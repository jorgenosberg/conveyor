<p align="center">
  <img src="docs/header.webp" alt="Conveyor" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/github/license/jorgenosberg/conveyor?style=flat-square" alt="License" />
  <img src="https://img.shields.io/github/last-commit/jorgenosberg/conveyor?style=flat-square" alt="Last commit" />
</p>

A companion app for [Satisfactory](https://www.satisfactorygame.com/). Browse items, look up recipes and their alternates, and sketch out production chains.

Fan project, not affiliated with Coffee Stain Studios.

## Status

Item browser, recipe browser, and a rough production graph work. Factory planning and optimization are the reason I started this, but they aren't built yet.

## Running it

You'll need the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.9.2`).

```bash
flutter pub get
flutter run
```

Builds to iOS, Android, web, macOS, Windows, and Linux via `flutter build <platform>`. I mostly develop against the iOS simulator, so the other platforms may have rough edges.

```bash
flutter analyze
flutter test
dart format .
```

## Game assets

All item/building/recipe data in `assets/data/` and icons in `assets/images/` come from Satisfactory and belong to Coffee Stain Studios. I don't own any of it — it's here so the app is useful. If anyone from Coffee Stain wants something removed, open an issue and I'll take it down.

## License

Code is MIT (see [`LICENSE`](./LICENSE)). That license covers the source only, not the game assets under `assets/`.
