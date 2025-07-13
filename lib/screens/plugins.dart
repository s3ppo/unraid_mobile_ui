import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/queries.dart';
import 'package:unmobile/notifiers/auth_state.dart';

class PluginsPage extends StatefulWidget {
  const PluginsPage({Key? key}) : super(key: key);

  @override
  _MyPluginsPageState createState() => _MyPluginsPageState();
}

class _MyPluginsPageState extends State<PluginsPage> {
  AuthState? _state;
  Future<QueryResult>? _plugins;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    getPlugins();
  }

  getPlugins() {
    _state!.client!.resetStore();

    _plugins = _state!.client!.query(QueryOptions(
      document: gql(Queries.getPlugins),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugins'),
          actions: <Widget>[],
          elevation: 0,
        ),
        body: Container(child: showPluginsContent()));
  }

  Widget showPluginsContent() {
    return FutureBuilder<QueryResult>(
        future: _plugins,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final result = snapshot.data!;

            List plugins = result.data?['plugins'] ?? [];

            return ListView.builder(
                itemCount: plugins.length,
                itemBuilder: (context, index) {
                  Map plugin = plugins[index];
                  return ListTile(
                      leading: const Icon(Icons.extension),
                      title: Text(plugin['name']),
                      subtitle: Text('Version: ${plugin['version']}')
                      
                      );
                });
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }
}
