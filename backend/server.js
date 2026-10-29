"use strict";

// Demo backend for the inverter app.
// It implements the endpoints the Flutter app calls, with clearly fake demo data.
// For development, tests and screenshots only: it is not secure and must not be
// exposed to the internet. See README.md.
//
//   npm start                 (listens on PORT, default 24301)
//
// All settings come from environment variables or a local .env file; see .env.example.

const fs = require("fs");
const http = require("http");
const path = require("path");
const { URL } = require("url");

/** Reads KEY=VALUE lines from a .env file into process.env. Real environment variables win. */
function loadEnvFile(file) {
  if (!fs.existsSync(file)) return;
  for (const line of fs.readFileSync(file, "utf8").split(/\r?\n/)) {
    const m = /^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/.exec(line);
    if (!m || line.trim().startsWith("#")) continue;
    const value = m[2].replace(/^(['"])(.*)\1$/, "$2");
    if (process.env[m[1]] === undefined) process.env[m[1]] = value;
  }
}

/** demo-data.json (local, git-ignored) wins over the committed demo-data.example.json. */
function resolveDataFile() {
  if (process.env.DEMO_DATA_FILE) return path.resolve(process.env.DEMO_DATA_FILE);
  const local = path.join(__dirname, "demo-data.json");
  return fs.existsSync(local) ? local : path.join(__dirname, "demo-data.example.json");
}

function readConfig() {
  return {
    port: Number(process.env.PORT || 24301),
    host: process.env.HOST || "0.0.0.0",
    // Applied to every demo user that has no password of its own in the data file.
    demoPassword: process.env.DEMO_PASSWORD || "Demo@1234",
    dataFile: resolveDataFile(),
  };
}

/** Builds a fresh server with its own in-memory state. */
function createServer(options = {}) {
  const config = { ...readConfig(), ...options };
  const logRequests = options.logRequests !== false;
  const data = JSON.parse(fs.readFileSync(config.dataFile, "utf8"));

  const users = data.users.map((u) => ({ ...u, password: u.password || config.demoPassword }));
  const devices = data.devices.map((d) => ({ ...d }));
  const inverter = data.inverter;

  const tokens = new Map(); // token -> user id

  // Plausible solar readings over the last few hours.
  const readings = Array.from({ length: 12 }, (_, i) => {
    const t = new Date(Date.now() - (11 - i) * 15 * 60 * 1000);
    const sun = Math.sin(Math.PI * (0.12 + (i / 11) * 0.38)); // morning ramp-up, latest reading near the peak
    return {
      id: 1000 + i,
      energy_consumed: +(1.2 + i * 0.35).toFixed(2),
      gen_power: +(1800 + sun * 2400).toFixed(1),
      pv_voltage: +(310 + sun * 60).toFixed(1),
      output_voltage: +(229.5 + (i % 3) * 0.4).toFixed(1),
      output_current: +(7.4 + sun * 9).toFixed(2),
      mac_address: inverter.mac_address,
      error: 0,
      device_name: inverter.device_name,
      version: inverter.version,
      createdAt: t.toISOString(),
    };
  });

  const send = (res, status, body, type = "application/json") => {
    const payload = typeof body === "string" ? body : JSON.stringify(body);
    res.writeHead(status, { "Content-Type": type, "Content-Length": Buffer.byteLength(payload) });
    res.end(payload);
  };

  const readBody = (req) =>
    new Promise((resolve) => {
      let raw = "";
      req.on("data", (c) => (raw += c));
      req.on("end", () => {
        try {
          resolve(raw ? JSON.parse(raw) : {});
        } catch {
          resolve({});
        }
      });
    });

  const authed = (req) => {
    const h = req.headers["authorization"] || "";
    const t = h.startsWith("Bearer ") ? h.slice(7) : "";
    const m = /^demo-token-(\d+)$/.exec(t);
    return m ? users.find((u) => u.id === Number(m[1])) || null : null;
  };

  const publicUser = ({ password, ...u }) => u;

  return http.createServer(async (req, res) => {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const route = `${req.method} ${url.pathname}`;
    if (logRequests) console.log(new Date().toISOString().slice(11, 19), route, url.search);
    const body = ["POST", "PUT"].includes(req.method) ? await readBody(req) : {};

    if (route === "POST /api/auth/signin") {
      const u = users.find((x) => (x.username === body.username || x.email === body.username) && x.password === body.password);
      if (!u) return send(res, 401, { message: "Error: Unauthorized" });
      const token = `demo-token-${u.id}`; // stateless, survives server restarts
      tokens.set(token, u.id);
      return send(res, 200, { token, type: "Bearer", id: u.id, username: u.username, email: u.email, roles: u.roles.map((r) => r.name) });
    }

    if (route === "POST /api/auth/signup") {
      if (!body.username || !body.email || !body.password) return send(res, 400, { message: "Error: Missing fields" });
      if (users.some((u) => u.username === body.username)) return send(res, 400, { message: "Error: Username is already taken!" });
      if (users.some((u) => u.email === body.email)) return send(res, 400, { message: "Error: Email is already in use!" });
      if (body.password !== body.confirmPassword) return send(res, 400, { message: "Error: Passwords do not match" });
      users.push({ id: users.length + 1, username: body.username, lastname: body.lastname || "", email: body.email, password: body.password, address: "", postalCode: "", city: "", country: "", phone: 0, roles: [{ name: "ROLE_USER" }] });
      return send(res, 200, { message: "User registered successfully!" });
    }

    const me = authed(req);
    if (!me) return send(res, 401, { message: "Error: Unauthorized" });

    if (route === "GET /api/auth/getAllUser") return send(res, 200, users.filter((u) => !u.deleted).map(publicUser));

    if (route === "PUT /api/auth/deleteUser") {
      const u = users.find((x) => x.id === Number(url.searchParams.get("userId")));
      if (!u) return send(res, 404, "User not found", "text/plain");
      u.deleted = true;
      return send(res, 200, "User deleted successfully", "text/plain");
    }

    if (route === "PUT /api/auth/macaddress") {
      const mac = url.searchParams.get("macAddress");
      const name = url.searchParams.get("inverter_name");
      if (!mac || !name) return send(res, 400, { message: "MAC address and inverter name are required" });
      if (devices.some((d) => d.mac_address.toLowerCase() === mac.toLowerCase())) return send(res, 400, { message: "Mac is not Unique" });
      devices.push({ mac_address: mac, inverter_name: name, userId: me.id });
      return send(res, 200, { message: "Mac Added!" });
    }

    if (route === "PUT /api/auth/changepassword") {
      if (body.oldPassword !== me.password) return send(res, 400, { message: "Old password is incorrect" });
      if (!body.newPassword || body.newPassword !== body.confirmPassword) return send(res, 400, { message: "Passwords do not match" });
      me.password = body.newPassword;
      return send(res, 200, { message: "Password changed successfully" });
    }

    if (route === "GET /api/user/devices") {
      return send(
        res,
        200,
        devices.map((d) => {
          const u = users.find((x) => x.id === d.userId) || me;
          return { mac_address: d.mac_address, inverter_name: d.inverter_name, user: { id: u.id, username: u.username, email: u.email, address: u.address, phone: u.phone } };
        })
      );
    }

    if (route === "GET /api/inverter/getAllInverterData") return send(res, 200, readings);

    send(res, 404, { message: "Not found" });
  });
}

module.exports = { createServer, readConfig };

if (require.main === module) {
  loadEnvFile(path.join(__dirname, ".env"));
  const config = readConfig();
  createServer().listen(config.port, config.host, () => {
    console.log(`Inverter demo backend on http://${config.host}:${config.port}`);
    console.log(`Demo data: ${path.relative(process.cwd(), config.dataFile) || config.dataFile}`);
  });
}
