## Code Generation

AlgoQuest uses code generation during development, primarily through [`freezed`](https://pub.dev/packages/freezed), to reduce boilerplate and provide immutable data classes.

Generated source files are **not committed to the repository**, keeping the version history focused on manually maintained code.

After cloning the repository and installing the dependencies, generate the required files with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This is a **build-time requirement**. The project will not compile until the generated files have been created.

Code generation is only part of the development and build process; it does not introduce any additional runtime dependency or affect the application's runtime behavior.

When modifying an annotated model during development, generated files can be updated automatically with:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## App Icons

AlgoQuest uses [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) to generate platform-specific launcher icons.

The generated icons are based on the configuration defined in the `flutter_launcher_icons` section of `pubspec.yaml`.

To regenerate the icons, run:

```bash
dart run flutter_launcher_icons
```

This command updates the launcher icons for the enabled target platforms, such as Android, iOS, Web, Windows, and macOS.

Icon generation is not required to run the project after cloning the repository unless the source icon or its configuration has been changed.

## Platform-Specific Configuration

AlgoQuest applies different startup settings depending on the target platform.

### Android

On Android, the application:

- Locks the interface to portrait orientation.
- Enables immersive sticky mode to hide the system navigation and status bars while preserving gesture-based access to them.

This behavior is configured during application startup through Flutter's `SystemChrome` API.

### Desktop

On Windows, Linux, and macOS, the application uses `window_manager` to configure the desktop window.

The initial and minimum window size is:

```text
575 × 960 pixels
```

The window is also centered when the application starts.

These constraints are applied **only on desktop platforms** and are not initialized on Android or Web.

### Web

No platform-specific window or system UI configuration is currently applied when running the application on the Web.

## Running the Application

Install the project dependencies:

```bash
flutter pub get
```

Generate the required source files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run the application on an available device:

```bash
flutter run
```

To select a specific device, list the available targets:

```bash
flutter devices
```

Then run the application using the corresponding device identifier:

```bash
flutter run -d <device-id>
```

Examples:

```bash
flutter run -d windows
flutter run -d android
flutter run -d chrome
```

Platform-specific behavior is configured automatically during startup.
