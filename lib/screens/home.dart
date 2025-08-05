import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/queries.dart';
import 'package:unmobile/notifiers/auth_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unmobile/global/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  AuthState? _state;
  Future<QueryResult>? _unreadNotifications;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    getNotifications();
  }

  void getNotifications() {
    _unreadNotifications = _state!.client!.query(QueryOptions(
      document: gql(Queries.getNotificationsUnread),
      queryRequestTimeout: const Duration(seconds: 30),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('unMobile'),
          actions: <Widget>[
            showNotificationsButton(),
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => doLogout())
          ],
          elevation: 0,
        ),
        body: Column(children: [showListContent()]));
  }

  Widget showListContent() {
    return Expanded(
        child: ListView(children: [
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.server),
        title: const Text('System'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.system);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.hardDrive),
        title: const Text('Array'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.array);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.folder),
        title: const Text('Shares'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.shares);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.docker),
        title: const Text('Dockers'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.dockers);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.desktop),
        title: const Text('Virtual machines'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.vms);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.puzzlePiece),
        title: const Text('Plugins'),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.plugins);
        },
      )
    ]));
  }

  Widget showNotificationsButton() {
    return FutureBuilder<QueryResult>(
        future: _unreadNotifications,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => navigateNotifications());
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final result = snapshot.data!;
            int unreadTotalCount =
                result.data!['notifications']['overview']['unread']['total'];

            return IconButton(
                onPressed: () => navigateNotifications(),
                icon: unreadTotalCount > 0
                    ? const Badge(
                        smallSize: 10,
                        largeSize: 10,
                        backgroundColor: Colors.green,
                        alignment: AlignmentDirectional.bottomStart,
                        child: Icon(Icons.notifications),
                      )
                    : Icon(Icons.notifications));
          } else {
            return IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => getNotifications());
          }
        });
  }

  void navigateNotifications() {
    //Navigator.of(context).pushNamed(Routes.notifications);
  }

  void doLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Do you really want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _state!.logout();
              },
            ),
          ],
        );
      },
    );
  }
}
