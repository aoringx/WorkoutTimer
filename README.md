# WorkoutTimer

WorkoutTimer is a native iOS calisthenics app for building exercise libraries, creating reusable workouts, and following guided set and rest intervals.

## Features

- Browse, search, filter, sort, create, edit, and delete exercises.
- Assign each exercise one Planche, Push, Pull, Legs, Handstand, L-sit, Core, Freeze, Power, or Cardio type, with duplicate names supported across different types.
- Configure sets, reps or seconds, and rest time for each exercise.
- Keep one automatic workout synchronized for every exercise category.
- Build reusable workouts by selecting and reordering exercises.
- Run workouts with automatic guided warm-up and cool-down phases, a set jump slider, set progress, background-safe rest countdowns, completion alerts, and upcoming-exercise previews.
- Pin and reorder all workouts, and edit or delete user-created workouts.
- Enable sound effects, countdown beeps, haptic feedback, automatic set advancement, and screen-awake behavior.
- Start with a bundled calisthenics exercise catalog and category workouts.
- Store exercises, workouts, and preferences locally on the device.

## Tech Stack

- Swift 5
- SwiftUI
- SwiftData
- AVFAudio
- UIKit
- Xcode 26.5
- iOS 26.5+

The project has no third-party dependencies.

## Getting Started

1. Clone the repository.
2. Open `WorkoutTimer.xcodeproj` in Xcode.
3. Select the `WorkoutTimer` scheme and an iOS simulator or device.
4. Build and run with **Command-R**.

Code signing is required when running on a physical device.

## Databases

On a fresh install with an empty database, the app adds the bundled exercise collection. The app maintains one automatic workout for every category and synchronizes its exercises with the exercise library. Automatic category workouts cannot be renamed or deleted; user-created workouts remain independently editable.

Rebuilding the project does not clear persisted SwiftData. Delete the app or erase its simulator data to start with a completely fresh copy of the bundled database.

## Project Structure

The app uses a feature-first layout with shared core layers:

| Directory | Responsibility |
| --- | --- |
| `WorkoutTimer/App/` | App entry point, root navigation, and startup |
| `WorkoutTimer/Core/` | App-wide configuration, models, persistence, extensions, and utilities |
| `WorkoutTimer/Features/` | Exercise library, workout library, workout runner, and settings flows |
| `WorkoutTimer/Shared/` | Reusable design-system components and styles |
| `WorkoutTimer/Resources/` | Asset catalogs and other bundled resources |
| `Documentation/` | Architecture and contributor-facing project notes |

See [Architecture](Documentation/Architecture.md) for the full directory map,
dependency direction, and file-placement conventions.

## Data Model

The exercise model stores reusable definitions. Automatic category workouts stay synchronized with those definitions. When an exercise is added to a user-created workout, its values are copied into the saved workout, allowing it to remain stable if the exercise library changes later. Each workout owns its ordered exercises through a SwiftData cascade relationship.

## Build Verification

To perform a command-line simulator build:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild \
  -project WorkoutTimer.xcodeproj \
  -scheme WorkoutTimer \
  -sdk iphonesimulator \
  -configuration Debug \
  -derivedDataPath /tmp/WorkoutTimerDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```
