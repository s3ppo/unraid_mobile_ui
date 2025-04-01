import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

class OsPage extends StatefulWidget {
  final Map os;
  const OsPage({Key? key, required this.os}) : super(key: key);

  @override
  _MyOsPageState createState() => _MyOsPageState();
}

class _MyOsPageState extends State<OsPage> {
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
          title: const Text('OS'),
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
      children: widget.os.entries.map((entry) {
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
