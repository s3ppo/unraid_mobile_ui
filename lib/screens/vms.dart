import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

class VmsPage extends StatefulWidget {
  const VmsPage({Key? key}) : super(key: key);

  @override
  _MyVmsPageState createState() => _MyVmsPageState();
}

class _MyVmsPageState extends State<VmsPage> {
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
              title: const Text('Virtual machines'),
              actions: <Widget>[
                IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _state!.logout())
              ],
              elevation: 0,
            ),
            body: Container(child: showVmsContent())));
  }

  Widget showVmsContent() {
    String readAllDockers = """
      query Query{
        vms{domain{uuid,name,state}}
      }
    """;

    return Query(
      options: QueryOptions(
        document: gql(readAllDockers),
      ),
      builder: (QueryResult? result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result!.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return Container(
              padding: const EdgeInsets.all(10),
              child: const CircularProgressIndicator());
        }

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
                leading: running ? Icon(Icons.play_circle, color: Colors.green) : Icon(Icons.stop_circle, color: Colors.red), /*Switch(
                  value: running,
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    startStopVM(value, running, vm);
                  },
                ),*/
                title: Text(vm['name']),
              );
            });
      },
    );
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
