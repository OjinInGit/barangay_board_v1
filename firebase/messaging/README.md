# Firebase Messaging assets (BarangayBoard)

| File | Purpose |
|------|---------|
| `notification_templates.json` | Ready-made **notification title** and **body** strings for each announcement type. Used when composing messages in **Firebase Console → Cloud Messaging** (topic `all_residents`). Not loaded by the app at runtime. |
| `../FCM_CONSOLE_GUIDE.md` | Full procedure for officials: publish in app → send matching push from Console. |

The Flutter app only needs the topic name and Android channel defined in `lib/core/app_constants.dart` and `AndroidManifest.xml`.
