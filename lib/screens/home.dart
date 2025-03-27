import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../global/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
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
              title: const Text('Unraid mobile'),
              actions: <Widget>[
                IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _state!.logout())
              ],
              elevation: 0,
            ),
            body: Column(children: [showListContent()])));
  }

  Widget showListContent() {
    return Expanded(
        child: ListView(children: [
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.hardDrive),
        title: const Text('Array'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.array);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.folder),
        title: const Text('Shares'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.shares);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.docker),
        title: const Text('Dockers'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.dockers);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.desktop),
        title: const Text('Virtual machines'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.vms);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.puzzlePiece),
        title: const Text('Plugins'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.plugins);
        },
      )
    ]));
  }
}
