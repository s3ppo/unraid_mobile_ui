import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

class DockersPage extends StatefulWidget {
  const DockersPage({Key? key}) : super(key: key);

  @override
  _MyDockersPageState createState() => _MyDockersPageState();
}

class _MyDockersPageState extends State<DockersPage> {
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
              title: const Text('Dockers'),
              actions: <Widget>[
                IconButton(icon: const Icon(Icons.logout), onPressed: () => _state!.logout())
              ],
              elevation: 0,
            ),
            body: Container(child: showDockersContent())));
  }

  Widget showDockersContent() {
    String readAllDockers = """
      query Query{
        docker { containers { id,names,image,state,status } } 
      }
     """;

    return Query(
      options: QueryOptions(
        document: gql(readAllDockers),
      ),
      builder: (QueryResult? result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result!.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return Container(
              padding: const EdgeInsets.all(10), child: const CircularProgressIndicator());
        }

        List dockers = result.data!['docker']['containers'];

        return ListView.builder(
            itemCount: dockers.length,
            itemBuilder: (context, index) {
              final docker = dockers[index];
              bool running = false;
              if (docker['state'] == 'RUNNING') {
                running = true;
              }

              return ListTile(
                leading: running ? Icon(Icons.play_circle, color: Colors.green) : Icon(Icons.stop_circle, color: Colors.red),
                /*Switch(
                  value: running,
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    startStopDocker(value, running, docker);
                  },*/
                title: Text(docker['image'])
              );
            });
      },
    );
  }

  startStopDocker(bool value, bool running, Map docker) {
    if (value) {
      running = true;
    } else {
      running = false;
    }
    setState(() {});
  }
}
