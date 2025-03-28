import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

class CpuPage extends StatefulWidget {
  const CpuPage({Key? key}) : super(key: key);

  @override
  _MyCpuPageState createState() => _MyCpuPageState();
}

class _MyCpuPageState extends State<CpuPage> {
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
              title: const Text('OS'),
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

    ]));
  }
}
