## Code Generation

This project uses code generation during development (via `freezed`) to reduce boilerplate and enforce immutability.

Generated files are **not committed to the repository** in order to keep the version control history clean and focused on handwritten source code.

After cloning the repository, please run the following command to generate the required files:

```bash
dart run build_runner build
```

This is a **build-time requirement**: the project will not compile until the generated files are created.
However, code generation does **not affect the runtime behavior** of the application.
