import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        queryRequestTimeout: const Duration(seconds: 30),
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
                leading: running
                    ? Icon(FontAwesomeIcons.play, size: 15, color: Colors.green)
                    : Icon(FontAwesomeIcons.stop, size: 15, color: Colors.red),
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
