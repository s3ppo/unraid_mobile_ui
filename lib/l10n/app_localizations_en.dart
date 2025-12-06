// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'LOGIN';

  @override
  String get needHelp => 'Need help?';

  @override
  String get appTitle => 'unConnect';

  @override
  String get dashBoardTitle => 'Dashboard';

  @override
  String get arrayTitle => 'Array';

  @override
  String get sharesTitle => 'Shares';

  @override
  String get dockerContainerTitle => 'Docker Containers';

  @override
  String get virtualMachineTitle => 'Virtual Machines';

  @override
  String get systemInfoTitle => 'System Info';

  @override
  String get systemTitle => 'System';

  @override
  String get pluginsTitle => 'Plugins';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get multiserverSettingsTitle => 'Multiserver Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese (Simplified)';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get version => 'Version';

  @override
  String get status => 'Status';

  @override
  String get upTime => 'Uptime';

  @override
  String get days => 'days';

  @override
  String get hours => 'hours';

  @override
  String get minutes => 'minutes';

  @override
  String get lanIP => 'Lan IP';

  @override
  String get array => 'Array';

  @override
  String get state => 'State';

  @override
  String get total => 'Total';

  @override
  String get disks => 'Disks';

  @override
  String get disk => 'Disk';

  @override
  String get caches => 'Caches';

  @override
  String get cache => 'Cache';

  @override
  String get arrayOperation => 'Array Operation';

  @override
  String get arrayOperationStart => 'Start';

  @override
  String get arrayOperationStop => 'Stop';

  @override
  String get system => 'System';

  @override
  String get infos => 'Infos';

  @override
  String get memory => 'Memory';

  @override
  String get noData => 'No data available';

  @override
  String freeSpace(int size) {
    return 'Free: $size GB';
  }

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get cancel => 'Cancel';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get reboot => 'Reboot';

  @override
  String get forceStop => 'Force Stop';

  @override
  String get add => 'Add';

  @override
  String get running => 'Running';

  @override
  String get stopped => 'Stopped';

  @override
  String get addServer => 'Add Server';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }
}
