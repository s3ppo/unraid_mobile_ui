import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/notifiers/auth_state.dart';

class PluginsPage extends StatefulWidget {
  const PluginsPage({Key? key}) : super(key: key);

  @override
  _MyPluginsPageState createState() => _MyPluginsPageState();
}

class _MyPluginsPageState extends State<PluginsPage> {
  AuthState? _state;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugins'),
          actions: <Widget>[
          ],
          elevation: 0,
        ),
        body: Container(
            padding: const EdgeInsets.all(10), child: showPluginsContent()));
  }

  Widget showPluginsContent() {
    return const Center( child: Text('Sorry no plugin query available yet!'));
  }
}
