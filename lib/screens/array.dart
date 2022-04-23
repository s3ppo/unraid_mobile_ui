import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

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
                IconButton(icon: const Icon(Icons.logout), onPressed: () => _state!.logout())
              ],
              elevation: 0,
            ),
            body: showDockersContent()));
  }

  Widget showDockersContent() {
    String readAllDockers = """
      query Query{
          array {
            boot {
              name
              device
              size
              status
            }
            disks {
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
      ),
      builder: (QueryResult? result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result!.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return Container(
              padding: const EdgeInsets.all(10), child: const CircularProgressIndicator());
        }

        Map boots = result.data!['array']['boot'];
        List disks = result.data!['array']['disks'];

        return ListView.builder(
            itemCount: disks.length,
            itemBuilder: (context, index) {
              final disk = disks[index];
              Icon icon;
              if (disk['status'] == 'DISK_OK') {
                icon = const Icon(FontAwesomeIcons.circleDot, color: Colors.green);
              } else {
                icon = const Icon(FontAwesomeIcons.circleDot, color: Colors.red);
              }

              double size = disk['size'] / 1024 / 1024 / 1024;
              int sizeTB = size.round();

              return ListTile(
                  leading: icon,
                  title: Text(disk['name']),
                  trailing: Text(sizeTB.toString() + ' TB'));
            });
      },
    );
  }
}
