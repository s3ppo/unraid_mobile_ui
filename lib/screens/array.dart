import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/mutations.dart';
import 'package:unmobile/global/queries.dart';
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
          title: const Text('Array'),
          elevation: 0,
        ),
        body: showArrayContent(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primary,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Wrap(
                  children: [
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
                    ),
                    ListTile(
                      leading: const Icon(Icons.check),
                      title: const Text('Parity Check'),
                      onTap: () {
                        Navigator.of(context).pop();
                        doSetArrayState('PARITY_CHECK');
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.menu),
        ));
  }

  Widget showArrayContent() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      /*Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8),
        child: Row(children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey), //Theme.of(context).primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onPressed: null, //() => doSetArrayState(_arrayState == 'STARTED' ? 'STOP' : 'START'),
            child: Text(_arrayState == 'STARTED' ? 'Stop' : ''),
          ),
          Container(width: 10),
            OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onPressed: null,
            child: Text('Check', style: TextStyle(color: Colors.grey)),
            ),
          Container(width: 10),
            OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onPressed: null,
            child: Text('History', style: TextStyle(color: Colors.grey)),
            ),
        ])
      ),*/
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

            return ListView.builder(
                itemCount: array.length,
                itemBuilder: (context, index) {
                  final arr = array[index];
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

                  //Total size in GB
                  double size = arr['fsSize'] / 1024 / 1024;
                  int sizeGB = size.round();
                  //Used size in GB
                  double used =
                      arr['fsUsed'] != null ? arr['fsUsed'] / 1024 / 1024 : 0;
                  double fillPercent = size > 0 ? (used / size) : 0;

                  return ListTile(
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
                      ));
                });
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

      _arrayState = result.data!['array']['setState']['state'];

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Align(alignment: Alignment.center, child: Text('Success')),
          duration: const Duration(seconds: 3)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Align(alignment: Alignment.center, child: Text('Failed')),
        duration: const Duration(seconds: 3),
      ));
    }

    Navigator.of(context).pop();
  }
}
