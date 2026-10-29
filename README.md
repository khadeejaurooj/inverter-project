# POL Inverter Project (sanitized public copy)

A Flutter mobile app for monitoring solar inverters (live readings, device management and user administration over a REST API), together with a demo backend for local testing.

> ## About this repository
>
> This repository is a **sanitized copy** of the POL Inverter Project, published for reference and testing.
>
> - The original app and the **production backend are maintained separately and are not included here.** The production backend contains confidential configuration and private server details.
> - **`frontend/`** is the Flutter app with sensitive values removed. The server address and default device identifier are supplied at build time instead (see [Configuration](#configuration)).
> - **`backend/`** is a **demo (mock) backend** with fake data, provided only so the app can be run and tested without a real server. **It is not the production backend** and says nothing about how the production system is built, secured or deployed.

```
inverter-project/
  frontend/   Flutter app (sensitive values removed)
  backend/    Demo/mock backend (Node.js, no dependencies) with fake data. Not the production backend
  docs/       Screenshots (demo data only)
```

## What is in each part

| Part | What it is |
| --- | --- |
| [`frontend/`](frontend) | The Flutter app: sign up and sign in, inverter dashboard, device list and registration by MAC address, user list and delete, change password. MVVM with Provider and Dio. |
| [`backend/`](backend) | A **demo/mock server** that implements the endpoints the app calls, using clearly fake users and readings. **Not the production backend.** Configured with environment variables; see [`backend/README.md`](backend/README.md). |

## Run it locally

You need [Flutter](https://docs.flutter.dev/get-started/install) 3.27+ and [Node.js](https://nodejs.org) 18+.

**1. Start the demo backend**

```bash
cd backend
cp .env.example .env        # optional: change the port or the demo password
npm start
```

It listens on `http://0.0.0.0:24301` and logs every request. Demo login: `demo_admin` with the password from `.env` (default `Demo@1234`).

**2. Run the app against it**

```bash
cd frontend
flutter pub get
flutter run -d chrome                                            # backend on this computer
flutter run -d windows                                           # backend on this computer
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:24301     # Android emulator
```

For a physical phone on the same Wi-Fi, use your computer's address, for example `--dart-define=API_BASE_URL=http://192.168.1.20:24301`.

Android 9 and newer block plain `http://` unless the app allows it. If requests fail on a device with a plain-HTTP address, that is the reason; use the emulator address, or serve the backend over HTTPS.

## Configuration

Nothing about a particular server or device is stored in the code. The app reads two build-time settings, defined in [`frontend/lib/core/network/api_config.dart`](frontend/lib/core/network/api_config.dart):

| Setting | Default (placeholder) | Meaning |
| --- | --- | --- |
| `API_BASE_URL` | `http://localhost:24301` | Address of the backend, without a trailing slash |
| `DEFAULT_INVERTER_MAC` | `00:00:00:00:00:00` | MAC address of the inverter the dashboard shows until the user registers their own |

Pass them with `--dart-define`, for example when running or building against a real server:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-server.example.com \
  --dart-define=DEFAULT_INVERTER_MAC=AA:BB:CC:DD:EE:FF
```

The backend's settings (`PORT`, `HOST`, `DEMO_PASSWORD`, `DEMO_DATA_FILE`) live in environment variables or a local `backend/.env`, which is git-ignored. `backend/.env.example` lists them. To use your own demo users, copy `backend/demo-data.example.json` to `backend/demo-data.json` (also git-ignored).

The demo backend is **not secure** (its tokens are guessable). Use it only on your own machine or a trusted network.

## Tests

```bash
cd backend && npm test                              # 8 backend tests, no installs needed
cd frontend && flutter test test/api_config_test.dart
```

`api_config_test.dart` also fails if a server address or device MAC address is ever hard-coded back into the app's source.

`frontend/test/widget_test.dart` is Flutter's default counter test from the original project. It does not match this app, so a plain `flutter test` reports one failure there. It was left as it was.

## Screenshots

See [`docs/screenshots`](docs/screenshots). They show demo data only.
