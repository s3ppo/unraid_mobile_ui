import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _state!.logout())
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
                  leading: running
                      ? Icon(FontAwesomeIcons.play,
                          size: 15, color: Colors.green)
                      : Icon(FontAwesomeIcons.stop,
                          size: 15, color: Colors.red),
                  title: Text(docker['image']));
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
