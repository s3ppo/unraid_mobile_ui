// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';
import 'package:fan_floating_menu/fan_floating_menu.dart';

class ArrayPage extends StatefulWidget {
  const ArrayPage({Key? key}) : super(key: key);

  @override
  _MyArrayPageState createState() => _MyArrayPageState();
}

class _MyArrayPageState extends State<ArrayPage> {
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
            title: const Text('Array'),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _state!.logout())
            ],
            elevation: 0,
          ),
          body: showDockersContent(),
          floatingActionButton: FanFloatingMenu(
            toggleButtonColor:
                Theme.of(context).floatingActionButtonTheme.backgroundColor!,
            fanMenuDirection: FanMenuDirection.rtl,
            menuItems: [
              FanMenuItem(
                  onTap: () => doStartArray(),
                  icon: Icons.play_arrow,
                  title: 'Start Array',
                  menuItemIconColor: Theme.of(context)
                      .floatingActionButtonTheme
                      .backgroundColor!),
              FanMenuItem(
                  onTap: () => doStopArray(),
                  icon: Icons.stop,
                  title: 'Stop Array',
                  menuItemIconColor: Theme.of(context)
                      .floatingActionButtonTheme
                      .backgroundColor!)
            ],
          ),
        ));
  }

  Widget showDockersContent() {
    String readAllDockers = """
      query Query{
        array {
          state
          boot {
            id
            name
            status
            size
          }
          disks {
            id
            name
            status
            size
          }
          parities {
            id
            name
            status
            size
          }
          caches {
            id
            name
            status
            size
          }
        }
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
              child: const Center(child: CircularProgressIndicator()));
        }

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
      },
    );
  }

  doStartArray() {}

  doStopArray() {}
}
