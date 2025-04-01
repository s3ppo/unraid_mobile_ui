import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

class BaseboardPage extends StatefulWidget {
  final Map baseboard;
  const BaseboardPage({Key? key, required this.baseboard}) : super(key: key);

  @override
  _MyBaseboardPageState createState() => _MyBaseboardPageState();
}

class _MyBaseboardPageState extends State<BaseboardPage> {
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
          title: const Text('Baseboard'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _state!.logout())
          ],
          elevation: 0,
        ),
        body: Container(child: showListContent()));
  }

  Widget showListContent() {
    return ListView(
      children: widget.baseboard.entries.map((entry) {
        return ListTile(
          title: Text(entry.key),
          trailing: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              entry.value.toString(),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        );
      }).toList(),
    );
  }
}
