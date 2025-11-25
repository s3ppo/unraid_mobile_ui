import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/mutations.dart';
import 'package:unmobile/global/queries.dart';
import 'package:unmobile/l10n/app_localizations.dart';
import 'package:unmobile/notifiers/auth_state.dart';

class ArrayPage extends StatefulWidget {
  const ArrayPage({Key? key}) : super(key: key);

  @override
  _MyArrayPageState createState() => _MyArrayPageState();
}

class _MyArrayPageState extends State<ArrayPage> {
  AuthState? _state;
  Future<QueryResult>? _array;
  String _arrayState = "";

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    if (_state!.client != null) {
      _state!.client!.resetStore();
      getArray();
    }
  }

  void getArray() {
    _state!.client!.resetStore();

    _array = _state!.client!.query(QueryOptions(
      document: gql(Queries.getArray),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.arrayTitle),
          elevation: 0,
        ),
        body: showArrayContent(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primary,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SizedBox(height: 160, child: Wrap(
                  children: [
                    SizedBox( height: 40, child: ListTile(
                      title: Text('Array Operation'),
                    )),
                    ListTile(
                      leading: const Icon(Icons.play_arrow),
                      title: const Text('Start'),
                      onTap: () {
                        Navigator.of(context).pop();
                        doSetArrayState('START');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.stop),
                      title: const Text('Stop'),
                      onTap: () {
                        Navigator.of(context).pop();
                        doSetArrayState('STOP');
                      },
                    )
                  ],
                ));
              },
            );
          },
          child: const Icon(Icons.menu),
        ));
  }

  Widget showArrayContent() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Expanded(
          child: FutureBuilder<QueryResult>(
        future: _array,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final result = snapshot.data!;

            Map boots = result.data!['array']['boot'];
            List disks = result.data!['array']['disks'];
            List parities = result.data!['array']['parities'];
            List caches = result.data!['array']['caches'];

            List array = [];
            array.addAll(disks);
            array.addAll(parities);
            array.addAll(caches);
            array.add(boots);
            _arrayState = result.data!['array']['state'] ?? "";

            // Gruppiere die Einträge nach Typ
            Map<String, List> grouped = {
              'Disks': disks,
              'Parities': parities,
              'Caches': caches,
              'Boot': [boots],
            };

            return ListView(
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Divider()
                          ],
                        )),
                    ...entry.value.map<Widget>((arr) {
                      Icon icon;
                      if (arr['status'] == 'DISK_OK') {
                        icon = const Icon(FontAwesomeIcons.solidCircle,
                            size: 15, color: Colors.green);
                      } else {
                        icon = const Icon(FontAwesomeIcons.solidCircle,
                            size: 15, color: Colors.red);
                      }

                      if (arr['fsSize'] == null) {
                        arr['fsSize'] = arr['size'];
                      }
                      if (arr['fsUsed'] == null) {
                        arr['fsUsed'] = 0;
                      }
                      if (arr['fsFree'] == null) {
                        arr['fsFree'] = 0;
                      }

                      double size = arr['fsSize'] / 1024 / 1024;
                      int sizeGB = size.round();
                      double used = arr['fsUsed'] != null
                          ? arr['fsUsed'] / 1024 / 1024
                          : 0;
                      double fillPercent = size > 0 ? (used / size) : 0;

                      return Column(
                        children: [
                          ListTile(
                            leading: icon,
                            title: Text(arr['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(arr['device']),
                                SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: fillPercent.clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    fillPercent > 0.9
                                        ? Colors.red
                                        : (fillPercent > 0.7
                                            ? Colors.orange
                                            : Colors.green),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${used.round()} GB / $sizeGB GB (${(fillPercent * 100).toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ))
    ]);
  }

  Future<void> doSetArrayState(String targetState) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      QueryResult result = await _state!.client!.mutate(MutationOptions(
          document: gql(Mutations.setArrayState),
          queryRequestTimeout: Duration(seconds: 30),
          variables: {
            "input": {"desiredState": "${targetState}"}
          }));

      if (result.hasException) {
        throw Exception(result.exception!.graphqlErrors[0].message);
      }
      _arrayState = result.data!['array']['setState']['state'];

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Align(alignment: Alignment.center, child: Text('Success')),
          duration: const Duration(seconds: 3)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Align(alignment: Alignment.center, child: Text(e.toString())),
        duration: const Duration(seconds: 3),
      ));
    }

    Navigator.of(context).pop();
  }
}
