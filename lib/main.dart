import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/global/notifiers.dart';
import 'package:unraid_ui/global/routes.dart';
import 'package:unraid_ui/screens/home.dart';
import 'package:unraid_ui/screens/login.dart';
import 'notifiers/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeStr = await rootBundle.loadString('assets/themes/default.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(MyApp(theme: theme));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.theme}) : super(key: key);
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: MaterialApp(
          title: 'Unraid Mobile',
          debugShowCheckedModeBanner: false,
          theme: theme,
          onGenerateRoute: Routes.onGenerateRoute,
          home: Consumer<AuthState>(builder: (context, state, child) {
            if (state.initialized) {
              if (state.client != null) {
                return const HomePage();
              } else {
                return const LoginPage();
              }
            } else {
              return Scaffold(
                  body: Center(
                      child: SingleChildScrollView(
                          child: Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: const CircularProgressIndicator()))));
            }
          })
        ));
  }
}
