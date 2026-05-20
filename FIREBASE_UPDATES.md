# Firebase setup — BarangayBoard v1.5.6 (Spark / free plan)

This app uses **Firebase Auth**, **Cloud Firestore**, and **FCM** only.  
**Firebase Storage is not used** — there is no image upload. You do **not** need to enable Storage or upgrade for images.

Project: **barangayboard-v1** — [Firebase Console](https://console.firebase.google.com/)

---

## 1. Services you need (free Spark plan)

| Service | Purpose |
|---------|---------|
| **Authentication** | Login / registration |
| **Cloud Firestore** | Users, announcements, archive fields |
| **Cloud Messaging (FCM)** | Push notifications (Console or Blaze Functions) |

**Do not enable Firebase Storage** for this app. If you turned it on earlier, you can leave it unused or disable it in Console — the app will not read or write files there.

---

## 2. Deploy Firestore security rules

Archive fields: `archived`, `archivedAt` (no Storage fields).

```powershell
cd c:\Users\Ojin\Desktop\BarangayBoard\barangay_board_v1\barangay_board_v1
firebase deploy --only firestore:rules
```

Rules file: `firebase/firestore.rules`

---

## 3. Announcements in Firestore

- **Active** — `archived` is `false` or missing; shown to residents and in Admin → Announcements.
- **Archived** — after **30 days**, the app sets `archived: true` and `archivedAt` (not deleted).
- **Optional cleanup** — Old `imageUrl` fields on documents (from a previous build) are ignored by the app. You may delete that field manually in Console if you want a tidy database.

---

## 4. Push notifications (FCM)

- **Manual sends** from Firebase Console → Messaging: works on **Spark (free)**.  
  See `firebase/FCM_CONSOLE_GUIDE.md`.
- **Cloud Functions** (`functions/index.js`) for automatic push on publish: requires **Blaze** billing (pay-as-you-go; still has a free tier for light use).

---

## 5. iOS (iPhone / iPad)

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Add **`GoogleService-Info.plist`** (Console → Project settings → Your iOS app → Download) into `ios/Runner/`.
3. Set your **Team** for code signing; iOS **13+** recommended.
4. Build: `flutter build ios` or run on device.

No photo-library permission is required (image upload removed). PDF/text share uses the system share sheet only.

---

## 6. Android

- `google-services.json` is already under `android/app/`.
- No extra Storage or gallery permissions are required.

---

## 7. Quick checklist

| Step | Action |
|------|--------|
| Auth | Email/password enabled in Console |
| Firestore | Database created + `firebase deploy --only firestore:rules` |
| Storage | **Skip** — not used |
| FCM | Optional: send test from Console (see FCM guide) |
| iOS | `GoogleService-Info.plist` + Xcode signing |
| Test | Create announcement (text only), archive, share PDF |

---

## 8. If you previously enabled Storage

1. Console → **Build** → **Storage** — you can ignore it; the app no longer uploads images.
2. Do **not** run `firebase deploy --only storage` (rules file removed from this project).
3. Optional: delete test files under `announcements/` in the Storage browser to save space.

No billing change is required if you stay on Spark and only use Auth + Firestore + Console FCM.
