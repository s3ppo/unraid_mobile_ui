import 'package:flutter/material.dart';
import 'package:unraid_ui/screens/array.dart';
import 'package:unraid_ui/screens/dockers.dart';
import 'package:unraid_ui/screens/login.dart';
import 'package:unraid_ui/screens/plugins.dart';
import 'package:unraid_ui/screens/shares.dart';
import 'package:unraid_ui/screens/home.dart';
import 'package:unraid_ui/screens/system_memory.dart';
import 'package:unraid_ui/screens/vms.dart';
import 'package:unraid_ui/screens/system.dart';
import 'package:unraid_ui/screens/system_baseboard.dart';
import 'package:unraid_ui/screens/system_cpu.dart';
import 'package:unraid_ui/screens/system_os.dart';

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
