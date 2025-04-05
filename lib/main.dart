import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/global/globals.dart';
import 'package:unraid_ui/global/notifiers.dart';
import 'package:unraid_ui/global/routes.dart';
import 'package:unraid_ui/screens/home.dart';
import 'package:unraid_ui/screens/login.dart';
import 'notifiers/auth_state.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: MaterialApp(
          title: 'Unraid Mobile',
          debugShowCheckedModeBanner: false,
            theme: ThemeData(
                tabBarTheme: TabBarTheme(
                    indicatorColor: Colors.white, labelColor: Colors.white),
                    indicatorColor: Colors.orange,
                    switchTheme: SwitchThemeData(
                      thumbColor: WidgetStateProperty.all(Colors.orange),
                      trackColor: WidgetStateProperty.all(Colors.white),
                      trackOutlineColor: WidgetStateProperty.all(Colors.black),
                      overlayColor: WidgetStateProperty.all(Colors.black),
                    ),
                inputDecorationTheme: InputDecorationTheme(
                  floatingLabelStyle: TextStyle(color: Colors.deepOrange),
                  border: OutlineInputBorder(),
                  focusColor: Colors.orange,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
                progressIndicatorTheme:
                    ProgressIndicatorThemeData(color: Colors.orange),
                appBarTheme: AppBarTheme(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black),
                primarySwatch: Colors.orange,
                primaryColor: Colors.orange,
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white)),
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
          }),
        ));
  }
}
