// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Unraid'),
          actions: <Widget>[
            IconButton(icon: const Icon(Icons.logout), onPressed: () => _state!.logout())
          ],
          elevation: 0,
        ),
        body: Container(child: showHomeContent()));
  }

  Widget showHomeContent() {
    String readAllDockers = """
        query Query{
          dockerContainers(all:true){id,names,image}
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
          return Container(padding: const EdgeInsets.all(10), child: CircularProgressIndicator());
        }

        List dockers = result.data!['dockerContainers'];

        return ListView.builder(
            itemCount: dockers.length,
            itemBuilder: (context, index) {
              final docker = dockers[index];

              return ListTile(
                title: Text(docker['names'][0]),
                subtitle: Text(docker['image']),
              );
            });
      },
    );
  }
}
