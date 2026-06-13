# Android cloud build

This project is intended to be built through GitHub Actions, so no local Godot desktop editor is required.

## Triggering the workflow

1. Open the repository on GitHub.
2. Go to **Actions**.
3. Select **Build Android APK**.
4. Press **Run workflow**.

The workflow also runs automatically on pushes to `main` or `master`.

## Downloading the APK

When the workflow finishes, open the completed run and download the artifact named **android-apk**. It contains:

- `HearthlandsRoutebuilder-debug.apk`

## Caveats

- The APK is debug-signed for phone testing only.
- The repository uses a text-based SVG placeholder icon to avoid binary art files.
- The GitHub runner downloads Godot 4.2.2 and its export templates during the workflow.
