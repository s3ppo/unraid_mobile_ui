import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/global/mutations.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';
import 'package:unraid_ui/global/queries.dart';

class DockersPage extends StatefulWidget {
  const DockersPage({Key? key}) : super(key: key);

  @override
  _MyDockersPageState createState() => _MyDockersPageState();
}

class _MyDockersPageState extends State<DockersPage> {
  AuthState? _state;
  Future<QueryResult>? _allDockers;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    getAllDockers();
  }

  getAllDockers() async {
    _state!.client!.resetStore();

    _allDockers = _state!.client!.query(QueryOptions(
      document: gql(Queries.getDockers),
      queryRequestTimeout: const Duration(seconds: 30),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dockers'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _state!.logout())
          ],
          elevation: 0,
        ),
        body: showDockersContent());
  }

  Widget showDockersContent() {
    return FutureBuilder<QueryResult>(
        future: _allDockers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final result = snapshot.data!;
            return ListView.builder(
                itemCount: result.data!['docker']['containers'].length,
                itemBuilder: (context, index) {
                  Map docker = result.data!['docker']['containers'][index];
                  bool running = docker['state'] == 'RUNNING';

                  return ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: const Text('Confirm Action'),
                                content: Text(
                                    'Are you sure you want to ${running ? 'stop' : 'start'} this container?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                      child: const Text('Confirm'),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await startStopDocker(running, docker);
                                      }),
                                ]);
                          },
                        );
                        //startStopDocker(running, docker);
                      },
                      leading: running
                          ? Icon(FontAwesomeIcons.play,
                              size: 15, color: Colors.green)
                          : Icon(FontAwesomeIcons.stop,
                              size: 15, color: Colors.red),
                      title: Text(docker['image']));
                });
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }

  startStopDocker(bool running, Map docker) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      if (running) {
        await _state!.client!.query(
            QueryOptions(document: gql(Mutations.stopDocker), variables: {
          "containerId": "${docker['id']}",
        }));
      } else {
        await _state!.client!.query(
            QueryOptions(document: gql(Mutations.startDocker), variables: {
          "containerId": "${docker['id']}",
        }));
      }
    } finally {
      Navigator.of(context).pop(); // Remove the spinner
    }

    getAllDockers();
    setState(() {});
  }
}
