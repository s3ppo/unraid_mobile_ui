import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/global/notifiers.dart';
import 'package:unraid_ui/global/routes.dart';
import 'package:unraid_ui/screens/home.dart';
import 'package:unraid_ui/screens/login.dart';
import 'notifiers/auth_state.dart';

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
          title: 'Unraid UI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme:
                const AppBarTheme(backgroundColor: Colors.orange, foregroundColor: Colors.black),
            primarySwatch: Colors.orange,
            primaryColor: Colors.orange,
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.grey, foregroundColor: Colors.white),
          ),
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
