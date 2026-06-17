## Code Generation

This project uses code generation during development (via `freezed`) to reduce boilerplate and enforce immutability.

Generated files are **not committed to the repository** in order to keep the version control history clean and focused on handwritten source code.

After cloning the repository, please run the following command to generate the required files:

```bash
dart run build_runner build
```

This is a **build-time requirement**: the project will not compile until the generated files are created.
However, code generation does **not affect the runtime behavior** of the application.

## App Icons

To generate the app icons for all platforms (Android, iOS, Web, Windows, and macOS), run:

```bash
dart run flutter_launcher_icons
```

This command generates platform-specific launcher icons based on the configuration in `pubspec.yaml`. The icons are generated from the source image specified in the `flutter_launcher_icons` section.
