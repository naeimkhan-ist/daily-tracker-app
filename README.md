# Daily Tracker

A study & productivity daily tracker built with Flutter — tasks, study sessions, daily streaks and weekly analytics, backed by Supabase (Postgres + Auth) with Google Sign-In.

## Status

Work-in-progress, built screen by screen. Current state:

- [x] Project scaffold, theme, routing, Supabase client wiring
- [x] Supabase schema (`profiles`, `subjects`, `tasks`, `study_sessions`, `daily_checkins`, `settings`) with row-level security
- [x] Screen: Splash
- [x] Screen: Login (Google via Supabase Auth)
- [x] Screen: Home dashboard (daily challenge, week streak, available hours, today's tasks)
- [x] Screen: Add task (bottom sheet — title, subject, due date, priority)
- [x] Screen: Log study session (bottom sheet — duration presets + subject)
- [x] Screen: Analytics (weekly minutes chart, days-on-track, study time, per-subject breakdown)
- [x] Screen: Subjects/Categories (grid + add-subject dialog)
- [x] Screen: Settings (profile, daily reminder toggle + time, sign out)
- [x] Bottom-nav shell (Home / Analytics / Subjects / Settings)
- [x] Web build → Vercel (PWA) — live at https://daily-tracker-app-nklab.vercel.app
- [ ] Android build (APK) — workflow committed, waiting on the GitHub push (see below)
- [ ] Google OAuth provider enabled in the Supabase dashboard (manual step, credentials supplied by the user)
- [ ] Push to GitHub — blocked from the dev sandbox by a git-proxy repo-authorization restriction; see the zip delivered to the user with 2-command push instructions

## Tech stack

- Flutter (Material 3), Riverpod, go_router
- Supabase (Postgres, Auth, Row-Level Security)
- fl_chart for analytics
- Deployed as a PWA on Vercel; Android APK built separately

## Getting started locally

Requires the Flutter SDK (stable channel) installed locally.

```bash
flutter pub get

# generate platform folders (first time only, if not already present)
flutter create --org com.naeimkhan --platforms=web,android .

flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://elngxguxdbslcsuulnlg.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-or-publishable-key-from-supabase-dashboard>
```

The same two `--dart-define` values are stored as Vercel project environment variables (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) and consumed by `vercel.json`'s build command, which installs Flutter fresh on each Vercel build (Vercel's build machines have full internet access) and runs `flutter build web`.

## Supabase

- Project ref: `elngxguxdbslcsuulnlg`
- Google OAuth must be enabled under Authentication → Providers, with the redirect URL(s) for web + the Android deep link added once those are configured.
- Every table has RLS enabled with a `user_id = auth.uid()` policy — no user can see another user's data.
