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
    getArray();
  }

  getArray() {
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
        body: showArrayContent());
  }

  Widget showArrayContent() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
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
        ]),
      ),
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

            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _arrayState = result.data!['array']['state'];
              });
            });

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

                  double size = arr['size'] / 1024 / 1024;
                  int sizeGB = size.round();

                  return ListTile(
                      leading: icon,
                      title: Text(arr['name']),
                      subtitle: Text(arr['device']),
                      trailing: Text('Size: $sizeGB GB'));
                });
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ))
    ]);
  }

  doSetArrayState( String targetState ) async {

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

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Align(
              alignment: Alignment.center,
              child: Text('Success')),
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
  }
}
