# World Countries

A polished Flutter app to explore every country in the world — flags, capitals,
interactive maps, and geography quizzes. Runs on Android, iOS, web, and desktop.

## Features

- **249 countries**, fully offline: bundled JSON dataset and local flag assets
- **Smart list**: search by country *or* capital, filter by region chips,
  favorites with one tap (persisted across launches)
- **Country details**: hero flag, region/code/coordinates chips, and an
  interactive OpenStreetMap view with capital marker
- **Quizzes** — four modes, each 15 questions with region-aware distractors:
  - Capitals (multiple choice / typing)
  - Flags (multiple choice / typing)
  - Live score + progress bar, animated result ring, full answer review,
    and persisted best score per mode
- **Light & dark theme** with a persisted toggle
- **Self-contained web build**: CanvasKit and Roboto are served from the app's
  own origin — no CDN dependency, works offline as a PWA

## Getting started

```bash
flutter pub get
flutter test
flutter run
```

## Web deployment

Every push to `master` triggers `.github/workflows/deploy.yml`, which runs the
analyzer and tests, builds the release web bundle, and publishes it to GitHub
Pages.

One-time setup: in the repository settings, under **Pages**, set the source to
**GitHub Actions**. The app is then served at
`https://<user>.github.io/<repo>/`.

To build locally:

```bash
flutter build web --release --base-href "/<repo>/"
```

## Architecture

Feature-first clean architecture with Riverpod and go_router:

```
lib/
  core/            # theme, routing, storage
  features/
    countries/     # data (JSON asset repo) → domain (entities, use cases) → presentation
    quiz/          # question generation, session state machine, quiz screens
    navigation/    # app shell with bottom navigation
```

- The countries repository is asset-backed but sits behind a domain interface,
  so it can be swapped for an API later without touching presentation code.
- Quiz distractors prefer capitals/countries from the same region to keep
  questions challenging.

## Data & credits

- Country dataset: bundled at `assets/data/countries.json`
- Flags: bundled PNGs under `assets/flags/`
- Map tiles: © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors
- Roboto font: Apache License 2.0
