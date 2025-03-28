import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        }
      }
     """;

    return Expanded(
        child: ListView(children: [
      ListTile(
        title: const Text('OS'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.systemOs);
        },
      ),          
      ListTile(
        title: const Text('Baseboard'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.systemBaseboard);
        },
      ),
      ListTile(
        title: const Text('CPU'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.systemCpu);
        },
      )
    ]));
  }
}
