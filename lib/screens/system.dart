import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/queries.dart';
import 'package:unmobile/notifiers/auth_state.dart';
import 'package:unmobile/global/routes.dart';

class SystemPage extends StatefulWidget {
  const SystemPage({Key? key}) : super(key: key);

  @override
  _MySystemPageState createState() => _MySystemPageState();
}

class _MySystemPageState extends State<SystemPage> {
  AuthState? _state;
  Future<QueryResult>? _info;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    _state!.client!.resetStore();
    getInfo();
  }

  void getInfo() {
    _state!.client!.resetStore();

    _info = _state!.client!.query(QueryOptions(
      document: gql(Queries.getInfo),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('System'),
          actions: <Widget>[
          ],
          elevation: 0,
        ),
        body: Container(child: showSystemContent()));
  }

  Widget showSystemContent() {
    return FutureBuilder<QueryResult>(
        future: _info,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final result = snapshot.data!;

            // Extract the data from the result
            Map cpu = result.data!['info']['cpu'];
            Map baseboard = result.data!['info']['baseboard'];
            Map os = result.data!['info']['os'];
            Map memory = result.data!['info']['memory'];

            // Remove keys that start with '_'
            cpu.removeWhere((key, value) => key.startsWith('_'));
            baseboard.removeWhere((key, value) => key.startsWith('_'));
            os.removeWhere((key, value) => key.startsWith('_'));
            memory.removeWhere((key, value) => key.startsWith('_'));

            return ListView(children: [
              ListTile(
                  title: const Text('OS'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(Routes.systemOs, arguments: os);
                  }),
              ListTile(
                  title: const Text('Baseboard'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.systemBaseboard,
                        arguments: baseboard);
                  }),
              ListTile(
                  title: const Text('CPU'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(Routes.systemCpu, arguments: cpu);
                  }),
              ListTile(
                  title: const Text('Memory'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(Routes.systemMemory, arguments: memory);
                  })
            ]);
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }
}
