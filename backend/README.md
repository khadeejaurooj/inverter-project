# Inverter demo backend

A small Node.js server (no dependencies) that implements the endpoints the inverter app calls, with clearly fake demo data. Use it to develop, test and demo the app without a real server.

> **This is not the production backend.** It is a mock server with fake data, written only for local development and testing of the app. The production backend is maintained separately and is not part of this repository.
>
> Demo only. Authentication is intentionally simple (tokens are guessable) and data lives in memory. Do not expose it to the internet.

## Run

Requires Node.js 18 or newer.

```bash
cp .env.example .env     # optional
npm start
npm test
```

## Configuration

Set these as environment variables or in a local `.env` file (git-ignored). Real environment variables win over `.env`.

| Variable | Default | Meaning |
| --- | --- | --- |
| `PORT` | `24301` | Port to listen on |
| `HOST` | `0.0.0.0` | Interface to bind. Use `127.0.0.1` to accept only this computer |
| `DEMO_PASSWORD` | `Demo@1234` | Password for every demo user that has no `password` in the data file. It is a public demo value, so change it if others can reach the server |
| `DEMO_DATA_FILE` | `demo-data.json` if it exists, otherwise `demo-data.example.json` | Demo users, devices and the simulated inverter |

To use your own demo data, copy `demo-data.example.json` to `demo-data.json` and edit it. The local file is git-ignored.

## Endpoints

| Method and path | Auth | Purpose |
| --- | --- | --- |
| `POST /api/auth/signin` | no | Sign in with username or email; returns `{token, type, id, username, email, roles}` |
| `POST /api/auth/signup` | no | Register a user |
| `GET /api/auth/getAllUser` | Bearer | List users (never includes passwords) |
| `PUT /api/auth/deleteUser?userId=` | Bearer | Mark a user deleted |
| `PUT /api/auth/macaddress?macAddress=&inverter_name=` | Bearer | Register an inverter; rejects a duplicate MAC |
| `PUT /api/auth/changepassword` | Bearer | Change the caller's password |
| `GET /api/user/devices` | Bearer | List registered inverters with their owner |
| `GET /api/inverter/getAllInverterData` | Bearer | Latest 12 simulated readings |

Send the token as `Authorization: Bearer <token>`.
