# Project Mwendo — UI & Functionality Audit

> Audited every file across `app/lib/`, `packages/`, and `backend/`.
> Classification: **✅ Functional** · **⚠️ Partial/Stubbed** · **❌ Non-functional or Missing**

---

## 1. App Entry & Shell

| Component | File | Verdict |
|---|---|---|
| App bootstrap | [main.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/main.dart) | ✅ Clean — `ProviderScope`, `FlutterError.onError` |
| Root widget | [app.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/app.dart) | ✅ `MaterialApp.router`, dark mode default, Google Fonts |
| Router | [app_router.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/router/app_router.dart) | ✅ All 14 routes defined with `StatefulShellRoute` bottom nav |
| Bottom nav | `ScaffoldWithNavBar` in router | ✅ 5 tabs with a floating gradient "Run" icon |
| Theme system | [app_theme.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/theme/app_theme.dart) | ✅ Full design system: brand palette, spacing grid, motion tokens, HR zone ramp, challenge tier colours, `AppExtensions` on both light/dark |

**Notes:**
- ⚠️ `ThemeMode` is hardcoded to `ThemeMode.dark` in `app.dart`. The profile page has an "Appearance" setting tile (`_SettingTile`) but it does nothing — it doesn't toggle the theme. 
- ⚠️ The `_RunNavIcon` in the nav bar has a gradient glow but is not state-aware — it always shows a play arrow even when a run is actively recording. On a real device, users may not know they're still recording if they tab away.

---

## 2. Onboarding

| Screen | File | Verdict |
|---|---|---|
| 3-slide flow | [onboarding_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/onboarding/onboarding_page.dart) | ✅ Fully functional |

**What works:** PageView swipe + animated dot indicators + skip/next/get-started button. `SharedPreferences`-backed onboarding-done flag. Invalidates provider, navigates via `context.go('/')`.

**UI nits:**
- The body text colour is hardcoded `Colors.white70` — this will be wrong on light theme.
- No illustration/image on the slides — just a material icon inside a gradient circle. Adequate for MVP, but sparse compared to competitors.

---

## 3. Dashboard / Home

| Screen | File | Verdict |
|---|---|---|
| Dashboard | [dashboard_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/home/dashboard_page.dart) | ✅ Rich, well-composed |

**What works:**
- Top bar with streak flame + level badge.
- Weekly stats hero card (gradient, distance, runs, time, best pace) — all from gamification state.
- Active challenges shown via `ChallengeEvaluator.allChallenges` with real progress bars.
- "Continue learning" horizontal course carousel.
- "Recent activity" area with skeleton shimmer loading.

**Functional issues:**
- ⚠️ **Fake loading state** — `_loading` is just a `Future.delayed(700ms)` timer, not tied to any real data fetch. After 700ms it always shows `_EmptyActivity`. Even if `SampleActivity.all()` returns data, the dashboard ignores it.
- ⚠️ **"Start Run" button** is full-width but doesn't indicate GPS permission state. Will navigate to `/run` regardless.
- ⚠️ All weekly stats are `0` until the user completes a run through the gamification engine. There's no onboarding hint or animation to guide a first-time user.

---

## 4. Live Tracking / Run

| Screen | File | Verdict |
|---|---|---|
| Live dashboard | [live_dashboard.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/tracking/live_dashboard.dart) | ✅ Architecturally complete |
| Tracking controller | [tracking_controller.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/tracking/tracking_controller.dart) | ✅ Haversine, elevation gain, pace, calorie estimate |
| Metric tile | [metric_tile.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/tracking/widgets/metric_tile.dart) | ✅ |
| SOS countdown | `_SosButton` in live_dashboard | ✅ 3s countdown dialog |

**What works:**
- 58/42 split-screen: MapLibre map on top, 6-metric dashboard on bottom.
- Recording state pill (Ready / Recording / Paused / GPS…) with pulse glow.
- Start/Pause/Resume/Stop FAB cluster with haptic feedback.
- Live route line drawn on map (`_syncRoute` with LineOptions).
- km milestone haptic.
- Challenge completion confetti overlay on stop.
- Heart rate zone colouring (5-zone ramp) on the HR tile.
- Calorie estimate ~11 kcal/min.

**Functional issues:**
- ⚠️ **Map tile source is remote** — uses `basemaps.cartocdn.com` dark-matter style. No offline fallback; the run screen will show blank tiles without internet. The blueprint calls for offline MBTiles.
- ⚠️ **No GPS permission request** — `startRecording()` is called blindly. On Android 12+, the app will crash or silently get no points if location permissions haven't been granted. There's no runtime permission prompt anywhere in the app.
- ⚠️ **SOS dialog is visual only** — the countdown fires but `_confirmSos` never actually calls `SafetyService.sendSos()`. There's no emergency contact storage, so even if it did call the service, there's nothing to send to.
- ⚠️ **Tracking doesn't survive app tab-out** — the `TrackingModel` runs the GPS stream subscription in the widget lifecycle. If the user leaves the tab, the stream continues but there's no foreground service / notification keeping the process alive on Android. The OS can kill the location listener.
- ⚠️ **`_onStop` challenge evaluation bug** — `completeRun` is called with the model *before* `stop()` clears state, but `stop()` is `await`ed before reading the newly completed challenges. The read `m` captures the state correctly, but the `ref.read(gamificationProvider.notifier).completeRun()` uses a snapshot `m` — this is actually fine. However, the `next.earnedBadges.add(c.badgeId)` inside the gamification provider mutates a set that was created by `copyWith`, which is safe as long as `copyWith` creates new sets. Inspecting `copyWith`: it does `??` fallback, so it reuses the same set reference. **This is a mutation bug** — `earnedBadges` inside `next` is the same `Set` object as `state.earnedBadges` if not overridden, and `c.badgeId` modifies it in place.

---

## 5. Challenges

| Screen | File | Verdict |
|---|---|---|
| Library (grid) | [challenge_library_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/challenges/challenge_library_page.dart) | ✅ Rich UI with filters |
| Detail page | [challenge_detail_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/challenges/challenge_detail_page.dart) | ✅ |
| Evaluator | [challenge_evaluator.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/challenges/challenge_evaluator.dart) | ✅ ~50 challenges |

**What works:**
- Level header with `LevelRing` + XP bar.
- 6 category filter chips (All / Starter / Milestones / Performance / Fun / School / Learn).
- Each challenge card: tier-coloured icon, progress bar, XP reward, description.
- Detail page: gradient hero, tier badge, info tiles (Reward, Badge, Goal), progress bar, CTA button ("Go for a run" or "Open the Academy").

**Functional issues:**
- ⚠️ **Challenge routes clash** — `/challenges/:slug` is registered as a *sibling* route under the same `StatefulShellBranch` as `/challenges`. GoRouter may not resolve nested navigation correctly in all cases because both are top-level routes in the branch.
- ⚠️ **No persistence for per-challenge progress** — progress bars rely entirely on in-memory `GamificationState`, which is restored from SharedPreferences JSON. This works, but there's no debouncing — every `completeRun` serializes the entire state to SharedPreferences synchronously. Fine for now, but worth noting.

---

## 6. Learn / Academy

| Screen | File | Verdict |
|---|---|---|
| Learn landing | [learn_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/learn_page.dart) | ✅ |
| Course detail | [course_detail_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/course_detail_page.dart) | ✅ |
| Lesson reader | [lesson_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/lesson_page.dart) | ✅ |
| Course data | [courses.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/data/courses.dart) | ✅ |

**What works:**
- Hero banner with brand gradient.
- 3-section course grid (Science / Technique & Health / Heritage) with `GridView.count`.
- Progress bars per course based on completed lessons count.
- Course detail with lesson list → tappable rows.
- Lesson reader: full-text paragraphs, reading-time badge, "Mark complete" button awarding +15 XP with snackbar confirmation.
- Knowledge streak tracking in gamification provider.

**Functional issues:**
- ⚠️ **No quiz flow** — The blueprint specifies quizzes at the end of courses. The lesson page has a "Mark complete" button but no quiz widget.
- ⚠️ **Course slugs are hardcoded** — no CMS, no dynamic loading. Adding content requires code changes. Acceptable for MVP but noted.

---

## 7. Legends & Beat the Legends

| Screen | File | Verdict |
|---|---|---|
| Legends grid | [legends_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/legends_page.dart) | ✅ |
| Legend detail | [legend_detail_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/legend_detail_page.dart) | ✅ |
| Legend data | [legends.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/data/legends.dart) | ✅ 20 legends seeded |
| Beat the Legends | [beat_legends_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/beat/beat_legends_page.dart) | ⚠️ UI-only |
| Ghost pace data | [beat_legends.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/data/beat_legends.dart) | ✅ Split data defined |

**What works:**
- Horizontal legend picker carousel with emoji avatars and accent borders.
- Ghost header card with gradient, name, distance, target time, avg pace.
- Per-segment splits chart via `fl_chart`.
- "Race this ghost" button navigates to `/run`.

**Functional issues:**
- ⚠️ **Ghost racing is entirely cosmetic** — pressing "Race this ghost" navigates to the standard run page. There is no ghost marker on the map, no real-time pace comparison, no win/lose logic. The ghost splits data exists but is never consumed during an actual run.

---

## 8. Activity History

| Screen | File | Verdict |
|---|---|---|
| Activity list | [activity_list_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/activity/activity_list_page.dart) | ⚠️ Hardcoded data |
| Activity detail | [activity_detail_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/activity/activity_detail_page.dart) | ⚠️ Hardcoded data |
| Sample data | [sample_activities.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/data/sample_activities.dart) | ⚠️ Deterministic fake |

**What works:**
- Activity list with skeleton shimmer loading.
- Activity detail: top map, stats grid (6 tiles), elevation chart, pace chart, share button.
- Share integration via `share_plus`.

**Functional issues:**
- ❌ **Activities are not persisted from real runs** — the tracking controller `_onStop` feeds gamification state (distance, time, XP) but never writes the activity itself to storage. `SampleActivity.all()` generates 3 deterministic fakes based on hashed IDs. The list page uses those, not real data.
- ⚠️ **RouteMap widget** references MapLibre with sample coordinates, but has no link to real trackpoints from the tracking controller.
- ⚠️ **No activity deletion, editing, or filtering.**

---

## 9. Profile

| Screen | File | Verdict |
|---|---|---|
| Profile page | [profile_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/profile/profile_page.dart) | ✅ Well-featured |
| Leaderboard data | [leaderboard_data.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/gamification/leaderboard_data.dart) | ⚠️ Static fake |

**What works:**
- User avatar, level, title, XP bar.
- 4-stat row (Distance, Runs, Time, Streak).
- Achievement badge grid (earned via challenges and lessons).
- Title chip wall.
- Leaderboard top-5 with country flags and "You" highlight.
- Language toggle (EN/SW) via `SegmentedButton` → `localeProvider`.
- Settings tiles (Units, Appearance, Emergency contacts, Export data).

**Functional issues:**
- ⚠️ **Leaderboard is entirely fake** — `leaderboard_data.dart` generates static entries with hardcoded names and XP values. The Go backend has a real Redis leaderboard, but the app never calls it.
- ⚠️ **Settings tiles are decorative** — tapping Units, Appearance, Emergency contacts, or Export data does nothing. No sheets, no navigation, no functionality.
- ⚠️ **Username is hardcoded** — `'Runner'` is always displayed. No account system is connected.
- ⚠️ **No profile photo** — uses a plain `CircleAvatar` with a person icon.

---

## 10. Safety

| Component | File | Verdict |
|---|---|---|
| Safety service | [safety_service.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/safety/safety_service.dart) | ⚠️ Implemented but disconnected |

**What exists:** `SafetyService.sendSos(contacts, lat, lng)` builds an SMS URL with a Google Maps link and launches it via `url_launcher`.

**Functional issues:**
- ❌ **Never called** — the SOS button's countdown dialog just closes when it reaches 0. It never invokes `SafetyService.sendSos`.
- ❌ **No contact storage** — `EmergencyContact` is defined but there is no UI to add/edit contacts and no persistence layer.

---

## 11. Localization (i18n)

| Component | File | Verdict |
|---|---|---|
| String table | [app_strings.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/l10n/app_strings.dart) | ⚠️ Partial |

**What works:** 30 keys translated EN/SW. `L10n.tr(key, locale)` with fallback to English. `SegmentedButton` toggle on profile page instantly switches visible keys.

**Functional issues:**
- ⚠️ **Only ~30% of strings are translated** — many screens use hardcoded English strings (e.g. "This week", "Start Run", "No runs yet", "All caught up!", challenge titles, lesson titles, legend bios). The i18n system exists but is not consistently used.
- ⚠️ **Not using Flutter's standard ARB/`intl` system** — the blueprint calls for ARB assets. The current approach is a manual `Map<String, Map<String, String>>`, which won't scale well and doesn't get compile-time checks.

---

## 12. Data Layer

| Component | File | Verdict |
|---|---|---|
| Drift database | [app_database.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/data/database/app_database.dart) | ❌ Stub |
| Drift tables | [tables.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/data/database/tables.dart) | ❌ Stub |
| Repositories | `data/repositories/` | ❌ Empty directory |
| GPX parser | [gpx_parser.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/data/datasources/gpx_parser.dart) | ✅ Pure Dart XML parse/generate |
| Data models | `activity.dart`, `trackpoint.dart` | ⚠️ Tiny stubs |

**Analysis:**
- The entire offline data layer is missing. `AppDatabase` is an empty singleton. `tables.dart` defines `Users` and `Activities` columns but `build_runner` has never been run — no generated `.g.dart` files exist. The `repositories/` directory is empty.
- The app runs entirely on in-memory state (`GamificationState` in SharedPreferences JSON, `SampleActivity` fakes). Completed runs are counted in XP but never stored as discrete activity records.
- GPX parser is fully functional: parses `<trkpt>` with lat/lon/ele/time and generates GPX XML output. But nothing in the app calls it.

---

## 13. Packages

### mwendo_gps_engine

| Component | Verdict |
|---|---|
| Dart API surface | ✅ `startRecording()`, `pause()`, `resume()`, `stop()`, `state` stream |
| Platform interface | ✅ Abstract class with method channel default |
| Android Kotlin plugin | ⚠️ Method channel skeleton, basic location polling |
| iOS Swift plugin | ❌ Empty template |

**Functional issues:**
- ⚠️ **No foreground service** — location dies when app backgrounds on Android.
- ⚠️ **No speed hysteresis** — the blueprint calls for dynamically switching GPS interval based on running speed (walking = 3s, running = 1s, sprinting = 0.5s). Not implemented.
- ⚠️ **No Kalman filter** — raw GPS fixes are used as-is.

### mwendo_fit_parser

| Component | Verdict |
|---|---|
| Dart FFI wrapper | ⚠️ Skeleton with hardcoded path strings |
| Rust crate | ⚠️ Returns mock JSON `{"status": "scaffolded"}` |
| Bindings `.dart` | ⚠️ Referenced but likely not generated |

**Functional issues:**
- ❌ **Cannot parse FIT files** — `_parseJson` returns `{}`. `parseBytes` allocates memory but the Rust side just returns a canned string. 
- ❌ **Cannot compile locally** — Windows lacks MSVC linker for Rust; must be built via CI or cross-compilation.

---

## 14. Backend API

| Component | File | Verdict |
|---|---|---|
| HTTP router | [main.go](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/cmd/api/main.go) | ✅ |
| Auth handler | `internal/auth/handler.go` + `store.go` | ✅ bcrypt + JWT |
| Activity store | [store.go](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/internal/activity/store.go) | ✅ PostGIS spatial |
| Leaderboard | [leaderboard.go](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/internal/leaderboard/leaderboard.go) | ✅ Redis + fallback |
| Migrations | [0001_init.sql](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/internal/db/migrations/0001_init.sql) | ✅ |
| Integration tests | [main_test.go](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/cmd/api/main_test.go) | ✅ All passing |
| Dockerfile | [Dockerfile](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/Dockerfile) | ✅ Multi-stage Alpine |

**Functional issues:**
- ⚠️ **Backend is never called from the Flutter app** — there is no HTTP client, no `dio` interceptor configured, no auth token storage, no API base URL configuration anywhere in the app code. The `dio` package is in `pubspec.yaml` but never imported.
- ⚠️ **Dockerfile copies `go.mod` but not `go.sum`** — `RUN go mod download` will fail without `go.sum`. Should be `COPY go.mod go.sum ./`.
- ⚠️ **No CORS** — if a web client were ever added, the backend doesn't set CORS headers.

---

## 15. Shared Widgets

| Widget | File | Verdict |
|---|---|---|
| CelebrationOverlay | [celebration_overlay.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/celebration_overlay.dart) | ✅ Confetti + trophy |
| LevelRing + XpBar | [level_ring.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/level_ring.dart) | ✅ |
| RouteMap | [route_map.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/route_map.dart) | ⚠️ Uses remote tiles |
| SectionTitle | [section_title.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/section_title.dart) | ✅ |
| SkeletonCard | [skeleton.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/skeleton.dart) | ✅ Shimmer |

---

## 16. Bug Summary

| # | Severity | Location | Description |
|---|---|---|---|
| 1 | 🔴 High | [gamification_provider.dart:85](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/gamification/gamification_provider.dart#L85) | **Set mutation bug** — `next.earnedBadges.add(c.badgeId)` mutates the set in-place. If `copyWith` didn't override `earnedBadges`, `next.earnedBadges` is the same object as the old state's set. |
| 2 | 🔴 High | live_dashboard.dart | **No GPS permission request** — app will fail silently or crash on first run on a fresh install. |
| 3 | 🟡 Medium | live_dashboard.dart | **SOS countdown never sends** — `_confirmSos` timer fires but doesn't call `SafetyService.sendSos`. |
| 4 | 🟡 Medium | Dockerfile L3 | **Missing `go.sum`** — `COPY go.mod ./` should include `go.sum`. |
| 5 | 🟡 Medium | tracking_controller | **No persistence** — completed runs update XP but the activity is discarded. |
| 6 | 🟡 Medium | All screens | **No backend integration** — `dio` is declared but never used. |
| 7 | 🟢 Low | onboarding_page.dart L137 | **Hardcoded `Colors.white70`** — breaks on light theme. |
| 8 | 🟢 Low | dashboard_page.dart L26 | **Fake 700ms loading** — shimmer is cosmetic, not tied to real data loading. |

---

## 17. Feature Completeness Scorecard

| Feature (Blueprint) | UI | Logic | Backend | Data Layer | Score |
|---|---|---|---|---|---|
| GPS Tracking | ✅ | ✅ | n/a | ❌ no persist | 60% |
| Activity History | ✅ | ❌ fakes | ✅ | ❌ no DB | 35% |
| Challenges + XP | ✅ | ✅ | n/a | ✅ SharedPrefs | 85% |
| Learn Academy | ✅ | ✅ | n/a | ✅ SharedPrefs | 80% |
| Legends | ✅ | ✅ | n/a | ✅ static | 90% |
| Beat the Legends | ✅ | ❌ ghost logic | n/a | ✅ split data | 40% |
| Safety/SOS | ⚠️ | ❌ disconnected | n/a | ❌ no contacts | 15% |
| Leaderboard | ✅ | ❌ fake data | ✅ Redis | ❌ no API call | 35% |
| Auth | ❌ no UI | ❌ | ✅ bcrypt/JWT | ❌ no client | 25% |
| Offline Maps | ❌ | ❌ | n/a | n/a | 0% |
| FIT Import | ❌ | ❌ | n/a | ❌ stub | 5% |
| i18n EN/SW | ⚠️ partial | ✅ toggle | n/a | ✅ | 50% |
| Profile/Settings | ✅ | ⚠️ decorative | n/a | ⚠️ | 40% |

**Overall Phase 1+2 completion: ~45%** — the UI layer is ~80% built, the backend is ~90% built, but the two halves aren't connected, and the critical mobile plumbing (local DB, GPS permissions, activity persistence, FIT parsing) is missing.
