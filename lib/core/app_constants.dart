class AppConstants {
  static const appName = 'BarangayBoard';
  static const appTagline = 'E-Bulletin App for Brgy. Sagkahan';
  static const appVersionLabel = 'v 1.5.6';

  /// Announcements older than this are auto-archived (not deleted).
  static const archiveAfterDays = 30;

  static const fcmTopicResidents = 'all_residents';
  static const fcmChannelId = 'barangay_announcements';
  static const fcmChannelName = 'Barangay announcements';

  static const prefLocale = 'locale_code';
  static const prefLanguageOnboarded = 'language_onboarded';
  static const prefNotificationPromptDone = 'notification_prompt_done';
  static const prefReadAnnouncementIds = 'read_announcement_ids';

  static const logoAsset = 'assets/branding/app_icon.png';
}
