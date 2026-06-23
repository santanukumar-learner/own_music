# Sonata — Offline-First Personal Music Player with On-Device AI Recommendations

A polished, dark, AMOLED-friendly Android music player (Flutter) that deeply
understands every song already on your device, enriches missing metadata from the
web, then autoplays the next best local song using a **content-based + listening-history
hybrid recommender** — no streaming subscription required.

> Personal app. Not for store submission. Single user, no auth. All audio stays
> on the device; only metadata is fetched from the web (and cached locally).

---

## Architecture decisions (locked for this build)

| Area | Decision | Why |
|------|----------|-----|
| AI engine placement | **Hybrid** | Recommender (cosine ANN + Dart ALS) and genre/mood (ONNX Runtime) run **on-device** for fully offline playback. A small **LAN Python service** handles only the inherently-online enrichment (AcoustID fingerprint, librosa BPM/key, cover art). |
| Local DB | **`isar_community` 3.3.2** | Stock `isar` 3.1.0 caps at Dart SDK `<3.0.0` and cannot resolve on a modern toolchain. The community fork is an API-compatible, Dart-3 drop-in (same `@collection` codegen). |
| Color extraction | **`palette_generator`** | The spec named `palette_dart`, which does not exist on pub.dev. |
| Visualizer | **`audio_visualizer`** (or CustomPainter) | The spec named `flutter_visualizers`, which is stale (pre-Dart-3). |
| Background audio | **`audio_service` + `just_audio`** | `just_audio_background` has no stable release; `audio_service` is the stable, full-control path the spec already lists. |

All other packages match the spec. Versions are **exact-pinned** in
[`pubspec.yaml`](pubspec.yaml) (verified on pub.dev 2026-06-23).

---

## Prerequisites (install these first)

This machine currently has Python 3.12 and Git, but **not** Flutter / Dart / JDK /
Android SDK. Install the mobile toolchain before building:

1. **Flutter SDK (stable channel)** — https://docs.flutter.dev/get-started/install/windows
   - Unzip to e.g. `C:\src\flutter` and add `C:\src\flutter\bin` to your PATH.
   - Needs a recent stable (Dart ≥ 3.10). Verify: `flutter --version`.
2. **JDK 17** — bundled with Android Studio, or install Temurin 17. Set `JAVA_HOME`.
3. **Android SDK** — easiest via **Android Studio** (includes SDK, platform-tools,
   emulator). Then:
   ```powershell
   flutter doctor --android-licenses   # accept all
   flutter doctor                       # should be all green for Android
   ```

### Optional: Python LAN enrichment service (deliverable 3)
The on-device app runs fully without it; you only need it during the first
enrichment pass for fingerprinting + audio-feature extraction. It will live in
`service/` with its own `requirements.txt` (acoustid/chromaprint, librosa,
onnxruntime, implicit, hnswlib, MusicBrainz client).

---

## One-time setup

Flutter ships a few **binary** scaffolding files that can't be stored as source
text (launcher icons + the Gradle wrapper jar). Generate them once into a scratch
project and copy them in — this does **not** touch any of the authored files in
this repo:

```powershell
# from the project root: c:\Users\santa\Desktop\Music_recommender_system
flutter create --platforms=android --org com.helprevx --project-name music_recommender scratch_app

# copy only the binaries this repo intentionally omits:
Copy-Item -Recurse scratch_app\android\app\src\main\res\mipmap-* android\app\src\main\res\
Copy-Item scratch_app\android\gradlew, scratch_app\android\gradlew.bat android\
Copy-Item -Recurse scratch_app\android\gradle\wrapper\gradle-wrapper.jar android\gradle\wrapper\

Remove-Item -Recurse -Force scratch_app
```

Then fetch dependencies and run:

```powershell
flutter pub get
flutter run            # on a connected device / emulator (API 26+)
```

> `local.properties` (Flutter SDK path) is generated automatically on first build
> and is git-ignored.

When code generation is added (Isar collections — deliverable 2+; Riverpod uses
the manual AsyncNotifier API, no codegen):

```powershell
dart run build_runner build --delete-conflicting-outputs
```

---

## Project structure

```
music_recommender_system/
├── pubspec.yaml                 # exact-pinned deps (deliverable 1)
├── analysis_options.yaml        # lints + strict casts
├── .gitignore
├── README.md
├── lib/
│   └── main.dart                # app entry, Material 3 dark / true-black theme
├── android/
│   ├── settings.gradle          # AGP 8.7.3 · Kotlin 2.1.0 · Flutter plugin loader
│   ├── build.gradle
│   ├── gradle.properties        # AndroidX, JVM args
│   ├── gradle/wrapper/gradle-wrapper.properties   # Gradle 8.9
│   └── app/
│       ├── build.gradle         # minSdk 26 · compileSdk/targetSdk 35 · arm64 ABI · Java 17
│       ├── proguard-rules.pro   # keep rules (used only if R8 enabled)
│       └── src/main/
│           ├── AndroidManifest.xml          # permissions + audio_service + WorkManager
│           ├── kotlin/com/helprevx/music_recommender/MainActivity.kt
│           └── res/values{,-night}/styles.xml, res/drawable*/launch_background.xml
└── service/                     # Python LAN enrichment service (deliverable 3, TBD)
```

Planned `lib/` layout for later deliverables: `lib/data` (Isar collections,
repositories), `lib/ml` (HNSW index, ALS trainer, ONNX runner, feature extractor),
`lib/services` (audio handler, WorkManager tasks, enrichment client),
`lib/features/<screen>` (Riverpod providers + UI), `lib/theme`.

---

## Permissions (declared in the manifest)

`READ_MEDIA_AUDIO` (API 33+) / `READ_EXTERNAL_STORAGE` (≤ API 32),
`FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `WAKE_LOCK`,
`POST_NOTIFICATIONS` (API 33+), `RECEIVE_BOOT_COMPLETED` (WorkManager),
`INTERNET` + `ACCESS_NETWORK_STATE` (enrichment + LAN service).

`usesCleartextTraffic="true"` is set only so the app can reach the
HTTP enrichment service on your local network. **Audio is sent only to your own
LAN service** (for fingerprinting + librosa feature extraction), where it is
deleted immediately after processing — never to any cloud or third party. Only
content fingerprints and text queries reach AcoustID / MusicBrainz / Last.fm.

---

## API keys (added in the Settings screen — deliverable 9)

- **MusicBrainz / Cover Art Archive** — free, no key (1 req/sec rate limit honored).
- **AcoustID** — free application key (3 req/sec).
- **Last.fm**, **Discogs** — optional fallbacks; keys entered in Settings, stored
  locally via `shared_preferences`.

---

## Build size note (target < 80 MB)

`app/build.gradle` restricts native libs to `arm64-v8a` and the ONNX model is
fetched at runtime (not bundled). Add other ABIs in `defaultConfig.ndk.abiFilters`
if you need 32-bit or emulator (`x86_64`) builds.

---

## ⚠️ Repository note

The folder `C:\Users\santa` (your home directory) is itself a Git repository, so
this project currently sits *inside* that repo. Before committing project history,
give Sonata its own repo:

```powershell
cd c:\Users\santa\Desktop\Music_recommender_system
git init
git add .
git commit -m "Deliverable 1: project scaffold"
```

(Not done automatically — flagged so project commits don't land in your home-dir repo.)

---

## Deliverables roadmap

1. ✅ **Project scaffold + pinned `pubspec.yaml` + Android config**
2. ✅ **Isar schema (5 collections + indices)** — `lib/data/`
3. ✅ **Python enrichment service** (acoustid / musicbrainz / genre-mood ONNX / features) — `service/`
4. ✅ **Dart ↔ service enrichment bridge** — `lib/enrichment/` (client, contract models, 134-d feature vector) + `lib/data/song_repository.dart` + settings (service URL)
   - Plus: basic on-device player (scan/list/play/mini-player) confirmed working on device.
5. ⬜ WorkManager tasks (LibraryScan / MetadataEnrichment / ModelRetrain)
6. ✅ **Recommender core** — `lib/recommender/` cosine similarity + content ranking + context re-rank (time-of-day energy, last-2h suppression, thumb boost/penalty, genre diversity). 16/16 unit tests pass.
   - NOTE: uses **brute-force cosine** (sub-ms for a personal library) rather than HNSW/hnswlib — that's a Python/C++ lib with no Dart binding, and ANN is unnecessary at personal scale. Revisit only if a library exceeds ~50k tracks.
7. ⬜ ALS trainer + inference (collaborative, from play history)
8. ⬜ `RecommenderService.getNextSong()` wiring (blend + cache) + autoplay
   - Remaining for a live on-device demo: settings field for the service URL, scan→enrich orchestration (deliverable 5), autoplay-on-complete.
9. ⬜ All 6 screens + Riverpod providers
10. ⬜ "Why this song?" explainability sheet
11. ⬜ Background audio service (lock screen / notification / headset)
12. ⬜ README polish + setup walkthrough
