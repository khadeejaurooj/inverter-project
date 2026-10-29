"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { createServer } = require("../server");

async function start(options = {}) {
  const server = createServer({ logRequests: false, ...options });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  const call = async (method, route, { body, token } = {}) => {
    const res = await fetch(base + route, {
      method,
      headers: { "Content-Type": "application/json", ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      body: body ? JSON.stringify(body) : undefined,
    });
    const text = await res.text();
    let json;
    try {
      json = JSON.parse(text);
    } catch {
      json = undefined;
    }
    return { status: res.status, text, json };
  };
  return { server, call, close: () => new Promise((r) => server.close(r)) };
}

const login = async (call, username = "demo_admin", password = "Demo@1234") =>
  call("POST", "/api/auth/signin", { body: { username, password } });

test("signs in with the demo account and rejects a wrong password", async () => {
  const { call, close } = await start();
  try {
    const ok = await login(call);
    assert.equal(ok.status, 200);
    assert.equal(ok.json.username, "demo_admin");
    assert.deepEqual(ok.json.roles, ["ROLE_ADMIN"]);
    assert.match(ok.json.token, /^demo-token-1$/);

    assert.equal((await login(call, "demo_admin", "nope")).status, 401);
    assert.equal((await login(call, "demo.admin@example.com")).status, 200, "email works as username");
  } finally {
    await close();
  }
});

test("protected routes need a valid token", async () => {
  const { call, close } = await start();
  try {
    assert.equal((await call("GET", "/api/auth/getAllUser")).status, 401);
    assert.equal((await call("GET", "/api/auth/getAllUser", { token: "bogus" })).status, 401);
  } finally {
    await close();
  }
});

test("lists users without exposing passwords, and soft-deletes", async () => {
  const { call, close } = await start();
  try {
    const { json: session } = await login(call);
    const users = await call("GET", "/api/auth/getAllUser", { token: session.token });
    assert.equal(users.json.length, 4);
    assert.ok(users.json.every((u) => !("password" in u)));

    const del = await call("PUT", "/api/auth/deleteUser?userId=4", { token: session.token });
    assert.equal(del.status, 200);
    assert.equal(del.text, "User deleted successfully");
    assert.equal((await call("GET", "/api/auth/getAllUser", { token: session.token })).json.length, 3);
    assert.equal((await call("PUT", "/api/auth/deleteUser?userId=99", { token: session.token })).status, 404);
  } finally {
    await close();
  }
});

test("signup validates input and the new user can sign in", async () => {
  const { call, close } = await start();
  try {
    const base = { username: "new_user", lastname: "N", email: "new@example.com", password: "Secret#1", confirmPassword: "Secret#1" };
    assert.equal((await call("POST", "/api/auth/signup", { body: { ...base, username: "" } })).status, 400);
    assert.equal((await call("POST", "/api/auth/signup", { body: { ...base, username: "demo_admin" } })).status, 400);
    assert.equal((await call("POST", "/api/auth/signup", { body: { ...base, confirmPassword: "x" } })).status, 400);
    assert.equal((await call("POST", "/api/auth/signup", { body: base })).status, 200);
    assert.equal((await login(call, "new_user", "Secret#1")).status, 200);
  } finally {
    await close();
  }
});

test("registers a device by MAC address and rejects duplicates", async () => {
  const { call, close } = await start();
  try {
    const { json: s } = await login(call);
    const add = await call("PUT", "/api/auth/macaddress?macAddress=02:00:00:bb:00:09&inverter_name=Test", { token: s.token });
    assert.equal(add.status, 200);
    assert.equal(add.json.message, "Mac Added!");
    const dup = await call("PUT", "/api/auth/macaddress?macAddress=02:00:00:BB:00:09&inverter_name=Again", { token: s.token });
    assert.equal(dup.status, 400);
    assert.equal(dup.json.message, "Mac is not Unique");
    assert.equal((await call("PUT", "/api/auth/macaddress?macAddress=x", { token: s.token })).status, 400);

    const devices = await call("GET", "/api/user/devices", { token: s.token });
    assert.equal(devices.json.length, 4);
    assert.equal(devices.json.at(-1).inverter_name, "Test");
  } finally {
    await close();
  }
});

test("changes the password", async () => {
  const { call, close } = await start();
  try {
    const { json: s } = await login(call, "alex_demo");
    const bad = await call("PUT", "/api/auth/changepassword", { token: s.token, body: { oldPassword: "wrong", newPassword: "n", confirmPassword: "n" } });
    assert.equal(bad.status, 400);
    const mismatch = await call("PUT", "/api/auth/changepassword", { token: s.token, body: { oldPassword: "Demo@1234", newPassword: "a", confirmPassword: "b" } });
    assert.equal(mismatch.status, 400);
    const ok = await call("PUT", "/api/auth/changepassword", { token: s.token, body: { oldPassword: "Demo@1234", newPassword: "Fresh#9", confirmPassword: "Fresh#9" } });
    assert.equal(ok.status, 200);
    assert.equal((await login(call, "alex_demo", "Demo@1234")).status, 401);
    assert.equal((await login(call, "alex_demo", "Fresh#9")).status, 200);
  } finally {
    await close();
  }
});

test("serves inverter readings in the shape the app expects", async () => {
  const { call, close } = await start();
  try {
    const { json: s } = await login(call);
    const r = await call("GET", "/api/inverter/getAllInverterData", { token: s.token });
    assert.equal(r.json.length, 12);
    for (const key of ["id", "energy_consumed", "gen_power", "pv_voltage", "output_voltage", "output_current", "mac_address", "error", "device_name", "version", "createdAt"]) {
      assert.ok(key in r.json[0], `missing ${key}`);
    }
    assert.equal((await call("GET", "/api/nope", { token: s.token })).status, 404);
  } finally {
    await close();
  }
});

test("DEMO_PASSWORD and a custom data file replace the built-in demo values", async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "inverter-backend-"));
  const dataFile = path.join(dir, "data.json");
  fs.writeFileSync(
    dataFile,
    JSON.stringify({
      users: [{ id: 1, username: "owner", lastname: "O", email: "o@example.com", address: "", postalCode: "", city: "", country: "", phone: 1, roles: [{ name: "ROLE_ADMIN" }] }],
      devices: [],
      inverter: { mac_address: "02:00:00:cc:00:01", device_name: "Custom", version: "v9" },
    })
  );
  const { call, close } = await start({ demoPassword: "Custom#Pass1", dataFile });
  try {
    assert.equal((await login(call, "owner", "Demo@1234")).status, 401);
    const ok = await login(call, "owner", "Custom#Pass1");
    assert.equal(ok.status, 200);
    const r = await call("GET", "/api/inverter/getAllInverterData", { token: ok.json.token });
    assert.equal(r.json[0].device_name, "Custom");
  } finally {
    await close();
    fs.rmSync(dir, { recursive: true, force: true });
  }
});
