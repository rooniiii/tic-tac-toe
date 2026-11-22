# NEON XO – Tic-Tac-Toe Game

A neon-styled tic-tac-toe game for Android, built with Flutter and Firebase.
It has a companion admin app, **NEON XO Admin** (`tic-tac-toe-admin`), that
uses the same Firebase project.

> Screenshots: add images to `docs/screenshots/` and link them here.

## Features

- Sign up with name, email, phone and password (with a password checklist)
- Email verification and password reset
- Login with email and password, with a temporary lock after wrong attempts
- Offline login after one successful online login
- Play against the computer (several difficulty levels) or a friend on the same phone
- Hints, undo, and an extra undo for watching a rewarded ad
- Personal statistics and best score
- **Global online leaderboard** (top 20) next to personal stats
- Edit your bio
- Sound effects and a voice assistant that reads out game updates
- Tutorial and FAQ
- **Delete my account** (Settings), which removes all of your data
- Blocked accounts are signed out immediately and cannot log in

## Tech stack

| Part | Used for |
|---|---|
| Flutter / Dart | App |
| Firebase Authentication | Email + password login |
| Cloud Firestore | Profiles, stats, game history, leaderboard |
| Drift (SQLite) | Offline login data and local stats |
| shared_preferences | Settings and small flags |
| Google Mobile Ads | Rewarded ads |
| flutter_tts / audioplayers | Voice assistant and sounds |

## Project structure

```
lib/
  main.dart                     App start, global "account blocked" handler
  database/                     Drift (SQLite) database
  logic/
    auth_service.dart           Sign-up, login, session restore, delete account
    auth/
      password_hasher.dart      PBKDF2 hashing of passwords stored on the device
      login_attempt_limiter.dart  Temporary lock after wrong passwords
      offline_credentials_store.dart  Offline login data and "blocked" flag
    game_logic.dart             Win / draw detection
    profile_service.dart        Bio and local stats
  services/
    account_status_service.dart Detects when an admin blocks the account
    firestore_sync_service.dart Saves game results to Firestore
    leaderboard_service.dart    Global leaderboard
  screens/ widgets/ models/ theme/
firestore.rules                 Security rules (shared with the admin app)
```

## Setup

1. Install Flutter (Dart SDK 3.8 or newer).
2. `flutter pub get`
3. The Firebase config for project `tic-tac-toe-4ab92` is already in
   `lib/firebase_options.dart` and `android/app/google-services.json`.
4. In the Firebase console, enable **Authentication → Email/Password**.
5. Publish the security rules: paste `firestore.rules` into
   **Firestore → Rules**, or run
   `firebase deploy --only firestore:rules`.
   (Do not run plain `firebase deploy`: the `functions` folders are empty
   templates and cannot be deployed on the free Spark plan.)
6. `flutter run`

## Firestore data model

| Collection | Document ID | Contents | Written by |
|---|---|---|---|
| `users` | player UID | name, email, phone, isBlocked, status | game (sign-up), admin |
| `player_stats` | player UID | gamesPlayed, wins, losses, draws | game |
| `game_history` | auto | player, opponent, difficulty, result, time | game |
| `user_profiles` | player UID | bio | game, admin |
| `leaderboard` | player UID | name and totals (public, no email) | game, admin |
| `admins` | admin UID | role, name, email | admin app |
| `admin_logs` | auto | admin action history | admin app |
| `deleted_users` | player UID | marker for deleted players | admin app |

## Design notes

**Blocking players without a paid plan.** Firebase can only disable a
login from a server (Cloud Functions or the Admin SDK), which needs the
paid Blaze plan. This project stays on the free Spark plan, so blocking
works in three layers instead:

1. The admin app sets `isBlocked: true` on the player's `users` document.
2. **Security rules** (checked on Firebase's servers, so they cannot be
   bypassed by changing the app) reject every write from a blocked player,
   and stop players from changing their own block fields.
3. **The game** listens to the player's profile, so a block signs the player
   out immediately with a message. It also checks at login and on app start,
   and removes the saved offline login from the phone.

**Leaderboard that cannot be faked.** `player_stats` contains emails, so it
stays private. Each player also has a public `leaderboard` entry, and the
rules only accept it if its numbers are exactly equal to the player's real
`player_stats`. The rules also only allow stats to grow by one game at a
time.

**Offline passwords.** The password copy used for offline login is stored
as a PBKDF2-HMAC-SHA256 hash (10,000 rounds, random salt). Hashes from older
versions (single SHA-256) are upgraded automatically at the next login.

## Known limitations

- Game results are calculated on the phone. The rules limit what can be
  sent (one game at a time, valid results only), but a modified app could
  still report fake wins.
- A blocked player who stays offline can keep playing locally until the
  phone reconnects. Nothing they do offline reaches Firebase.
- When an admin deletes a player, the Firebase login itself stays (it is
  useless without a profile) and can be removed by hand in Firebase
  console → Authentication. When players delete their own account, the
  login is removed too.
- App Check uses the debug provider, which is fine for development but
  gives no protection in a release build.
- Only Android is configured.
