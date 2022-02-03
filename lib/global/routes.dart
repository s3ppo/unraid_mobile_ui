import 'package:flutter/material.dart';
import 'package:unraid_ui/screens/home.dart';
import 'package:unraid_ui/screens/login.dart';

class Routes {
  static const String login = "login";
  static const String home = "home";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          switch (settings.name) {
            case login:
              return const LoginPage();
            case home:
              return const HomePage();
            default:
              return const LoginPage();
          }
        });
  }
}
