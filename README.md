<div align="center">

# Mwendo

**The open-source running tracker, teacher, and challenge platform — built in Kenya, for the world.**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Go](https://img.shields.io/badge/Go-00ADD8?logo=go&logoColor=white)](https://go.dev)
[![Licenses](https://img.shields.io/badge/License-MIT%20%2F%20Apache--2.0%20%2F%20AGPL--3.0-blue)](./LICENSE-MIT)

*Measure every step. Learn the craft of running. Celebrate East African heritage. All without a black-box AI coach — just your own effort, knowledge, and community.*

</div>

---

## Why Mwendo?

Most running apps lock your data behind proprietary clouds, demand a fast connection, and bury the
sport's rich heritage under gamified noise. **Mwendo** takes the opposite stance:

- **Privacy-first** — your runs are recorded and stored on your device. Cloud sync is opt-in.
- **Offline-first** — full tracking, maps, education, and challenges work without a signal.
- **Open by default** — every line of code, map, and lesson is released under an open licence.
- **Built for real conditions** — designed for low-end devices and intermittent connectivity,
  with a deep respect for East African running culture.

Mwendo is more than a tracker. It is a companion that teaches the science of running, connects you
to the legends who shaped the sport, and motivates you through challenges, streaks, and friendly
leaderboards.

---

## Features

### Track every run
- **Native GPS engine** — a custom Flutter plugin (Kotlin on Android, Swift on iOS) keeps
  recording through a foreground service / background location session, so a run survives a locked
  screen or a backgrounded app.
- **Live dashboard** — distance, elapsed time, current & average pace, speed, heart rate, cadence,
  elevation gain, and calories update in real time.
- **Live map** — a breadcrumb trail and current-location marker that follow you as you move.
- **Wall-clock timer** — the run timer ticks from the moment you press Start, independent of GPS
  signal, so it never appears frozen when satellites are scarce.
- **Crash recovery** — an interrupted run is automatically detected and restored on next launch.
- **Serial command locking** — rapid start/pause/resume/stop taps are queued so they can never
  race.

### Maps that work anywhere
- **Offline maps** — MBTiles and PMTiles v3 bundles are served to MapLibre GL through a local
  loopback tile server, so you can run without cell data.
- **Online fallback** — with no bundle present, the map gracefully uses the online style.

### Learn & celebrate
- **Running education** — an in-app academy covering technique, training science, and health.
- **East African legends** — interactive history, records, and stories of the sport's greats.
- **Beat the Legends** — ghost-runner challenges racing against legendary performances.
- **Challenges & gamification** — XP, levels, badges, streaks, and leaderboards to keep you
  coming back.

### Safety
- **Emergency SOS** — one tap sends your live GPS coordinates to pre-set emergency contacts.

### Sync & community
- **Accounts & cloud sync** — sign in to submit runs and climb the leaderboard; stay anonymous
  and keep everything local if you prefer.
- **Multilingual** — English and Swahili at launch, with full `i18n` throughout the UI.
- **Export** — GPX and JSON export of your activities to share or back up.

> Mwendo follows a nine-pillar blueprint (tracking, education, legends, challenges, gamification,
> safety, and more). The pillars above are the ones implemented today; the rest are on the roadmap.

---

## Architecture

Mwendo is a monorepo split into a mobile app, a backend service, and reusable native/Dart packages.

| Layer | Technology |
|-------|------------|
| **Mobile app** | Flutter & Dart, Riverpod (state), go_router (routing), drift/SQLite (local store), MapLibre GL (maps) |
| **GPS engine** | Native Flutter plugin — Kotlin (Android) + Swift (iOS) + Dart, architecturally based on the Apache-2.0 [OpenTracks](https://github.com/OpenTracksApp/OpenTracks) project |
| **FIT parser** | Dart package with a Rust core (FFI) for decoding Garmin FIT files |
| **Backend** | Go REST API with a SQL datastore, containerised via Docker |

### Project structure

```
mwendo/
├── app/                 # Flutter mobile application
├── backend/             # Go backend (auth, activities, leaderboard)
├── packages/
│   ├── mwendo_gps_engine/   # Native GPS tracking plugin (Kotlin/Swift/Dart)
│   └── mwendo_fit_parser/   # FIT file parser (Dart + Rust)
├── docs/                # Design documentation and course content
└── tools/               # Development and content tooling
```

---

## Getting started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x)
- A Go toolchain (1.22+) for the backend
- An Android or iOS device/emulator with developer mode

### Run the mobile app

```bash
cd app
flutter pub get
flutter run            # launches on a connected device or emulator
```

### Run the backend

```bash
cd backend
go run ./cmd/api       # serves the REST API (see backend/cmd/api/main.go)
# or, containerised:
docker build -t mwendo-api . && docker run -p 8080:8080 mwendo-api
```

The app talks to the backend over `POST /api/v1/auth/*`, `/api/v1/activities`, and
`/api/v1/leaderboard/submit`. Anonymous runs never leave the device.

---

## Development notes

A few platform specifics worth knowing before you build or review:

- **Background location permission (critical for real runs).** The tracker requests
  `locationWhenInUse`, then `locationAlways`. On Android 10+ the foreground location service only
  keeps delivering updates while the screen is off if the user grants **"Allow all the time"** —
  otherwise tracking freezes when the screen locks. The app warns when this is denied; keeping the
  screen on also works.
- **Offline maps need a bundle.** Drop an `.mbtiles` or `.pmtiles` file into the app's
  `offline_maps/` directory (e.g. `getApplicationDocumentsDirectory()/offline_maps/`). With no
  bundle, the map uses the online style and needs cell data.
- **Cleartext loopback tiles.** `android:networkSecurityConfig` permits cleartext HTTP only to
  `127.0.0.1`/`localhost`, so the offline tile server works on Android 9+.
- **GPS plugin build fix.** `MwendoTrackingService.activityId` is package-visible (not `private`)
  and the `@SuppressLint` annotation was removed, because `androidx.annotation` is not on the AGP 9
  classpath. Both are required for the APK to compile.
- **The run timer is wall-clock driven.** `elapsedMs` is accumulated by a 1s ticker started on
  `start()` and banked on pause/stop. GPS feeds distance, pace, and calories only — the timer
  itself never depends on a satellite fix. A run that moves less than 1 m is still not saved (the
  `distanceM < 1` guard is intentional).
- **Route line follows the recorded path.** The live map (`_MapView`) uses
  `MyLocationTrackingMode.none` so the camera follows the *recorded* `trackPoints` polyline rather
  than the device's raw GPS fix (which lagged behind and made the route look wrong). The camera
  preserves the user's zoom and recenters on the route's end via `CameraUpdate.newLatLng`. Line
  drawing is serialized (`_isSyncing` / `_pendingCoords`) to avoid concurrent add/remove conflicts,
  and stale lines are cleared when fewer than two points remain. The static past-route map
  (`RouteMap`) draws the same polyline with no user-tracking line.

---

## Licensing

Mwendo is open source under a per-component licence model:

| Component | Licence |
|-----------|---------|
| Mobile app & local packages (`app/`, `packages/`) | MIT or Apache-2.0 |
| Backend (`backend/`) | AGPL-3.0 |
| Educational content (`docs/`) | CC-BY-SA-4.0 |

See [`LICENSE-MIT`](./LICENSE-MIT), [`LICENSE-APACHE`](./LICENSE-APACHE), and
[`LICENSE-AGPL`](./LICENSE-AGPL).

---

## Contributing

Contributions are welcome — whether code, translations, course content, or bug reports. Please open
an issue to discuss substantial changes first, and ensure `flutter analyze` (and `go vet` for the
backend) pass before submitting a pull request.

---

## Acknowledgements

Mwendo's native GPS engine is architecturally inspired by the Apache-2.0-licensed
[OpenTracks](https://github.com/OpenTracksApp/OpenTracks) project, reimplemented clean-room for the
Flutter plugin. Heartfelt thanks to the East African running community whose heritage this project
exists to celebrate.

---

<div align="center">

**Mwendo** — *your effort, your knowledge, your community.*

</div>
