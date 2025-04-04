import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/global/queries.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';
import 'package:fan_floating_menu/fan_floating_menu.dart';

class ArrayPage extends StatefulWidget {
  const ArrayPage({Key? key}) : super(key: key);

  @override
  _MyArrayPageState createState() => _MyArrayPageState();
}

class _MyArrayPageState extends State<ArrayPage> {
  AuthState? _state;
  Future<QueryResult>? _array;

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
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.logout), onPressed: () => _state!.logout())
        ],
        elevation: 0,
      ),
      body: showArrayContent(),
      floatingActionButton: FanFloatingMenu(
        toggleButtonColor:
            Theme.of(context).floatingActionButtonTheme.backgroundColor!,
        fanMenuDirection: FanMenuDirection.rtl,
        menuItems: [
          FanMenuItem(
              onTap: () => doStartArray(),
              icon: Icons.play_arrow,
              title: 'Start Array',
              menuItemIconColor:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor!),
          FanMenuItem(
              onTap: () => doStopArray(),
              icon: Icons.stop,
              title: 'Stop Array',
              menuItemIconColor:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor!)
        ],
      ),
    );
  }

  Widget showArrayContent() {
    return FutureBuilder<QueryResult>(
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

                double size = arr['size'] / 1024 / 1024;
                int sizeGB = size.round();

                return ListTile(
                    leading: icon,
                    title: Text(arr['name']),
                    trailing: Text('Size: $sizeGB GB'));
              });
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  doStartArray() {}

  doStopArray() {}
}
