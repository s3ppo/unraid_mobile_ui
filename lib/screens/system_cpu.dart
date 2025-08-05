import 'package:flutter/material.dart';

class CpuPage extends StatefulWidget {
  final Map cpu;
  const CpuPage({Key? key, required this.cpu}) : super(key: key);

  @override
  _MyCpuPageState createState() => _MyCpuPageState();
}

class _MyCpuPageState extends State<CpuPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('CPU'),
          actions: <Widget>[
          ],
          elevation: 0,
        ),
        body: Container(child: showListContent()));
  }

  Widget showListContent() {
    return ListView(
      children: widget.cpu.entries.map((entry) {
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
