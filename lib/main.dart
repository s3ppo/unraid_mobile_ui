import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/notifiers.dart';
import 'package:unmobile/global/routes.dart';
import 'package:unmobile/screens/dashboard.dart';
import 'package:unmobile/screens/login.dart';
import 'notifiers/auth_state.dart';
import 'notifiers/theme_mode.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeStr = await rootBundle.loadString('assets/themes/default.json');
  final themeStrDark = await rootBundle.loadString('assets/themes/default_dark.json');
  final themeJson = jsonDecode(themeStr);
  final themeJsonDark = jsonDecode(themeStrDark);
  final lightTheme = ThemeDecoder.decodeThemeData(themeJson)!;
  final darkTheme = ThemeDecoder.decodeThemeData(themeJsonDark)!;

  runApp(MyApp(lightTheme: lightTheme, darkTheme: darkTheme));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.lightTheme, required this.darkTheme}) : super(key: key);
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, child) {
            return MaterialApp(
              title: 'unMobile',
              debugShowCheckedModeBanner: false,
              theme: themeNotifier.isDarkMode ? darkTheme : lightTheme,
              onGenerateRoute: Routes.onGenerateRoute,
              home: Consumer<AuthState>(builder: (context, state, child) {
                if (state.initialized) {
                  if (state.client != null) {
                    return const DashboardPage();
                  } else {
                    return const LoginPage();
                  }
                } else if (state.loginError) {
                  return const LoginPage();
                } else {
                  return Scaffold(
                    body: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: const CircularProgressIndicator()))));
                }
              })
            );
          }
        ));
  }
}
