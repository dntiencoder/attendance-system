# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

GPS-based attendance system built as two independent Flutter apps sharing one Firebase backend (project `attendance-management-sy-34105`):

- **`attendance_mobile/`** — employee-facing app (check-in/out via GPS, attendance history, leave, profile). Targets Android/iOS primarily.
- **`attendance_admin/`** — admin/HR web+desktop dashboard (employee management, department management, attendance oversight, leave approval, company settings, exports). Targets web primarily (`fl_chart`, `excel`/`pdf`/`printing` exports are admin-only deps).

There is no custom backend server — all data access goes directly through the Firebase client SDKs (`cloud_firestore`, `firebase_auth`, `firebase_storage`) from both apps. Each app has its own `lib/firebase_options.dart` but they point at the same Firebase project, so **Firestore collection/document shapes are a shared contract between the two codebases** — a change to a field name or document ID scheme in one app's model/repository must be mirrored in the other.

## Commands

Run these from inside `attendance_mobile/` or `attendance_admin/` respectively (each is its own Flutter project with its own `pubspec.yaml`; there is no root-level pubspec).

```bash
flutter pub get                 # install dependencies
flutter analyze                 # static analysis / lint (flutter_lints)
flutter test                    # run all tests
flutter test test/widget_test.dart   # run a single test file
flutter run                     # run main.dart (normal entrypoint)
flutter run -t lib/main_dev.dart     # mobile only: dev entrypoint, wipes & reseeds Firestore demo data on every launch (see Dev/seed tooling below)
```

Both apps currently only ship the default `test/widget_test.dart` smoke test — there is no meaningful test suite to run beyond `flutter test`.

## Architecture

Both apps follow the same **feature-first layered structure** under `lib/features/<feature>/`:

- `domain/` — plain model classes with `fromFirestore(DocumentSnapshot)` / `toFirestore()` converters. No business logic beyond simple getters.
- `data/` — `*Repository` classes that talk directly to `FirebaseFirestore.instance` / `FirebaseAuth.instance`. This is the only layer that should contain Firestore queries.
- `presentation/` — Riverpod providers (`*_provider.dart`) plus screens/widgets. Providers wrap repositories; screens/widgets consume providers via `flutter_riverpod`, never call repositories directly.

Cross-cutting code lives in `lib/core/` (constants, routing, date/GPS/schedule helpers) and `lib/shared/` (theme, reusable widgets). `lib/dev/` holds one-off seeding/test-data scripts, not part of the shipped app.

Routing in both apps uses `go_router` with auth-based redirects driven by `FirebaseAuth.instance` (mobile also listens via a custom `GoRouterRefreshStream` on `authStateChanges()` so route guards react live to sign-in/out). Mobile uses `StatefulShellRoute.indexedStack` for the bottom-nav tabs (home/history/leave/profile); admin uses a single `ShellRoute` wrapping `MainLayout` (sidebar) for dashboard/employees/attendance/leave/settings.

### Firestore data model (shared contract)

Key top-level collections, as read/written by both apps' repositories:

- `users` — employee/admin profile doc keyed by Firebase Auth `uid`. Fields include `employeeCode`, `role` (`admin`|`employee`, see `AppConfig.roleAdmin/roleEmployee`), `shiftGroup` (`A`/`B`), `departmentId`.
- `attendance` — one doc per employee per day, **doc ID is `"<yyyy-MM-dd>_<uid>"`** (built via `DateHelper.toDateString` + uid concatenation — see `attendance_repository.dart` in both apps). Check-in creates the doc, check-out updates it in place; there is no separate check-in/check-out record.
- `company_settings` — single doc, ID fixed to `AppConfig.companySettingsDocId` (`"main"`). Holds office GPS coordinates + radius, shift start/end times, and shift-rotation config (`rotationDays`, `rotationStartDate`).
- `departments` — department docs (`name`, `managerUid`).
- Also referenced: `leave_request` / notification models exist under `features/leave` and `features/notification` in both apps (mirror data shape between apps when touching these).

### Shift & attendance business logic (`CompanySettingsModel`, duplicated in both apps' `settings/domain/company_settings_model.dart`)

- Two shifts: `day` and `night`, each with configurable start/end times (`HH:mm` strings).
- Employees are assigned to rotation group `A` or `B` (`shiftGroup`). Which group works which shift flips every `rotationDays` (default 14) relative to `rotationStartDate` — see `getCurrentShift()`. This logic is duplicated between the mobile and admin model files; keep them in sync if the rotation rule changes.
- Check-in (`AttendanceRepository.checkIn`, mobile) computes distance from office via Haversine (`core/utils/haversine.dart` + `services/gps_service.dart`), rejects if outside `company_settings.radius`, rejects if past the shift's end time (treated as absence), and stamps `isLate`/`status` based on `calculateIsLate`.
- Check-out (`AttendanceRepository.checkOut`) requires an existing check-in doc for today, re-validates GPS radius, computes `workHours` and `isEarlyLeave` via `calculateEarlyLeave`, and sets `status: 'completed'`.
- Night-shift boundary handling (shift end time earlier than start time, spanning midnight) is handled with explicit day-rollover checks in both check-in/out and `calculateEarlyLeave` — be careful preserving this when editing shift-time logic.

### State management

Both apps use `flutter_riverpod` throughout. Providers generally expose a repository instance and async data (e.g. `FutureProvider`/`StreamProvider` wrapping repository calls); screens use `ConsumerWidget`/`ConsumerStatefulWidget`. Follow the existing per-feature `*_provider.dart` naming and co-location convention when adding new features.

### Dev/seed tooling

- `attendance_mobile/lib/dev/demo_seeder.dart` — wipes and reseeds demo Firestore data; invoked automatically by `main_dev.dart` on every launch. Do not point this at a production Firebase project.
- `attendance_mobile/lib/dev/seed_firestore.dart`, `create_test_user.dart` — standalone seeding helpers.
- `attendance_admin/lib/dev/department_seeder.dart` — exposed via a hidden route `/dev/seed-departments` in the admin router.

## Development Workflow

Before coding:

1. Analyze the requirement.
2. Explain the root cause.
3. Explain the proposed solution.
4. List all files that will be modified.
5. Wait for user confirmation.

During implementation:

- Only modify files directly related to the task.
- Keep changes minimal.
- Do not refactor unrelated code.
- Do not rename classes, files or folders.
- Do not change Firestore schema.
- Do not change project architecture.
- Do not add packages unless requested.

After implementation:

1. Summarize every change.
2. Explain possible side effects.
3. Suggest manual tests.
4. Wait for approval before continuing to the next task.