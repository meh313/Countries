# Countries App

A Flutter mobile app that lists countries with their flags and opens a map-focused detail view for each country.

## Features

- Offline country dataset bundled as JSON
- Country list with search
- Country details with an interactive OpenStreetMap view
- Placeholder route for a future capitals quiz mode

## Setup

1. Install Flutter on Windows and ensure `flutter` is on `PATH`.
2. From this folder, run:

```powershell
flutter create .
flutter pub get
flutter test
flutter run
```

## Notes

- The repository is asset-backed today, but the app structure allows swapping to an API or backend later.
- Flags are loaded from `flagcdn.com` URLs defined in the local JSON dataset.
