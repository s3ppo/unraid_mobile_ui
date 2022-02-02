import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<LoginPage> {
  final myServer = TextEditingController();
  final myEmail = TextEditingController();
  final myPw = TextEditingController();

  @override
  void initState() {
    super.initState();
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
              keyboardType: TextInputType.emailAddress,
              controller: myEmail,
              decoration: const InputDecoration(
                  labelText: 'Server IP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.dns)),
            )),
        Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              controller: myEmail,
              decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person)),
            )),
        Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            alignment: Alignment.center,
            child: TextField(
              controller: myPw,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock)),
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
                onPressed: () => loginUser())),
      ])),
    ));
  }

  loginUser() async {}
}
