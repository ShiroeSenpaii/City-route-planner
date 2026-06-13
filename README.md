# Hearthlands Routebuilder

A mobile-first Godot 4.x GDScript prototype for a portrait Android settlement route-building game.

## Build in GitHub Actions

Open the repository on GitHub, choose **Actions**, select **Build Android APK**, and press **Run workflow**. The workflow also runs automatically on pushes to `main` or `master`.

When the run completes, download the artifact named **android-apk**. It contains `HearthlandsRoutebuilder-debug.apk`, a debug-signed Android APK for device testing.

## Caveats

- This is an intentionally ugly MVP using placeholder shapes and a text-based SVG placeholder icon so the repository contains no binary asset files.
- The cloud export uses Godot 4.2.2 stable export templates and a generated debug keystore.
- If GitHub changes runner images or Android tooling paths, the workflow may need small maintenance updates.
