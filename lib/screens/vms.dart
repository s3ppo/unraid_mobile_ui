import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/global/queries.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

class VmsPage extends StatefulWidget {
  const VmsPage({Key? key}) : super(key: key);

  @override
  _MyVmsPageState createState() => _MyVmsPageState();
}

class _MyVmsPageState extends State<VmsPage> {
  AuthState? _state;
  Future<QueryResult>? _vms;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    getVms();
  }

  getVms() {
    _state!.client!.resetStore();

    _vms = _state!.client!.query(QueryOptions(
      document: gql(Queries.getVms),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Virtual machines'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _state!.logout())
          ],
          elevation: 0,
        ),
        body: Container(child: showVmsContent()));
  }

  Widget showVmsContent() {
    return FutureBuilder<QueryResult>(
        future: _vms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final result = snapshot.data!;

            List vms = result.data!['vms']['domain'];

            return ListView.builder(
                itemCount: vms.length,
                itemBuilder: (context, index) {
                  final vm = vms[index];
                  bool running = false;
                  if (vm['state'] == 'RUNNING') {
                    running = true;
                  }

                  return ListTile(
                    leading: running
                        ? Icon(FontAwesomeIcons.play,
                            size: 15, color: Colors.green)
                        : Icon(FontAwesomeIcons.stop,
                            size: 15, color: Colors.red),
                    title: Text(vm['name']),
                  );
                });
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }

  startStopVM(bool value, bool running, Map vm) {
    if (value) {
      running = true;
    } else {
      running = false;
    }
    setState(() {});
  }
}
