import 'package:flutter/material.dart';
import 'package:unmobile/screens/array.dart';
import 'package:unmobile/screens/dockers.dart';
import 'package:unmobile/screens/login.dart';
import 'package:unmobile/screens/plugins.dart';
import 'package:unmobile/screens/shares.dart';
import 'package:unmobile/screens/home.dart';
import 'package:unmobile/screens/system_memory.dart';
import 'package:unmobile/screens/vms.dart';
import 'package:unmobile/screens/system.dart';
import 'package:unmobile/screens/system_baseboard.dart';
import 'package:unmobile/screens/system_cpu.dart';
import 'package:unmobile/screens/system_os.dart';
import 'package:unmobile/screens/notifications.dart';

class Routes {
  static const String login = "login";
  static const String home = "home";
  static const String array = "array";
  static const String dockers = "dockers";
  static const String plugins = "plugins";
  static const String vms = "vms";
  static const String shares = "shares";
  static const String system = "system";
  static const String systemBaseboard = "system_baseboard";
  static const String systemCpu = "system_cpu";
  static const String systemOs = "system_os";
  static const String systemMemory = "system_memory";
  static const String notifications = "notifications";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          switch (settings.name) {
            case login:
              return const LoginPage();
            case home:
              return const HomePage();
            case array:
              return const ArrayPage();
            case dockers:
              return const DockersPage();
            case vms:
              return const VmsPage();
            case plugins:
              return const PluginsPage();
            case shares:
              return const SharesPage();
            case notifications:
              return const NotificationPage();
            case system:
              return const SystemPage();
            case systemBaseboard:
              final args = settings.arguments as Map;
              return BaseboardPage(baseboard: args);
            case systemCpu:
              final args = settings.arguments as Map;
              return CpuPage(cpu: args);
            case systemOs:
              final args = settings.arguments as Map;
              return OsPage(os: args);
            case systemMemory:
              final args = settings.arguments as Map;
              return MemoryPage(memory: args);                          
            default:
              return const LoginPage();
          }
        });
  }
}
