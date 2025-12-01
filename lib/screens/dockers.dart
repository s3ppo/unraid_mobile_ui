import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/mutations.dart';
import 'package:unmobile/l10n/app_localizations.dart';
import 'package:unmobile/notifiers/auth_state.dart';
import 'package:unmobile/global/queries.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';

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
    if(_state!.client != null) {
      _state!.client!.resetStore();
      getAllDockers();
    }
  }

  void getAllDockers() async {
    _allDockers = _state!.client!.query(QueryOptions(
      document: gql(Queries.getDockers),
      queryRequestTimeout: const Duration(seconds: 60),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.dockerContainerTitle),
          actions: <Widget>[],
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
                  String name = docker['names'][0];

                  if (name.startsWith('/')) {
                    name = name.substring(1);
                  }

                  return ListTile(
                      onTap: () {
                        showAdaptiveActionSheet(
                          context: context,
                          title: Text(name),
                          actions: <BottomSheetAction>[
                            BottomSheetAction(
                              title: running
                                  ? Text(AppLocalizations.of(context)!.stop)
                                  : Text(AppLocalizations.of(context)!.start),
                              onPressed: (_) async {
                                Navigator.of(context).pop();
                                docker = await startStopDocker(running, docker);
                                setState(() {});
                              },
                            )
                          ],
                          cancelAction:
                              CancelAction(title: Text(AppLocalizations.of(context)!.cancel)),
                        );
                      },
                      leading:
                          docker['labels']['net.unraid.docker.icon'] != null &&
                                  docker['labels']['net.unraid.docker.icon']
                                      .toString()
                                      .startsWith('http')
                              ? Image.network(
                                  docker['labels']['net.unraid.docker.icon'],
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported),
                                )
                              : const Icon(Icons.image_not_supported),
                      title: Text(name),
                        subtitle: Row(children: [
                        Icon(
                          running
                            ? FontAwesomeIcons.play
                            : FontAwesomeIcons.stop,
                          color: running ? Colors.green : Colors.red,
                          size: 16),
                        const SizedBox(width: 4),
                        Text(docker['state'] == 'RUNNING'
                          ? 'Running'
                          : 'Stopped'),
                        const SizedBox(width: 10),
                        if (docker['status'] != null && docker['status'].toString().contains('healthy')) ...[
                            const Text('- healthy'),
                            const SizedBox(width: 4),
                            const Icon(FontAwesomeIcons.heartPulse, size: 12),
                          ]
                      ]));
                });
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }

  Future<Map> startStopDocker(bool running, Map docker) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    if (docker['id'].contains(':')) {
      docker['id'] = docker['id'].split(':')[1];
    }

    QueryResult result;
    try {
      if (running) {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.stopDocker),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "dockerId": "${docker['id']}",
            }));
        docker['state'] = result.data!['docker']['stop']['state'];
      } else {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.startDocker),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "dockerId": "${docker['id']}",
            }));
        docker['state'] = result.data!['docker']['start']['state'];
      }
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Align(
              alignment: Alignment.center,
              child: running ? Text('Docker stopped') : Text('Docker started')),
          duration: const Duration(seconds: 3)));
    } catch (e) {
      // Error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Align(alignment: Alignment.center, child: Text('Failed')),
        duration: const Duration(seconds: 3),
      ));
    }

    Navigator.of(context).pop();

    return docker;
  }
}
