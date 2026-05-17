import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_constants.dart';

class PrefsService {
  PrefsService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PrefsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsService(prefs);
  }

  String? get localeCode => _prefs.getString(AppConstants.prefLocale);
  Future<void> setLocaleCode(String code) =>
      _prefs.setString(AppConstants.prefLocale, code);

  bool get languageOnboarded =>
      _prefs.getBool(AppConstants.prefLanguageOnboarded) ?? false;
  Future<void> setLanguageOnboarded(bool v) =>
      _prefs.setBool(AppConstants.prefLanguageOnboarded, v);

  bool get notificationPromptDone =>
      _prefs.getBool(AppConstants.prefNotificationPromptDone) ?? false;
  Future<void> setNotificationPromptDone(bool v) =>
      _prefs.setBool(AppConstants.prefNotificationPromptDone, v);

  Set<String> get readAnnouncementIds =>
      _prefs.getStringList(AppConstants.prefReadAnnouncementIds)?.toSet() ??
      {};

  Future<void> markAnnouncementRead(String id) async {
    final ids = readAnnouncementIds..add(id);
    await _prefs.setStringList(
      AppConstants.prefReadAnnouncementIds,
      ids.toList(),
    );
  }

  bool isAnnouncementRead(String id) => readAnnouncementIds.contains(id);
}
