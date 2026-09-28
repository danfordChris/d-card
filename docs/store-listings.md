# Store listings and testing tracks

> Task: `docs/implementation/tasks/t06-09-store-listings.md`. Deployment overview: `docs/deployment.md`.
> Privacy basis: `docs/design/features/privacy-and-audit.md`. Last checked: 2026-09-27.

Listing text, privacy answers and release checklists for the two Flutter apps. Store accounts, signing keys and every submission are done by the owner. Nothing here is submitted automatically.

## Apps at a glance

| | D-Card (`apps/mobile`) | D-Card Door (`apps/door`) |
|---|---|---|
| Users | Hosts, treasurers, committee, walk-in approvers; guests (optional sign-in) | Door staff at the event entrance |
| Android application id | `tz.dcard.dcard_mobile` | `tz.dcard.dcard_door` |
| iOS bundle id | `tz.dcard.dcardMobile` | `tz.dcard.dcardDoor` |
| Version (pubspec) | `0.1.0+1` | `0.1.0+1` |
| Launcher name | D-Card | D-Card Door |
| iOS minimum | 15.0 (required by `firebase_auth`) | 15.0 |
| Android min/target SDK | Flutter defaults (`flutter.minSdkVersion` / `targetSdkVersion`) | Same |
| Privacy policy URL | https://dcard.danfordchris.dev/privacy | https://dcard.danfordchris.dev/privacy |
| Support contact | `<OWNER: support email>` · `<OWNER: WhatsApp/phone, 255XXXXXXXXX>` | Same |
| Website | `<OWNER: marketing site URL>` | Same |

Version bumps: change `version:` in each `pubspec.yaml` (`x.y.z+build`). The build number must increase on every upload to Play or App Store Connect.

Build defines (from `apps/*/README.md` and `docs/deployment.md`): every store build needs `--dart-define` values for `API_BASE_URL` (`https://api.dcard.danfordchris.dev`), `API_KEY` (the `mobile:` or `door:` entry of the server's `API_KEYS`) and the Firebase options (`FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, one Firebase app per platform). Keep them in a local, gitignored file and pass it with `--dart-define-from-file`. Never commit them.

---

## 1. D-Card (apps/mobile)

### Name

| | English | Swahili |
|---|---|---|
| App name (≤ 30) | D-Card: Event Invitations | D-Card: Kadi za Mialiko |
| Short description (≤ 80) | Digital invitation cards, contributions and guest lists for your event. | Kadi za mialiko kidijitali, michango na orodha ya wageni kwa tukio lako. |

### Full description — English

```
D-Card helps you run invitations for weddings, send-offs, kitchen parties and other events in Tanzania.

For hosts and committees
- Create an event and add guests from your phone contacts or one by one.
- Send each guest a digital invitation card by WhatsApp or SMS. Guests without a smartphone receive an SMS with a card number.
- Record pledges and contributions, and see who has paid and how much remains.
- Follow confirmations: who is coming and how many people.
- Approve or decline walk-in requests from the door during the event.
- Pay for your guest cards with mobile money (M-Pesa, Airtel Money, Mixx by Yas, HaloPesa).

For guests
- Sign in with Google or Apple to keep all your invitation cards in one place.
- Open your card and its QR code at the entrance, and answer whether you will attend.
- Download your data or delete your account at any time.

At the entrance, door staff use the separate D-Card Door app to scan cards.

Privacy
Guests who do not sign in are anonymised two weeks after the event. Event photos and videos stay in the host's own Google Drive. Read the privacy policy: https://dcard.danfordchris.dev/privacy

The app is available in Swahili and English.
```

### Full description — Swahili

```
D-Card inakusaidia kusimamia mialiko ya harusi, send-off, kitchen party na matukio mengine Tanzania.

Kwa wenyeji na kamati
- Tengeneza tukio na ongeza wageni kutoka kwenye namba za simu yako au mmoja mmoja.
- Tuma kadi ya mwaliko kidijitali kwa kila mgeni kupitia WhatsApp au SMS. Wageni wasio na simu janja wanapokea SMS yenye namba ya kadi.
- Rekodi ahadi na michango, na uone nani amelipa na kiasi kilichobaki.
- Fuatilia uthibitisho: nani anakuja na watu wangapi.
- Kubali au kataa maombi ya wageni wasio na kadi kutoka mlangoni wakati wa tukio.
- Lipia kadi za wageni kwa pesa za simu (M-Pesa, Airtel Money, Mixx by Yas, HaloPesa).

Kwa wageni
- Ingia kwa Google au Apple ili kadi zako zote za mwaliko ziwe sehemu moja.
- Fungua kadi yako na QR code yake mlangoni, na jibu kama utahudhuria.
- Pakua taarifa zako au futa akaunti yako wakati wowote.

Mlangoni, wahudumu wanatumia programu tofauti ya D-Card Door kuskani kadi.

Faragha
Wageni wasioingia kwenye akaunti wanafichwa taarifa zao wiki mbili baada ya tukio. Picha na video za tukio zinabaki kwenye Google Drive ya mwenyeji. Soma sera ya faragha: https://dcard.danfordchris.dev/privacy

Programu inapatikana kwa Kiswahili na Kiingereza.
```

(≈ 1,200 characters each; limit 4,000.) Check the mobile-money list against the Snippe providers enabled at launch before publishing.

### Keywords and category

- Apple keywords (≤ 100 chars, comma-separated, en): `invitation,wedding,harusi,mwaliko,kadi,michango,send-off,guest list,RSVP,event,contribution`
- Apple keywords (sw localisation): `mwaliko,kadi,harusi,michango,sherehe,send-off,kitchen party,wageni,tukio,ahadi`
- Apple category: primary **Lifestyle**, secondary **Productivity**.
- Google Play category: **Events**. Tags: Event planning, Invitations.
- Content rating: answer the IARC questionnaire with no violence, no user-to-user public content, no gambling → expected rating Everyone / 4+.
- Target audience (Play): 18+ (hosts pay and manage personal data of others). Not designed for children.

---

## 2. D-Card Door (apps/door)

### Name

| | English | Swahili |
|---|---|---|
| App name (≤ 30) | D-Card Door: Event Check-in | D-Card Door: Mapokezi Mlangoni |
| Short description (≤ 80) | Scan D-Card invitations at the entrance, online or offline. | Skani kadi za mwaliko za D-Card mlangoni, ukiwa na mtandao au bila. |

### Full description — English

```
D-Card Door is the check-in app for events that use D-Card invitation cards. It is for door staff invited by the event host.

- Sign in with the account the host invited, choose the event and name this phone's gate (for example "Gate 1").
- Scan the QR code on a guest's card with the camera, type the card number from an SMS card, or search by name.
- See at once whether the card is valid, already used, or for how many people.
- Keeps working without internet: the guest list is stored encrypted on the phone and check-ins sync when the connection returns.
- Send walk-in requests for people without a card; the host or an approver answers from the D-Card app.

The host can see every check-in and can revoke a door phone at any time.

Guests do not need this app. Hosts manage their event in the D-Card app or on the web.

Privacy policy: https://dcard.danfordchris.dev/privacy
The app is available in Swahili and English.
```

### Full description — Swahili

```
D-Card Door ni programu ya kupokea wageni mlangoni kwa matukio yanayotumia kadi za mwaliko za D-Card. Ni kwa wahudumu wa mlangoni walioalikwa na mwenyeji wa tukio.

- Ingia kwa akaunti uliyoalikwa nayo na mwenyeji, chagua tukio na lipe jina geti la simu hii (mfano "Geti 1").
- Skani QR code kwenye kadi ya mgeni kwa kamera, andika namba ya kadi kutoka SMS, au tafuta kwa jina.
- Ona papo hapo kama kadi ni halali, imeshatumika, au ni ya watu wangapi.
- Inafanya kazi bila mtandao: orodha ya wageni inahifadhiwa kwa usimbaji fiche kwenye simu na mapokezi yanasawazishwa mtandao ukirudi.
- Tuma maombi ya wageni wasio na kadi; mwenyeji au mwidhinishaji anajibu kutoka programu ya D-Card.

Mwenyeji anaona kila mapokezi na anaweza kuzuia simu ya mlangoni wakati wowote.

Wageni hawahitaji programu hii. Wenyeji wanasimamia tukio lao kwenye programu ya D-Card au kwenye wavuti.

Sera ya faragha: https://dcard.danfordchris.dev/privacy
Programu inapatikana kwa Kiswahili na Kiingereza.
```

### Keywords and category

- Apple keywords (en): `check-in,QR scanner,event,door,guest list,invitation,ticket,entrance,wedding,offline`
- Apple keywords (sw): `mlangoni,mapokezi,skani,QR,kadi,mwaliko,harusi,wageni,tukio,geti`
- Apple category: primary **Business**, secondary **Utilities**.
- Google Play category: **Events** (alternative: Business).
- Content rating: Everyone / 4+. Target audience: 18+.
- Both stores: the app needs an invited account. Give reviewers a demo account (see checklists).

---

## 3. What the apps collect (from the code, 2026-09-27)

| Data | D-Card | D-Card Door | Where it goes | Code |
|---|---|---|---|---|
| Email address | Hosts/team sign in with email + password; guests' Google/Apple email | Door staff email + password | Firebase Auth, D-Card API | `apps/*/lib/data/services/firebase_auth_service.dart` |
| Name | Google/Apple profile name (guests); names of guests the host adds | Gate name the staff gives the phone | D-Card API | `door_device_store.dart` |
| User ID | Firebase UID | Firebase UID | Firebase, D-Card API | |
| Phone numbers | Host's mobile-money number at checkout; guests' numbers (added by the host) | — (sees guest names/card data for the event) | D-Card API; checkout number to Snippe for the USSD push | `billing/views/checkout_screen.dart` |
| Contacts | Only contacts the host picks in the picker (name + numbers); read on request, not uploaded in bulk | — | D-Card API (bulk add with host's consent checkbox) | `contacts/…`, `data/services/contacts_source.dart`, `READ_CONTACTS` / `NSContactsUsageDescription` |
| Payment info | Amounts and receipts; mobile-money payment happens through Snippe (no card or wallet PIN in the app) | — | Snippe, D-Card API | `billing/` |
| Contributions (financial records) | Pledges and payments recorded by treasurers | — | D-Card API | `contributions/` |
| Camera | — | QR scanning only, frames not stored or sent | On device | `check_in/views/qr_scanner_view.dart`, `NSCameraUsageDescription` |
| Push token / device ID | FCM token | FCM token; per-event door device ID | Firebase Cloud Messaging, D-Card API | `data/services/push_token_source.dart`, `door_device_store.dart` |
| On-device storage | `shared_preferences` (session, settings); data export saved to a file the user chooses | Encrypted SQLite (`sqflite_sqlcipher`) guest cache, key in `flutter_secure_storage` | Device | |
| App activity | Actions are audited server-side (logins, check-ins, edits) | Every check-in attempt audited | D-Card API | `privacy-and-audit.md` |
| Crash data | Not yet. Sentry is planned (T06-06); update both forms when it ships | Same | — | |
| Photos/videos | Not uploaded by the app; media stays in the host's Google Drive | — | — | |
| Location, microphone, health, browsing history, ads ID | Not collected | Not collected | | |

Merged release permissions (from `flutter build appbundle`):
- D-Card: `INTERNET`, `ACCESS_NETWORK_STATE`, `READ_CONTACTS`, `POST_NOTIFICATIONS`, `WAKE_LOCK`, FCM `c2dm.RECEIVE`, `READ_GSERVICES`.
- D-Card Door: `INTERNET`, `ACCESS_NETWORK_STATE`, `CAMERA`, `POST_NOTIFICATIONS`, `WAKE_LOCK`, FCM `c2dm.RECEIVE`, `READ_GSERVICES`.

No ads SDK, no analytics SDK, no tracking. Data is encrypted in transit (HTTPS). Personal fields are encrypted at rest on the server (`DATA_ENCRYPTION_KEY`).

---

## 4. Google Play Data safety

Common answers (both apps):
- Does your app collect or share any of the required user data types? **Yes**.
- Is all user data encrypted in transit? **Yes**.
- Do you provide a way for users to request that their data is deleted? **Yes**. Registered guests: "Delete my account" in the D-Card app. Hosts/staff: `<OWNER: support email>` or the web account page. Play also requires an account-deletion web link: use `https://dcard.danfordchris.dev/privacy#delete` (`<OWNER: confirm the anchor once the privacy page ships>`).
- Data shared with third parties: **No** for "sharing" in Play's sense. Firebase, Snippe, WhatsApp/NextSMS act as service providers processing on D-Card's behalf, which Play does not count as sharing. The checkout phone number and amount go to Snippe as a service provider.
- Independent security review: No. Families policy: not targeted at children.

### D-Card

| Data type | Collected | Shared | Optional? | Purposes |
|---|---|---|---|---|
| Personal info › Name | Yes | No | Required for guests added by hosts; optional for guest sign-in | App functionality, Account management |
| Personal info › Email address | Yes | No | Required to sign in | App functionality, Account management, Developer communications (invites, password reset) |
| Personal info › User IDs | Yes | No | Required | App functionality, Account management |
| Personal info › Phone number | Yes | No | Required for checkout; guests' numbers added by the host | App functionality |
| Financial info › Purchase history | Yes | No | Required for hosts who pay | App functionality |
| Financial info › Other financial info (pledges, contributions) | Yes | No | Optional (only events that use contributions) | App functionality |
| Contacts | Yes | No | Optional (host chooses to import) | App functionality |
| App activity › Other user-generated content (RSVP answers, event details) | Yes | No | Optional | App functionality |
| App activity › Other actions (audit log of logins/edits) | Yes | No | Required | Fraud prevention, security, and compliance |
| Device or other IDs (FCM token) | Yes | No | Optional (notifications) | App functionality |
| App info and performance › Crash logs | **No** today; answer Yes (Analytics, not shared) once Sentry ships | | | |

Processed ephemerally: none. Location, photos/videos, audio, files, messages, health, web browsing: **Not collected**.

### D-Card Door

| Data type | Collected | Shared | Optional? | Purposes |
|---|---|---|---|---|
| Personal info › Email address | Yes | No | Required | App functionality, Account management |
| Personal info › User IDs | Yes | No | Required | App functionality, Account management |
| Personal info › Name | Yes (gate name; guest names downloaded for the event) | No | Gate name optional | App functionality |
| App activity › Other actions (check-ins, walk-in requests) | Yes | No | Required | App functionality, Fraud prevention, security, and compliance |
| Device or other IDs (door device ID, FCM token) | Yes | No | Required (device ID) | App functionality, Fraud prevention, security, and compliance |
| Crash logs | No today (see above) | | | |

Camera is used for scanning only and images are not collected, so no "Photos" entry. Contacts, location, financial info: **Not collected**.

---

## 5. Apple App Privacy ("nutrition label")

Both apps: **Data used to track you: none.** No third-party advertising, no data brokers. Answer "No" to tracking and do not add an App Tracking Transparency prompt.

### D-Card — Data linked to you

| Category › Type | Purposes |
|---|---|
| Contact Info › Name | App Functionality |
| Contact Info › Email Address | App Functionality |
| Contact Info › Phone Number | App Functionality |
| Contacts › Contacts | App Functionality |
| Financial Info › Other Financial Info (contributions, payment amounts; no card numbers) | App Functionality |
| Purchases › Purchase History | App Functionality |
| User Content › Other User Content (RSVP answers, event details) | App Functionality |
| Identifiers › User ID | App Functionality |
| Identifiers › Device ID (push token) | App Functionality |
| Usage Data › Product Interaction (audit log) | App Functionality (security) |

Data not linked to you: none. Diagnostics › Crash Data: add "Not linked, App Functionality/Analytics" when Sentry ships.

### D-Card Door — Data linked to you

| Category › Type | Purposes |
|---|---|
| Contact Info › Email Address | App Functionality |
| Contact Info › Name (gate name; guest names cached for the event) | App Functionality |
| Identifiers › User ID | App Functionality |
| Identifiers › Device ID | App Functionality |
| Usage Data › Product Interaction (check-in audit) | App Functionality |

### App Review notes to prepare

- **Sign in with Apple:** the D-Card app offers Google sign-in for guests, so Apple sign-in must be offered alongside (guideline 4.8). Hosts use email + password (allowed).
- **Account deletion (5.1.1(v)):** registered guests must be able to delete the account in the app. Hosts/staff also create accounts, so they need an in-app deletion path or a clear in-app link that starts deletion. `<OWNER: confirm before submitting>`.
- **Payments (3.1):** hosts pay for guest cards with mobile money through Snippe inside the app. A reviewer may consider the cards digital goods that need In-App Purchase. D-Card's case: the cards are a messaging service delivered by WhatsApp/SMS outside the app, and payment is for a real-world event service (3.1.3(e)/3.1.5). If review rejects this, fall back to checkout on the web (`apps/web`) with no in-app purchase button on iOS. `<OWNER: decision if rejected>`.
- **Demo accounts:** give a host demo account with an event that has guests and a door-staff demo account on the same event, plus a sample card link and QR for the reviewer to scan.
- Purpose strings present: `NSContactsUsageDescription` (D-Card), `NSCameraUsageDescription` (D-Card Door). English only today; add Swahili `InfoPlist.strings` (`sw.lproj`) before release.

---

## 6. Screenshots checklist

Sizes: Play phone screenshots 1080×1920 or larger (2–8 per language), feature graphic 1024×500, icon 512×512 PNG. App Store: 6.9" iPhone (1320×2868) required, 6.5" (1284×2778) optional; iPad not needed (`TARGETED_DEVICE_FAMILY` should be iPhone only unless iPad layouts are tested). App Store icon 1024×1024 without transparency.

Use demo data only (fake names, `255700000xxx` numbers). Take each set in Swahili and in English.

D-Card:
- [ ] Events list
- [ ] Event detail (guests, confirmations)
- [ ] Contacts picker with consent checkbox
- [ ] Contributions (pledged vs paid)
- [ ] Billing / checkout with mobile money
- [ ] Walk-in requests
- [ ] Guest: my cards and a card with QR

D-Card Door:
- [ ] Event select / gate name
- [ ] QR scanner
- [ ] Result: valid, already used, people count
- [ ] Card number pad
- [ ] Name search
- [ ] Offline banner / sync state
- [ ] Walk-in request

Assets still missing (both apps): real launcher icons (Android `mipmap-*`, iOS `AppIcon`) and launch images. Both are still the Flutter placeholders; `flutter build ipa` warns about them. Suggested: `flutter_launcher_icons` from a 1024×1024 source in D-Card brand colours.

---

## 7. Release build configuration

Done in T06-09:
- Android release signing in `apps/{mobile,door}/android/app/build.gradle.kts` reads `android/key.properties` (gitignored by `apps/*/android/.gitignore`, together with `*.jks` and `*.keystore`). Without the file, release builds fall back to the debug key: useful for local checks, but Play rejects them.
- Launcher names: Android `android:label` and iOS `CFBundleDisplayName` set to "D-Card" and "D-Card Door".
- D-Card Door main manifest now declares `INTERNET` (before, only the debug/profile manifests did).
- iOS deployment target raised to 15.0 in both `Podfile`s and `Runner.xcodeproj` (`firebase_auth` requires it; `pod install` failed on 13.0).

`android/key.properties` format (owner creates; one per app, or the same upload key for both):

```
storePassword=<secret>
keyPassword=<secret>
keyAlias=upload
storeFile=/absolute/path/outside/the/repo/dcard-upload.jks
```

`storeFile` may also be relative to `android/app/`, but keep the keystore outside the repository.

Still open (owner or later task):
- iOS push: add the Push Notifications capability (`aps-environment` entitlement) and Background Modes › Remote notifications in Xcode, and upload an APNs key to Firebase. Not in the project yet.
- Swahili `InfoPlist.strings`; `CFBundleName` is still `dcard_mobile` / `dcard_door` (shown only in some system places).
- Firebase: register the Android and iOS apps (ids above) in the Firebase project; add the Play App Signing SHA-1/SHA-256 and the upload key fingerprints for Google sign-in.

## 8. Build results (2026-09-27, Flutter 3.44.6 via fvm, Xcode 26.2)

| Command | D-Card | D-Card Door |
|---|---|---|
| `flutter build appbundle` | ✓ `build/app/outputs/bundle/release/app-release.aab` (57.8 MB), debug-signed (no `key.properties`) | ✓ `app-release.aab` (71.3 MB), debug-signed |
| `flutter build ipa --no-codesign` | ✓ `build/ios/archive/Runner.xcarchive`, IPA skipped (no signing) | ✓ `Runner.xcarchive`, IPA skipped |

Notes:
- Builds ran without `--dart-define`s, so these artifacts point at the emulator default API and have no Firebase config. They prove the build, not a release.
- The first iOS attempts needed `pod repo update` (stale CocoaPods specs) and, for D-Card, a `pod install` after dependency changes.
- Warning to follow up: `firebase_auth` and `firebase_core` apply the Kotlin Gradle Plugin, which future Flutter versions will reject. Upgrade those plugins when versions with built-in Kotlin support are out.

---

## 9. Owner checklist — Google Play internal testing

1. [ ] Create a Google Play Developer account (one-time US$25; organisation account needs a D-U-N-S number). Complete identity verification. New personal accounts must run a closed test with at least 12 testers for 14 days before production access. Internal testing has no such wait.
2. [ ] Create an upload key on your own machine (never in the repo):
   `keytool -genkey -v -keystore ~/keys/dcard-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
   Back up the `.jks` and passwords in a password manager. Never commit it or send it in chat.
3. [ ] Create `apps/mobile/android/key.properties` and `apps/door/android/key.properties` (format in section 7). Check with `git status` that neither file shows up.
4. [ ] In Play Console create two apps: "D-Card" (`tz.dcard.dcard_mobile`) and "D-Card Door" (`tz.dcard.dcard_door`), default language Swahili or English, app, free.
5. [ ] Enrol in Play App Signing (default). Copy the app-signing and upload SHA-1/SHA-256 into Firebase (needed for Google sign-in).
6. [ ] Build with the production defines:
   `flutter build appbundle --release --dart-define-from-file=<local, gitignored prod defines>`
   in `apps/mobile` and `apps/door`. Raise the `+build` number on every upload.
7. [ ] Fill in the store listing (sections 1–2), screenshots (section 6), privacy policy URL, app category, contact details.
8. [ ] App content: privacy policy, ads (none), app access (demo accounts), content rating, target audience (18+), data safety (section 4), government apps (no), financial features (answer that payments go through a licensed provider, Snippe), account deletion URL.
9. [ ] Testing › Internal testing: create a release, upload the `.aab`, add testers by email list (up to 100), roll out. Share the opt-in link with testers.
10. [ ] Test on real Android phones: sign in, add guests from contacts, checkout with a small amount, push notification, door scan online and in airplane mode.

## 10. Owner checklist — TestFlight

1. [ ] Enrol in the Apple Developer Program (US$99/year). An organisation needs a D-U-N-S number.
2. [ ] In Certificates, Identifiers & Profiles register App IDs `tz.dcard.dcardMobile` and `tz.dcard.dcardDoor` with Push Notifications (and Sign in with Apple for D-Card).
3. [ ] Create an APNs auth key (.p8), upload it to Firebase Cloud Messaging. Keep the .p8 out of the repo.
4. [ ] Open `apps/mobile/ios/Runner.xcworkspace` in Xcode: Signing & Capabilities → select your Team, automatic signing; add Push Notifications, Background Modes › Remote notifications, and Sign in with Apple. Repeat for `apps/door` (Push Notifications, Background Modes). Commit only the project/entitlements changes, never certificates or profiles.
5. [ ] In App Store Connect create two apps with those bundle ids, primary language, SKU (`dcard-mobile`, `dcard-door`).
6. [ ] Fill in App Privacy (section 5), privacy policy URL, category, age rating, and the review notes with demo accounts.
7. [ ] Build and upload:
   `flutter build ipa --release --dart-define-from-file=<local prod defines>` then upload `build/ios/ipa/*.ipa` with Transporter or `xcrun altool`/Xcode Organizer.
8. [ ] Answer export compliance: the apps use only standard HTTPS/OS encryption (plus SQLCipher on device) → exempt; set `ITSAppUsesNonExemptEncryption` to `NO` in `Info.plist` once confirmed.
9. [ ] TestFlight: add internal testers (App Store Connect users, no review), or external testers (needs a short Beta App Review).
10. [ ] Test on real iPhones: sign in (email, Google, Apple), contacts permission, checkout, push, door scan online and offline.

Security reminders: never commit `key.properties`, `*.jks`, `*.p8`, `*.p12`, `*.mobileprovision`, `GoogleService-Info.plist` with production keys, or the prod `--dart-define` file.
