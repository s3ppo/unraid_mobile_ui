import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/drawer.dart';
import 'package:unmobile/global/queries.dart';
import 'package:unmobile/notifiers/auth_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unmobile/global/routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _MyDashboardPageState createState() => _MyDashboardPageState();
}

class _MyDashboardPageState extends State<DashboardPage> {
  AuthState? _state;
  Future<QueryResult>? _unreadNotifications;
  Future<QueryResult>? _servercard;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    getNotifications();
    getServer();
  }

  void getNotifications() {
    _unreadNotifications = _state!.client!.query(QueryOptions(
      document: gql(Queries.getNotificationsUnread),
    ));
  }

  void getServer() {
    _servercard = _state!.client!.query(QueryOptions(
      document: gql(Queries.getServerCard),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('unMobile'),
          actions: <Widget>[Padding(padding: const EdgeInsets.only(right: 8.0), child: showNotificationsButton())],
          elevation: 0,
        ),
        body: Column(children: [showListContent()]),
        drawer: MyDrawer());
  }

  Widget showListContent() {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder<QueryResult>(
          future: _servercard,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const SizedBox.shrink();
            } else if (snapshot.hasData && snapshot.data!.data != null) {
              final server = snapshot.data!.data!['server'];
              final vars = snapshot.data!.data!['vars'];
              final info = snapshot.data!.data!['info'];

              return Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.server),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(server['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    fontSize: 16,
                                  )),
                              Text('Version: ${vars['version']}'),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Divider(),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Center(
                                child: const FaIcon(FontAwesomeIcons.plug,
                                    size: 16)),
                          ),
                          const SizedBox(width: 8),
                          Text('Status: '),
                          Text( server['status'],
                            style: TextStyle(
                              color: server['status'] == 'ONLINE'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                        Row(children: [
                        SizedBox(
                          width: 24,
                          child: Center(
                            child: const FaIcon(FontAwesomeIcons.clock,
                              size: 16)),
                        ),
                        const SizedBox(width: 8),
                        Text('Uptime: '),
                        Builder(
                          builder: (context) {
                          final isoTimestamp = info['os']['uptime'];
                          final dateTime = DateTime.tryParse(isoTimestamp);
                          if (dateTime == null) {
                            return Text('Unbekannt');
                          }
                          final duration = DateTime.now().difference(dateTime);
                          String formatted;
                          if (duration.inDays > 0) {
                            formatted = '${duration.inDays} days ${duration.inHours % 24} hours';
                          } else if (duration.inHours > 0) {
                            formatted = '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
                          } else {
                            formatted = '${duration.inMinutes} minutes';
                          }
                          return Text(formatted);
                          },
                        ),
                        ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        SizedBox(
                          width: 24,
                          child: Center(
                            child:
                                FaIcon(FontAwesomeIcons.networkWired, size: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Lan IP: '),
                        Text(server['lanip']),
                      ]),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ));
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
                    ? Badge(
                        smallSize: 10,
                        largeSize: 10,
                        backgroundColor: Colors.green,
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
    Navigator.of(context).pushNamed(Routes.notifications);
  }
}
