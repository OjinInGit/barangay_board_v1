# Firebase Console Cloud Messaging (BarangayBoard)

This project delivers **system notifications to residents** using **FCM topics**, without requiring Cloud Functions or a Blaze plan. After an admin publishes an announcement in the app, send a matching push from the **Firebase Console**.

---

## How it fits together

| Piece | Role |
|--------|------|
| **App** (`lib/services/messaging_service.dart`) | Subscribes residents to topic `all_residents`, requests permission, shows tray notifications when the app is open (foreground). |
| **Android** (`android/app/src/main/AndroidManifest.xml`) | Default FCM channel `barangay_announcements` so Console messages use the correct channel. |
| **Constants** (`lib/core/app_constants.dart`) | Topic name and channel id used by the app (must match Console targeting). |
| **Templates** (`firebase/messaging/notification_templates.json`) | Copy-paste **title** and **body** for each announcement type when composing a Console message. |
| **Cloud Function** (`functions/index.js`) | **Optional.** Auto-sends FCM when a Firestore announcement is created (requires Blaze + deploy). Use Console instead if you stay on Spark. |

**Resident devices** must:

1. Be signed in as a **resident** (not admin).
2. Have allowed notifications for BarangayBoard in system settings.
3. Have opened the app at least once after install so the app can subscribe to `all_residents`.

---

## Step-by-step: send a notification from Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/) → project **barangayboard-v1**.
2. Go to **Engage** → **Messaging** (or **Cloud Messaging**).
3. Click **Create your first campaign** or **New campaign** → **Firebase Notification messages**.
4. **Notification**
   - **Notification title** and **Notification text**: copy from `firebase/messaging/notification_templates.json` for the announcement type you just published (or write a short summary).
   - Example: title `BarangayBoard: Urgent Notice`, text `An urgent notice was posted for Brgy. Sagkahan. Open the app to read.`
5. Click **Send test message** (optional): add an FCM registration token from a test device, or skip and use topic in the next step.
6. **Target** → **Topic** → enter exactly: `all_residents`
7. **Scheduling**: send now.
8. Review and **Publish**.

Residents subscribed to `all_residents` should receive a system notification. Tapping it opens the app (bulletin is already in Firestore).

---

## Matching announcement types to templates

When you publish in the app (**Make an announcement**), pick the same category in the template file:

| App tag | Template key in JSON |
|---------|----------------------|
| Urgent Notice | `urgent_notice` |
| Health Advisory | `health_advisory` |
| Official Advisory | `official_advisory` |
| Public Notice | `public_notice` |
| General Assembly | `general_assembly` |
| Waste Management | `waste_management` |
| Event | `event` |
| Custom Tag | `custom_tag` (edit title to include your custom label) |

You may shorten the **body** to the first sentence of the announcement; keep titles consistent so residents recognize BarangayBoard.

---

## Optional: custom data (advanced)

In the Console composer, if **Additional options** → **Custom data** is available, you may add:

| Key | Example value |
|-----|----------------|
| `type` | `urgent_notice` |

The app does not require custom data for Console pushes; **notification title + body** are enough for the tray. Data keys are reserved for future deep-linking.

---

## Troubleshooting

| Problem | Check |
|---------|--------|
| No notification on device | Resident account (not admin); notifications enabled in phone settings; app opened once while logged in as resident. |
| Admin device does not receive topic message | Expected: only residents subscribe to `all_residents`. |
| Notification in foreground but not when app closed | Console message must include a **Notification** payload (not data-only). Channel id `barangay_announcements` is set in the manifest. |
| Wrong project | App uses `google-services.json` for `barangayboard-v1`; Console campaign must use the same project. |

**Verify topic subscription:** run the app as a resident, then in Console use **Send test message** with that device’s FCM token, or send to topic `all_residents` and wait a few minutes for propagation.

---

## Optional: automatic pushes (Cloud Functions)

If you later upgrade to **Blaze** and deploy functions:

```bash
cd barangay_board_v1
firebase deploy --only functions
```

`notifyResidentsOnAnnouncement` sends to `all_residents` whenever a document is created in `announcements`. You can use **Console** and **Functions** together, but avoid sending duplicate messages for the same post.

---

## File reference (do not rename topic/channel without updating the app)

- `lib/core/app_constants.dart` — `fcmTopicResidents`, `fcmChannelId`, `fcmChannelName`
- `lib/services/messaging_service.dart` — subscription, foreground display, background handler
- `lib/main.dart` — registers `FirebaseMessaging.onBackgroundMessage`
- `lib/screens/auth/login_screen.dart` & `lib/main.dart` — subscribe residents after login / cold start
- `firebase/messaging/notification_templates.json` — Console copy-paste templates
- `functions/index.js` — optional auto-send (Blaze)
