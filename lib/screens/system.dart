import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';
import 'package:unraid_ui/global/routes.dart';

class SystemPage extends StatefulWidget {
  const SystemPage({Key? key}) : super(key: key);

  @override
  _MySystemPageState createState() => _MySystemPageState();
}

class _MySystemPageState extends State<SystemPage> {
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
              title: const Text('System'),
              actions: <Widget>[
                IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _state!.logout())
              ],
              elevation: 0,
            ),
            body: Container(child: showSystemContent())));
  }

  Widget showSystemContent() {
    String readAllInfo = """
      query {
        info {
          cpu {
            manufacturer
            brand
            vendor
            family
            model
            stepping
            revision
            voltage
            speed
            speedmin
            speedmax
            threads
            cores
            processors
            socket
            cache
          }
          baseboard {
            manufacturer
            model
            version
            serial
            assetTag
          }
          os {
            platform
            distro
            release
            codename
            kernel
            arch
            hostname
            codepage
            logofile
            serial
            build
            uptime
          }
          memory {
            max
            total
            free
            used
            active
            available
            buffcache
            swaptotal
            swapused
            swapfree
          }
        }
      }
     """;
    return Query(
        options: QueryOptions(
          document: gql(readAllInfo),
          queryRequestTimeout: const Duration(seconds: 30),
        ),
        builder: (QueryResult? result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result!.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Center(
                child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const CircularProgressIndicator()));
          }

          // Extract the data from the result
          Map cpu = result.data!['info']['cpu'];
          Map baseboard = result.data!['info']['baseboard'];
          Map os = result.data!['info']['os'];
          Map memory = result.data!['info']['memory'];

          // Remove keys that start with '_'
          cpu.removeWhere((key, value) => key.startsWith('_'));
          baseboard.removeWhere((key, value) => key.startsWith('_'));
          os.removeWhere((key, value) => key.startsWith('_'));
          memory.removeWhere((key, value) => key.startsWith('_'));

          return ListView(children: [
            ListTile(
                title: const Text('OS'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(Routes.systemOs, arguments: os);
                }),
            ListTile(
                title: const Text('Baseboard'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(Routes.systemBaseboard, arguments: baseboard);
                }),
            ListTile(
                title: const Text('CPU'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(Routes.systemCpu, arguments: cpu);
                }),
            ListTile(
                title: const Text('Memory'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(Routes.systemMemory, arguments: memory);
                })
          ]);
        });
  }
}
