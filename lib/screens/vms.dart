import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/global/mutations.dart';
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
          actions: <Widget>[],
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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text(vm['name']),
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
                                      await startStopVM(running, vm);
                                      setState(() {});
                                    }),
                              ]);
                        },
                      );
                    },
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

  Future<Map> startStopVM(bool running, Map vm) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    QueryResult result;
    try {
      if (running) {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.stopVM),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "vmId": "${vm['id']}",
            }));
        vm['state'] = result.data!['vms']['stop']['state'];
      } else {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.startVM),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "vmId": "${vm['id']}",
            }));
        vm['state'] = result.data!['vms']['start']['state'];
      }
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Align(
              alignment: Alignment.center,
              child: running ? Text('VM stopped') : Text('VM started')),
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

    return vm;
  }
}
