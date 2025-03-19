import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

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
    return GraphQLProvider(
        client: _state!.client,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Plugins'),
              actions: <Widget>[
                IconButton(icon: const Icon(Icons.logout), onPressed: () => _state!.logout())
              ],
              elevation: 0,
            ),
            body: Container()));
  }
}
