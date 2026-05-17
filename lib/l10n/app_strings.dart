import 'package:flutter/material.dart';

enum AppLanguage { english, filipino }

extension AppLanguageCode on AppLanguage {
  String get code => this == AppLanguage.english ? 'en' : 'fil';
}

class AppStrings {
  AppStrings(this.lang);

  final AppLanguage lang;

  bool get isEnglish => lang == AppLanguage.english;

  String t(String en, String fil) => isEnglish ? en : fil;

  String get appName => t('Barangay E-Bulletin', 'E-Bulletin ng Barangay');
  String get introTagline => t(
    'Stay informed with official announcements.',
    'Manatiling may alam sa opisyal na anunsyo.',
  );

  String get chooseLanguage => t('Choose your language', 'Piliin ang wika');
  String get english => t('English', 'Ingles');
  String get filipino => t('Filipino', 'Filipino');
  String get continueLabel => t('Continue', 'Magpatuloy');

  String get login => t('Login', 'Mag-login');
  String get register => t('Register', 'Magrehistro');
  String get username => t('Username', 'Username');
  String get password => t('Password', 'Password');
  String get noAccount =>
      t('No account? Register', 'Walang account? Magrehistro');
  String get haveAccount =>
      t('Already have an account? Login', 'May account na? Mag-login');

  String get firstName => t('First Name', 'Pangalan');
  String get lastName => t('Last Name', 'Apelyido');
  String get middleInitial => t('Middle Initial', 'Gitnang Inisyal');
  String get suffix => t('Suffix (optional)', 'Suffix (opsyonal)');
  String get email => t('E-mail', 'E-mail');
  String get retypePassword => t('Retype Password', 'Ulitin ang Password');
  String get submit => t('Submit', 'Ipasa');

  String get settings => t('Settings', 'Mga Setting');
  String get language => t('Language', 'Wika');
  String get logOut => t('Log out', 'Mag-log out');
  String get exitApp => t('Exit', 'Lumabas');

  String get residents => t('Residents', 'Mga Residente');
  String get makeAnnouncement => t('Make an Announcement', 'Gumawa ng Anunsyo');
  String get announcements => t('Announcements', 'Mga Anunsyo');

  String get adminHomeTitle => t('Official Dashboard', 'Dashboard ng Opisyal');
  String get residentHomeTitle => t('Announcements', 'Mga Anunsyo');

  String get announcementType => t('Announcement type', 'Uri ng anunsyo');
  String get announcementBody => t('Announcement text', 'Teksto ng anunsyo');
  String get post => t('Post', 'I-post');
  String get save => t('Save', 'I-save');
  String get delete => t('Delete', 'Tanggalin');
  String get edit => t('Edit', 'I-edit');
  String get cancel => t('Cancel', 'Kanselahin');

  String get event => t('Event', 'Kaganapan');
  String get meeting => t('Meeting', 'Pulong');
  String get notice => t('Notice', 'Paunawa');
  String get ordinance => t('Ordinance', 'Ordinansa');
  String get healthAdvisory => t('Health Advisory', 'Health Advisory');
  String get other => t('Other', 'Iba pa');

  String get notificationRationaleTitle =>
      t('Enable notifications', 'Paganahin ang mga notification');
  String get notificationRationaleBody => t(
    'Turning on notifications helps the barangay reach you quickly when new announcements are posted. You can change this anytime in your device settings for this app.',
    'Kapag naka-on ang notifications, mas mabilis kang maabot ng barangay kapag may bagong anunsyo. Maaari mo itong baguhin anumang oras sa settings ng iyong device para sa app na ito.',
  );
  String get askLater => t('Not now', 'Hindi muna');
  String get allowNotifications =>
      t('Allow notifications', 'Payagan ang notifications');

  String get fieldRequired =>
      t('This field is required.', 'Kinakailangan ang patlang na ito.');
  String get passwordsMismatch =>
      t('Passwords do not match.', 'Hindi tugma ang mga password.');
  String get invalidCredentials =>
      t('Invalid username or password.', 'Mali ang username o password.');
  String get usernameTaken =>
      t('Username is already taken.', 'Gamit na ang username.');
  String get weakPassword => t('Password is too weak.', 'Mahina ang password.');
  String get genericError => t('Something went wrong.', 'May naganap na mali.');

  String get removeUserConfirm => t(
    'Remove this resident from the active list?',
    'Alisin ang residente sa aktibong listahan?',
  );
  String get deleteAnnouncementConfirm => t(
    'Delete this announcement? Residents will no longer see it.',
    'Tanggalin ang anunsyong ito? Hindi na ito makikita ng mga residente.',
  );

  String get noAnnouncements =>
      t('No announcements yet.', 'Wala pang anunsyo.');
  String get noResidents =>
      t('No registered residents.', 'Walang nakarehistrong residente.');

  String get createdAt => t('Posted', 'Na-post');

  String get confirmLogOutTitle => t('Log out?', 'Mag-log out?');
  String get confirmLogOutBody => t(
    'You will need to sign in again to use the app.',
    'Kailangan mong mag-sign in muli para magamit ang app.',
  );
  String get confirmExitTitle => t('Exit app?', 'Lumabas sa app?');
  String get confirmExitBody => t(
    'The app will close. You can open it again from your home screen.',
    'Magsasara ang app. Maaari mo itong buksan muli mula sa home screen.',
  );
  String get confirmYes => t('Yes', 'Oo');
  String get confirmNo => t('No', 'Hindi');

  String get duplicateFullName => t(
    'A resident is already registered with this name.',
    'May nakarehistrong residente na sa ganitong pangalan.',
  );
  String get passwordSameAsUsernameOrEmail => t(
    'Password must not contain or match your username or email.',
    'Hindi dapat ang password ay kapareho o bahagi ng username o email.',
  );

  String get errPasswordTooShort => t(
    'Password must be at least 8 characters.',
    'Ang password ay dapat hindi bababa sa 8 character.',
  );
  String get errPasswordNeedUpper => t(
    'Password must include an uppercase letter.',
    'Ang password ay dapat may isang malaking titik.',
  );
  String get errPasswordNeedLower => t(
    'Password must include a lowercase letter.',
    'Ang password ay dapat may isang maliit na titik.',
  );
  String get errPasswordNeedDigit =>
      t('Password must include a number.', 'Ang password ay dapat may numero.');
  String get errPasswordNeedSpecial => t(
    'Password must include a special character.',
    'Ang password ay dapat may espesyal na karakter.',
  );
  String get errMiddleInitialOneLetter => t(
    'Middle initial must be one letter (A–Z).',
    'Ang gitnang inisyal ay isang titik lamang (A–Z).',
  );

  String get errInvalidEmail =>
      t('Invalid email address.', 'Di-wastong email.');
  String get errUserDisabled =>
      t('This account has been disabled.', 'Naka-disable ang account na ito.');
  String get errUserNotFound =>
      t('No account found for this email or username.', 'Walang account.');
  String get errWrongPassword => t('Incorrect password.', 'Maling password.');
  String get errInvalidCredentials => t(
    'Sign-in failed. Check your email/username and password.',
    'Hindi nakapag-sign in. Suriin ang credentials.',
  );
  String get errEmailInUse => t(
    'This email is already registered.',
    'Nakarehistro na ang email na ito.',
  );
  String get errWeakPasswordAuth => t(
    'Password is too weak for Firebase.',
    'Mahina ang password (Firebase).',
  );
  String get errOperationNotAllowed => t(
    'This sign-in method is not enabled.',
    'Hindi pinapayagan ang paraan ng sign-in.',
  );
  String get errTooManyRequests => t(
    'Too many attempts. Try again later.',
    'Sobrang daming pagsubok. Subukan muli mamaya.',
  );
  String get errNetwork => t(
    'Network error. Check your connection.',
    'Error sa network. Suriin ang koneksyon.',
  );
  String errAuthWithDetail(String code) =>
      t('Authentication error: $code', 'Error sa authentication: $code');
  String get errFirestorePermission => t(
    'Permission denied. Check Firestore rules or your admin role.',
    'Tinanggihan ang pahintulot. Suriin ang Firestore rules o admin role.',
  );
  String get errRemoveResidentFailed => t(
    'Could not remove resident. Check your connection and Firestore rules.',
    'Hindi naalis ang residente. Suriin ang koneksyon at rules.',
  );

  String messageForPasswordPolicyCode(String code) {
    switch (code) {
      case 'password_too_short':
        return errPasswordTooShort;
      case 'password_need_upper':
        return errPasswordNeedUpper;
      case 'password_need_lower':
        return errPasswordNeedLower;
      case 'password_need_digit':
        return errPasswordNeedDigit;
      case 'password_need_special':
        return errPasswordNeedSpecial;
      default:
        return weakPassword;
    }
  }

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final lang =
        locale.languageCode.toLowerCase().startsWith('fil') ||
            locale.languageCode.toLowerCase() == 'tl'
        ? AppLanguage.filipino
        : AppLanguage.english;
    return AppStrings(lang);
  }
}
