import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/global/unraidclient.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<LoginPage> {
  final myServer = TextEditingController();
  final myToken = TextEditingController();
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: TextField(
              controller: myServer,
              decoration: const InputDecoration(
                  labelText: 'Server IP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.dns)),
            )),
        Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: TextField(
              controller: myToken,
              decoration: const InputDecoration(
                  labelText: 'API Token',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person)),
            )),
        Container(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            alignment: Alignment.center,
            child: OutlinedButton(
                style: TextButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  minimumSize: const Size(150, 40),
                  side: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () => loginUser()))
      ])),
    ));
  }

  loginUser() async {
    _state!
        .connectUnraid(token: myToken.value.text, ip: myServer.value.text, cache: GraphQLCache());
  }
}
