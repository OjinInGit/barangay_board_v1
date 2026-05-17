import 'package:flutter/material.dart';

class AppStrings {
  AppStrings(this._code);

  final String _code;
  bool get isFilipino => _code == 'fil';

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings(locale.languageCode == 'fil' ? 'fil' : 'en');
  }

  String get appName => 'BarangayBoard';
  String get appTagline => isFilipino
      ? 'E-Bulletin App para sa Brgy. Sagkahan'
      : 'E-Bulletin App for Brgy. Sagkahan';
  String get appVersionLabel => 'v 1.5.3';

  String get introTagline => appTagline;
  String get adminDashboardSubtitle =>
      isFilipino ? 'Dashboard ng tagapangasiwa' : 'Administrator dashboard';
  String get residentBulletinSubtitle =>
      isFilipino ? 'Bulletin ng residente' : 'Resident bulletin';

  String get chooseLanguage =>
      isFilipino ? 'Pumili ng wika' : 'Choose your language';
  String get english => 'English';
  String get filipino => 'Filipino';
  String get continueLabel => isFilipino ? 'Magpatuloy' : 'Continue';

  String get login => isFilipino ? 'Mag-login' : 'Login';
  String get register => isFilipino ? 'Magrehistro' : 'Register';
  String get noAccount =>
      isFilipino ? 'Walang account? Magrehistro' : "Don't have an account? Register";
  String get haveAccount =>
      isFilipino ? 'May account na? Mag-login' : 'Already have an account? Login';
  String get username => isFilipino ? 'Username' : 'Username';
  String get password => isFilipino ? 'Password' : 'Password';
  String get retypePassword => isFilipino ? 'Ulitin ang password' : 'Retype password';
  String get firstName => isFilipino ? 'Pangalan' : 'First name';
  String get lastName => isFilipino ? 'Apelyido' : 'Last name';
  String get middleInitial => isFilipino ? 'Gitnang inisyal' : 'Middle initial';
  String get suffix => isFilipino ? 'Suffix' : 'Suffix';
  String get email => isFilipino ? 'E-mail' : 'E-mail';

  String get fieldRequired => isFilipino ? 'Kailangan ang field' : 'This field is required';
  String get emptyPassword =>
      isFilipino ? 'Ilagay ang password' : 'Please enter your password';
  String get invalidMiddleInitial => isFilipino
      ? 'Isang malaking titik lamang'
      : 'One uppercase letter only';
  String get invalidCredentials =>
      isFilipino ? 'Hindi wasto ang username o password' : 'Invalid username or password';
  String get genericError =>
      isFilipino ? 'May naganap na error' : 'Something went wrong';
  String get accountDeactivated => isFilipino
      ? 'Na-deactivate ang account'
      : 'This account has been deactivated';

  String get residents => isFilipino ? 'Mga residente' : 'Residents';
  String get makeAnnouncement =>
      isFilipino ? 'Gumawa ng anunsyo' : 'Make an announcement';
  String get announcements => isFilipino ? 'Mga anunsyo' : 'Announcements';
  String get settings => isFilipino ? 'Mga setting' : 'Settings';
  String get language => isFilipino ? 'Wika' : 'Language';
  String get logout => isFilipino ? 'Mag-log out' : 'Log out';
  String get exitApp => isFilipino ? 'Lumabas sa app' : 'Exit app';
  String get logoutConfirm =>
      isFilipino ? 'Sigurado ka bang mag-log out?' : 'Are you sure you want to log out?';
  String get exitConfirm => isFilipino
      ? 'Lalabas ka sa app ngunit mananatiling naka-login.'
      : 'You will leave the app but stay signed in.';
  String get cancel => isFilipino ? 'Kanselahin' : 'Cancel';
  String get save => isFilipino ? 'I-save' : 'Save';
  String get edit => isFilipino ? 'I-edit' : 'Edit';
  String get delete => isFilipino ? 'Tanggalin' : 'Delete';
  String get noResidents =>
      isFilipino ? 'Walang nakarehistrong residente' : 'No registered residents yet';
  String get removeUserConfirm => isFilipino
      ? 'Tanggalin ang residente mula sa app?'
      : 'Remove this resident from the app?';
  String get residentRemovedSuccess => isFilipino
      ? 'Matagumpay na natanggal ang residente'
      : 'Resident removed successfully';
  String get residentRemoveFailed => isFilipino
      ? 'Hindi natanggal ang residente'
      : 'Could not remove resident';

  String get announcementType =>
      isFilipino ? 'Uri ng anunsyo' : 'Announcement type';
  String get typeUrgentNotice =>
      isFilipino ? 'Apurahang paalala' : 'Urgent Notice';
  String get typeHealthAdvisory =>
      isFilipino ? 'Payo sa kalusugan' : 'Health Advisory';
  String get typeOfficialAdvisory =>
      isFilipino ? 'Opisyal na payo' : 'Official Advisory';
  String get typePublicNotice =>
      isFilipino ? 'Pampublikong abiso' : 'Public Notice';
  String get typeGeneralAssembly =>
      isFilipino ? 'Pangkalahatang pagpupulong' : 'General Assembly';
  String get typeWasteManagement =>
      isFilipino ? 'Pamamahala ng basura' : 'Waste Management';
  String get typeEvent => isFilipino ? 'Kaganapan' : 'Event';
  String get typeCustomTag => isFilipino ? 'Pasadyang tag' : 'Custom Tag';
  String get customTagHint =>
      isFilipino ? 'Ilagay ang pasadyang tag' : 'Enter custom tag label';
  String get customTagRequired => isFilipino
      ? 'Kailangan ang pasadyang tag'
      : 'Custom tag label is required';
  String get publish => isFilipino ? 'I-publish' : 'Publish';
  String get noAnnouncements =>
      isFilipino ? 'Walang anunsyo' : 'No announcements yet';
  String get deleteAnnouncementConfirm => isFilipino
      ? 'Tanggalin ang anunsyong ito?'
      : 'Delete this announcement?';

  String get notificationPromptTitle => isFilipino
      ? 'Paganahin ang mga abiso'
      : 'Enable notifications';
  String get notificationPromptBody => isFilipino
      ? 'Mas epektibo ang app kapag pinapayagan ang mga abiso sa system settings.'
      : 'Notifications help this app reach residents quickly. You can change this later in system settings.';
  String get allowNotifications => isFilipino ? 'Payagan' : 'Allow';
  String get notNow => isFilipino ? 'Hindi muna' : 'Not now';

  String loggedInAs(String username) =>
      isFilipino ? 'Naka-log in bilang $username' : 'Logged in as $username';

  String get errInvalidEmail =>
      isFilipino ? 'Hindi wasto ang e-mail' : 'Invalid email address';
  String get errUserDisabled =>
      isFilipino ? 'Na-disable ang account' : 'This account is disabled';
  String get errUserNotFound => isFilipino
      ? 'Walang account na tumutugma sa username'
      : 'No account matches that username';
  String get errWrongPassword =>
      isFilipino ? 'Maling password' : 'Incorrect password';
  String get errInvalidCredentials => invalidCredentials;
  String get errEmailInUse =>
      isFilipino ? 'Ginagamit na ang e-mail' : 'Email is already in use';
  String get errWeakPasswordAuth =>
      isFilipino ? 'Masyadong mahina ang password' : 'Password is too weak';
  String get errOperationNotAllowed => isFilipino
      ? 'Hindi pinapayagan ang operasyon'
      : 'Operation not allowed';
  String get errTooManyRequests => isFilipino
      ? 'Masyadong maraming pagtatangka'
      : 'Too many attempts. Try again later';
  String get errNetwork =>
      isFilipino ? 'Problema sa network' : 'Network error. Check your connection';
  String errAuthWithDetail(String code) =>
      isFilipino ? 'Error sa pag-login ($code)' : 'Sign-in error ($code)';
  String get errRegistrationServer => isFilipino
      ? 'Hindi makumpleto ang rehistro sa server'
      : 'Registration could not be completed on the server';
  String get errNameTaken => isFilipino
      ? 'May account na para sa parehong pangalan at inisyal'
      : 'An account already exists for this full name';
  String get errUsernameTaken =>
      isFilipino ? 'Ginagamit na ang username' : 'Username is already taken';
  String get errWeakPassword => isFilipino
      ? 'Dapat may malaki, maliit, numero, at espesyal na karakter (min. 8)'
      : 'Password needs upper, lower, number, special character (min. 8)';
  String get errPasswordMismatch =>
      isFilipino ? 'Hindi magkatugma ang password' : 'Passwords do not match';
  String get registrationSuccess => isFilipino
      ? 'Matagumpay ang rehistro. Mag-login na.'
      : 'Registration successful. Please log in.';
}
