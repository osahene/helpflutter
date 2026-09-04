# helpflutter

Mobile client for HelpOoHelp — Flutter (BLoC) app talking to the same
Django backend as the `helpnext` web app.

## Configuration

`lib/core/constants/api_client.dart` reads two values via Dart's
compile-time `--dart-define`:

| Variable | Default when omitted | Notes |
|---|---|---|
| `BASE_URL` | `https://emergencysystem.onrender.com` (production) | Safe to omit — a build with no flags at all still reaches production. |
| `FRONTEND_API_KEY` | *(none — required)* | Must match the backend's `FRONTEND_API_KEY` exactly. Missing it fails loudly at app startup (`ApiClient.assertConfigured`) rather than silently sending a broken request. |

**Local development against a local backend:** copy `.env.example` to
`.env` (already gitignored), fill in the real key, then:

```sh
flutter run --dart-define-from-file=.env
```

**Release builds:**

```sh
flutter build apk --release --dart-define=FRONTEND_API_KEY=<the real key>
flutter build ipa --release --dart-define=FRONTEND_API_KEY=<the real key>
```

Get the real key from the team/password manager — never hardcode it in
source or commit it in `.env`. See the comment on `ApiClient.apiKey` for why
this key isn't (and can't be) a true secret for a mobile client, and what
actually protects the backend instead (the user's JWT, per-endpoint
throttling).

Android release builds also need a real upload keystore — copy
`android/key.properties.example` to `android/key.properties` and follow the
instructions in that file. Without it, `flutter build apk --release` falls
back to debug signing (fine for local testing, not for Play Store upload).

## Development

```sh
flutter pub get
flutter analyze
flutter test
```

## Architecture

- **State management:** `flutter_bloc` — one BLoC per feature under
  `lib/logic/`, backed by a `Repository` interface + implementation under
  `lib/data/repositories/`.
- **Networking:** a single shared `Dio` instance (`ApiClient`), with an
  interceptor that attaches the access token, and de-dupes concurrent 401s
  onto a single in-flight refresh call.
- **Session storage:** `flutter_secure_storage` (platform keychain/keystore,
  not SharedPreferences) for tokens and the cached user.
- **Push notifications:** Firebase Cloud Messaging + `flutter_local_notifications`
  (`lib/core/services/push_service.dart`), including a dedicated
  full-screen-intent channel for incoming emergency alerts. Degrades
  gracefully to a no-op if Firebase isn't available.
