# BarangayBoard

E-Bulletin App for Brgy. Sagkahan (v 1.5.3)

## Features

- Firebase Authentication and Firestore announcements
- Resident push notifications via **FCM topic** `all_residents`
- **Recommended (Spark / free):** send notifications from [Firebase Console](firebase/FCM_CONSOLE_GUIDE.md) using [message templates](firebase/messaging/notification_templates.json)
- **Optional:** Cloud Function auto-push (`functions/index.js`, requires Blaze)

## Push notifications (official workflow)

1. Admin publishes an announcement in the app (Firestore).
2. Admin opens Firebase Console → **Messaging** → new **Notification** campaign.
3. Target **Topic** `all_residents` and copy title/body from `firebase/messaging/notification_templates.json`.

Details: **[firebase/FCM_CONSOLE_GUIDE.md](firebase/FCM_CONSOLE_GUIDE.md)**

## Key app files (FCM)

| File | Role |
|------|------|
| `lib/core/app_constants.dart` | Topic `all_residents`, channel `barangay_announcements` |
| `lib/services/messaging_service.dart` | Subscribe, display Console/FCM messages |
| `lib/main.dart` | Background FCM handler registration |
| `android/app/src/main/AndroidManifest.xml` | Default FCM notification channel |
