import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<LoginPage> {
  final _myServer = TextEditingController();
  final _myToken = TextEditingController();
  String _protocol = "http";

  AuthState? _state;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
      Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topCenter,
          child: Text('Unraid UI',
              style: Theme.of(context).textTheme.headlineMedium)),
      Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: TextField(
            controller: _myServer,
            decoration: const InputDecoration(
                labelText: 'Server IP:Port',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns)),
          )),
      Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: TextField(
            controller: _myToken,
            decoration: const InputDecoration(
                labelText: 'API Token',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person)),
          )),
// Radio buttons für http/https
    Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          children: [
          Expanded(
            child: RadioListTile<String>(
            title: const Text('http'),
            value: 'http',
            groupValue: _protocol,
            onChanged: (String? value) {
              setState(() {
              _protocol = value!;
              });
            },
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
            title: const Text('https'),
            value: 'https',
            groupValue: _protocol,
            onChanged: (String? value) {
              setState(() {
              _protocol = value!;
              });
            },
            ),
          ),
          ],
        ),
        ],
      )),          
      Container(
          padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
          alignment: Alignment.center,
          child: OutlinedButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(150, 40),
                side: BorderSide(
                    width: 2.0, color: Theme.of(context).primaryColor),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              child: const Text('LOGIN',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              onPressed: () => loginUser()))
    ]))));
  }

  loginUser() async {
    try {
      await _state!
          .connectUnraid(token: _myToken.value.text, ip: _myServer.value.text, prot: _protocol);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to login'),
        duration: const Duration(seconds: 3),
      ));
    }
  }
}
