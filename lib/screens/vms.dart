import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/mutations.dart';
import 'package:unmobile/global/queries.dart';
import 'package:unmobile/l10n/app_localizations.dart';
import 'package:unmobile/notifiers/auth_state.dart';

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
    if(_state!.client != null) {
      _state!.client!.resetStore();
      getVms();
    }
  }

  void getVms() {
    _state!.client!.resetStore();

    _vms = _state!.client!.query(QueryOptions(
      document: gql(Queries.getVms),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.virtualMachineTitle),
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
                  Icon iconVm = const Icon(FontAwesomeIcons.question,
                      size: 15, color: Colors.grey);
                  Map vm = vms[index];
                  bool running = false;
                  bool paused = false;
                  bool shutoff = false;
                  if (vm['state'] == 'RUNNING') {
                    running = true;
                    iconVm = const Icon(FontAwesomeIcons.play,
                        size: 15, color: Colors.green);
                  }
                  if (vm['state'] == 'PAUSED') {
                    paused = true;
                    iconVm = const Icon(FontAwesomeIcons.pause,
                        size: 15, color: Colors.red);
                  }
                  if (vm['state'] == 'SHUTOFF') {
                    shutoff = true;
                    iconVm = const Icon(FontAwesomeIcons.stop,
                        size: 15, color: Colors.red);
                  }
                  return ListTile(
                      onTap: () {
                        showAdaptiveActionSheet(
                          context: context,
                          title: Text(vm['name']),
                          actions: <BottomSheetAction>[
                            if (running) ...[
                              BottomSheetAction(
                                title: Text(AppLocalizations.of(context)!.stop),
                                onPressed: (_) async {
                                  Navigator.of(context).pop();
                                  vm = await commandVM('stop', vm);
                                  setState(() {});
                                },
                              ),
                              BottomSheetAction(
                                title: Text(AppLocalizations.of(context)!.forceStop),
                                onPressed: (_) async {
                                  Navigator.of(context).pop();
                                  vm = await commandVM('forceStop', vm);
                                  setState(() {});
                                },
                              ),
                              BottomSheetAction(
                                  title: Text(AppLocalizations.of(context)!.pause),
                                  onPressed: (_) async {
                                    Navigator.of(context).pop();
                                    vm = await commandVM('pause', vm);
                                    setState(() {});
                                  }),
                              BottomSheetAction(
                                title: Text(AppLocalizations.of(context)!.reboot),
                                onPressed: (_) async {
                                  Navigator.of(context).pop();
                                  vm = await commandVM('reboot', vm);
                                  setState(() {});
                                },
                              ),
                            ] else if (shutoff) ...[
                              BottomSheetAction(
                                title: Text(AppLocalizations.of(context)!.start),
                                onPressed: (_) async {
                                  Navigator.of(context).pop();
                                  vm = await commandVM('start', vm);
                                  setState(() {});
                                },
                              ),
                              /*BottomSheetAction(
                                title: const Text('Reset'),
                                onPressed: (_) async {
                                  Navigator.of(context).pop();
                                  vm = await commandVM('reset', vm);
                                  setState(() {});
                                },
                              )*/
                            ],
                            if (paused) ...[
                              BottomSheetAction(
                                title: Text(AppLocalizations.of(context)!.resume),
                                onPressed: (_) async {
                                  Navigator.of(context).pop();
                                  vm = await commandVM('resume', vm);
                                  setState(() {});
                                },
                              )
                            ]
                          ],
                          cancelAction:
                              CancelAction(title: Text(AppLocalizations.of(context)!.cancel)),
                        );
                      },
                      leading: iconVm,
                      title: Text(vm['name']));
                });
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }

  Future<Map> commandVM(String targetCommand, Map vm) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    QueryResult result;
    try {
      if (targetCommand == 'stop') {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.stopVM),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "vmId": "${vm['id']}",
            }));
        if (result.data!['vm']['stop']) {
          vm['state'] = 'SHUTOFF';
        }
      } else if (targetCommand == 'start') {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.startVM),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "vmId": "${vm['id']}",
            }));
        if (result.data!['vm']['start']) {
          vm['state'] = 'RUNNING';
        }
      } else if (targetCommand == 'pause') {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.pauseVM),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "vmId": "${vm['id']}",
            }));
        if (result.data!['vm']['pause']) {
          vm['state'] = 'PAUSED';
        }
      } else if (targetCommand == 'forceStop') {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.forceStopVM),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "vmId": "${vm['id']}",
            }));
        if (result.data!['vm']['forceStop']) {
          vm['state'] = 'SHUTOFF';
        }
      } else if (targetCommand == 'reboot') {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.rebootVM),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "vmId": "${vm['id']}",
            }));
        if (result.data!['vm']['reboot']) {
          vm['state'] = 'RUNNING';
        }
      } else if (targetCommand == 'reset') {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.resetVM),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "vmId": "${vm['id']}",
            }));
        if (result.data!['vm']['reset']) {
          vm['state'] = 'RUNNING';
        }
      } else if (targetCommand == 'resume') {
        result = await _state!.client!.mutate(MutationOptions(
            document: gql(Mutations.resumeVM),
            queryRequestTimeout: Duration(seconds: 30),
            variables: {
              "vmId": "${vm['id']}",
            }));
        if (result.data!['vm']['resume']) {
          vm['state'] = 'RUNNING';
        }
      }

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Align(alignment: Alignment.center, child: Text('Success')),
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
