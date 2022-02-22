import 'package:flutter/material.dart';
import 'package:unraid_ui/screens/array.dart';
import 'package:unraid_ui/screens/dockers.dart';
import 'package:unraid_ui/screens/login.dart';

import '../screens/home.dart';
import '../screens/vms.dart';

class Routes {
  static const String login = "login";
  static const String home = "home";
  static const String array = "array";
  static const String dockers = "dockers";
  static const String plugins = "plugins";
  static const String vms = "vms";

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
            default:
              return const LoginPage();
          }
        });
  }
}
