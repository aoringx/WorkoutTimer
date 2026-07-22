# WorkoutTimer

WorkoutTimer is a native iOS calisthenics workout timer for building exercise libraries, creating reusable routines, and following guided set and rest intervals.

## Features

- Browse, search, filter, sort, create, edit, and delete exercises.
- Organize exercises into Planche, Push, Pull, Legs, Handstand, and Core categories.
- Configure sets, reps or seconds, rest time, and notes for each exercise.
- Build reusable workout timers by selecting and reordering exercises.
- Run workouts with set progress, rest countdowns, and upcoming-exercise previews.
- Pin, sort, reorder, edit, and delete saved timers.
- Enable sound effects, countdown beeps, haptic feedback, automatic set advancement, and screen-awake behavior.
- Start with a bundled calisthenics exercise catalog and ready-made routines.
- Store exercises, timers, and preferences locally on the device.

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

## Default Data

On launch, the app checks the bundled exercise and timer database versions and installs any missing defaults when a newer content version is available. Existing exercises and timers with matching names are preserved instead of being overwritten.

Rebuilding the project does not clear persisted SwiftData. Delete the app or erase its simulator data to start with a completely fresh copy of the bundled database.

## Project Structure

| Area | Key files |
| --- | --- |
| App setup and navigation | `WorkoutTimerApp.swift`, `ContentView.swift` |
| Exercise library | `ExerciseItem.swift`, `ExercisesOptionsView.swift`, `ExerciseEditorView.swift` |
| Timer creation and management | `GenerateTimerView.swift`, `EditTimerView.swift`, `ManageTimersView.swift` |
| Workout experience | `TimerRunnerView.swift`, `TimerRunnerComponents.swift`, `WorkoutSoundPlayer.swift` |
| Persistence models | `WorkoutTimerItem.swift`, `TimerExerciseItem.swift` |
| Bundled content | `DefaultExerciseDatabase.swift`, `DefaultTimerDatabase.swift` |
| Preferences and sorting | `SettingsView.swift`, `AppSettings.swift`, `SortOptions.swift` |

## Data Model

`ExerciseItem` stores reusable exercise definitions. When an exercise is added to a timer, its workout values are copied into a `TimerExerciseItem`, allowing saved routines to remain stable if the exercise library changes later. `WorkoutTimerItem` owns the ordered timer exercises through a SwiftData cascade relationship.

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
