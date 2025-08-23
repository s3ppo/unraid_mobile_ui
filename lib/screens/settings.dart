import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/routes.dart';
import 'package:unmobile/notifiers/auth_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _MySettingsPageState createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<SettingsPage> {
  AuthState? _state;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    _state!.client!.resetStore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          actions: <Widget>[],
          elevation: 0,
        ),
        body: Container(child: showSettingsContent()));
  }

  Widget showSettingsContent() {
    return ListView(
      children: [
        ListTile(
          title: const Text('Multiserver Settings'),
          onTap: () {
            Navigator.pushNamed(context, Routes.settingsMultiserver);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        )
      ],
    );
  }
}
