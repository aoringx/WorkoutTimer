# Architecture

WorkoutTimer uses a feature-first iOS project structure with a small set of
shared layers. The folders on disk are filesystem-synchronized with Xcode, so
the same hierarchy appears in the project navigator.

## Directory layout

```text
WorkoutTimer/
├── App/                         App entry point and root navigation
├── Core/
│   ├── Configuration/          App-wide settings keys and defaults
│   ├── Extensions/             App-wide extensions on system types
│   ├── Models/                 SwiftData models and domain types
│   ├── Persistence/            Database seeding and synchronization
│   └── Utilities/              Small reusable, non-UI helpers
├── Features/
│   ├── ExerciseLibrary/        Exercise browsing and editing
│   │   ├── Models/
│   │   └── Views/
│   ├── Settings/               User preferences UI
│   │   └── Views/
│   ├── WorkoutLibrary/         Workout creation and management
│   │   ├── Components/
│   │   ├── Models/
│   │   └── Views/
│   └── WorkoutRunner/          Active workout flow and its services
│       ├── Components/
│       ├── Services/
│       └── Views/
├── Resources/                  Asset catalogs and future localized resources
└── Shared/
    └── DesignSystem/           Reusable styles and UI components
```

Project documentation lives in `Documentation/` at the repository root so it
is not bundled into the app target.

## Dependency direction

Keep dependencies flowing toward the reusable layers:

```text
App -> Features -> Shared -> Core
               \----------> Core
```

- `App` composes the application, creates dependencies, and owns root
  navigation and startup work.
- `Features` contain user-facing flows. A feature can use `Core` and `Shared`,
  but should not reach into another feature's implementation.
- `Shared` contains code used by more than one feature. It can build on domain
  types from `Core`.
- `Core` contains app-wide data and configuration and must not depend on a
  feature.

## Where new code belongs

- Add a new user-facing flow under `Features/<FeatureName>/`.
- Keep feature-specific views, components, and services inside that feature.
- Put SwiftData models and domain-wide types in `Core/Models/`.
- Put database setup, migrations, and seed data in `Core/Persistence/`.
- Put system-type extensions and non-UI helpers in `Core/Extensions/` and
  `Core/Utilities/`.
- Move a component to `Shared/` only after multiple features use it.
- Put asset catalogs, string catalogs, and bundled files in `Resources/`.
- Name a Swift file after its primary type so it is easy to find in Xcode.

When test targets are added, mirror this hierarchy in `WorkoutTimerTests/` and
`WorkoutTimerUITests/` at the repository root.
