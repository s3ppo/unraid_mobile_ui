// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get login => '登录';

  @override
  String get needHelp => '需要帮助？';

  @override
  String get appTitle => 'unConnect';

  @override
  String get dashBoardTitle => '仪表盘';

  @override
  String get arrayTitle => '阵列';

  @override
  String get sharesTitle => '共享';

  @override
  String get dockerContainerTitle => 'Docker 容器';

  @override
  String get virtualMachineTitle => '虚拟机';

  @override
  String get systemInfoTitle => '系统信息';

  @override
  String get systemTitle => '系统';

  @override
  String get pluginsTitle => '插件';

  @override
  String get settingsTitle => '设置';

  @override
  String get multiserverSettingsTitle => '多服务器设置';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystemDefault => '跟随系统';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChinese => '中文（简体）';

  @override
  String get logoutTitle => '退出';

  @override
  String get notificationsTitle => '通知';

  @override
  String get version => '版本';

  @override
  String get status => '状态';

  @override
  String get upTime => '运行时间';

  @override
  String get days => '天';

  @override
  String get hours => '小时';

  @override
  String get minutes => '分钟';

  @override
  String get lanIP => '局域网IP';

  @override
  String get array => '阵列';

  @override
  String get state => '状态';

  @override
  String get total => '总和';

  @override
  String get disks => '磁盘';

  @override
  String get disk => '磁盘';

  @override
  String get caches => '缓存';

  @override
  String get cache => '缓存';

  @override
  String get arrayOperation => '阵列操作';

  @override
  String get arrayOperationStart => '启动阵列';

  @override
  String get arrayOperationStop => '停止阵列';

  @override
  String get system => '系统';

  @override
  String get infos => '信息';

  @override
  String get memory => '内存';

  @override
  String get noData => '暂无数据';

  @override
  String freeSpace(int size) {
    return '剩余：$size GB';
  }

  @override
  String get start => '启动';

  @override
  String get stop => '停止';

  @override
  String get cancel => '取消';

  @override
  String get pause => '暂停';

  @override
  String get resume => '恢复';

  @override
  String get reboot => '重启';

  @override
  String get forceStop => '强制停止';

  @override
  String get add => '添加';

  @override
  String get running => '运行中';

  @override
  String get stopped => '已停止';

  @override
  String get addServer => '添加服务器';

  @override
  String errorWithMessage(String message) {
    return '错误：$message';
  }
}
