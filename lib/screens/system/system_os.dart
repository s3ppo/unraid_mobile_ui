import 'package:flutter/material.dart';

class OsPage extends StatefulWidget {
  final Map os;
  const OsPage({Key? key, required this.os}) : super(key: key);

  @override
  _MyOsPageState createState() => _MyOsPageState();
}

class _MyOsPageState extends State<OsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('OS'),
          actions: <Widget>[
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
