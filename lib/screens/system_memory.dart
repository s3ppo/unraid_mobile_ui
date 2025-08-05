import 'package:flutter/material.dart';

class MemoryPage extends StatefulWidget {
  final Map memory;
  const MemoryPage({Key? key, required this.memory}) : super(key: key);

  @override
  _MyMemoryPageState createState() => _MyMemoryPageState();
}

class _MyMemoryPageState extends State<MemoryPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Memory'),
          actions: <Widget>[
          ],
          elevation: 0,
        ),
        body: Container(child: showListContent()));
  }

  Widget showListContent() {
    return ListView(
      children: widget.memory.entries.map((entry) {
        double size = entry.value / 1024 / 1024 / 1024;
        int sizeGB = size.round();

        return ListTile(
          title: Text(entry.key),
          trailing: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              '$sizeGB GB',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        );
      }).toList(),
    );
  }
}
