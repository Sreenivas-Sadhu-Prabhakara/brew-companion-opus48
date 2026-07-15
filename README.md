# Filter Coffee Brew Companion

An offline-first Android app for South Indian filter-coffee lovers: a **ratio
calculator**, a **guided brew timer**, and a **bean & tasting log** — all stored on the
device, no account, no network.

Built in a single Claude Code session (Claude Opus 4.8) as the Opus arm of the
[Opus 4.8 vs GPT 5.6 Sol — brief-to-`.aab`](https://github.com/Sreenivas-Sadhu-Prabhakara/claude-experimentation-guide)
experiment. The shared build brief and grading rubric live in that repo.

## Features

- **Ratio** — pick a method (South Indian Filter, Pour Over, French Press, Moka), solve
  water-from-dose or dose-from-water, a strength slider, and quick-cups fill.
- **Timer** — per-method staged recipe with countdown, progress ring, next-stage preview,
  start / pause / skip / reset, and haptics on each stage change.
- **Log** — persistent brew history with method, bean, roast, grind, dose, yield (auto
  ratio), a 0–5 rating, flavour tags and notes. Add / edit / delete, summary stats.
- **Settings** — default method, default strength, cup size, theme (system/light/dark),
  clear-all-data.

## Stack

- Flutter (stable), Dart `^3.11`
- One third-party runtime dependency: `shared_preferences` (device-local JSON persistence)
- State: a single `ChangeNotifier` store surfaced through an `InheritedNotifier`

## Run

```bash
flutter pub get
flutter run          # debug on a device/emulator
flutter analyze      # expect: No issues found!
flutter test         # expect: All tests passed!
```

## Build a signed release bundle

Signing is externalised so no secret is committed. `android/key.properties` and the
keystore are git-ignored.

```bash
# 1. one-time: create an upload keystore
keytool -genkeypair -v -keystore android/app/upload-keystore.jks \
  -alias upload -keyalg RSA -keysize 2048 -validity 10000

# 2. android/key.properties
#    storePassword=...
#    keyPassword=...
#    keyAlias=upload
#    storeFile=upload-keystore.jks

# 3. build the App Bundle
flutter build appbundle --release
# -> build/app/outputs/bundle/release/app-release.aab

# 4. verify it is properly signed
jarsigner -verify build/app/outputs/bundle/release/app-release.aab   # -> jar verified.
```

The release build is minified and resource-shrunk (R8) with Flutter keep-rules in
`android/app/proguard-rules.pro`. The `.aab` bundles the `arm64-v8a`, `armeabi-v7a` and
`x86_64` ABIs; Google Play splits it per-device on download.

## Privacy

Everything is stored on the device via `shared_preferences`. No network calls, no
analytics, no account. Uninstalling the app removes all data.
