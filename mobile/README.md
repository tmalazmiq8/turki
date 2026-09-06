# MIYAR — mobile (iOS + Android)

Cross-platform rebuild of the MIYAR app (Expo / React Native), sharing the
exact same Supabase project as the native Swift app in `../ios-miyar`. An
account created in either app works in both.

## Run it on your phone (no Mac, no Xcode, no signing)

1. Install **Expo Go** from the App Store (iPhone) or Play Store (Android).
2. On your computer:
   ```bash
   cd mobile
   npm install
   npx expo start
   ```
3. A QR code prints in the terminal. Scan it with your phone's camera
   (iPhone) or the Expo Go app itself (Android).
4. The app opens live on your phone. Any code change hot-reloads instantly —
   no rebuild step.

Your phone and computer must be on the **same Wi-Fi network**. If it can't
connect, run `npx expo start --tunnel` instead (slower, but works across
different networks/firewalls).

## What's implemented

- Sign up / sign in / sign out / password reset (Supabase Auth)
- Home, Materials library (30 seeded materials), IFRA safety section with a
  link to IFRA's official searchable Standards Library, Account/Settings
- Bilingual Arabic/English strings, matching the Swift app's visual identity
  (colors, logo, wording)

## Not yet ported from the Swift app

Formula calculator, marketplace, community feed, AI assistant. The
foundation (theme, strings, Supabase client, navigation shell) is in place
to add these incrementally — ask for any of them by name.

## Project layout

```
src/
  app/            expo-router screens (file-based routing)
    (auth)/       welcome, sign-in, sign-up, reset-password
    (tabs)/       home, materials, ifra, account
    material/     material detail screen
  components/     shared UI (Screen, Card, buttons, Field, Banner)
  context/        language + auth React contexts
  data/           seeded materials + IFRA defaults
  lib/            theme, strings, Supabase client, IFRA constants
  types/          shared TypeScript types
```
