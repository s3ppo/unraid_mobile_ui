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
  Future<QueryResult>? _serverCard;
  Future<QueryResult>? _arrayCard;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    getNotifications();
    getServerCard();
    getArrayCard();
  }

  void getNotifications() {
    _unreadNotifications = _state!.client!.query(QueryOptions(
      document: gql(Queries.getNotificationsUnread),
    ));
  }

  void getServerCard() {
    _serverCard = _state!.client!.query(QueryOptions(
      document: gql(Queries.getServerCard),
    ));
  }

  void getArrayCard() {
    _arrayCard = _state!.client!.query(QueryOptions(
      document: gql(Queries.getArrayCard),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('unMobile'),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: showNotificationsButton())
          ],
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            getNotifications();
            getServerCard();
            getArrayCard();
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
          showServerCard(),
          const SizedBox(height: 8),
          showArrayCard(),
              ],
            ),
          ),
        ),
        drawer: MyDrawer());
  }

  void navigateNotifications() {
    Navigator.of(context).pushNamed(Routes.notifications);
  }

  Widget showServerCard() {
    return FutureBuilder<QueryResult>(
        future: _serverCard,
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
                        Text(
                          server['status'],
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
                            child:
                                const FaIcon(FontAwesomeIcons.clock, size: 16)),
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
                            formatted =
                                '${duration.inDays} days ${duration.inHours % 24} hours';
                          } else if (duration.inHours > 0) {
                            formatted =
                                '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
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
        });
  }

  Widget showArrayCard() {
    return FutureBuilder<QueryResult>(
        future: _arrayCard,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SizedBox.shrink();
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final array = snapshot.data!.data!['array'];

            //Total size in GB
            double size = array['capacity']['kilobytes']['total'] != null
                ? double.tryParse(array['capacity']['kilobytes']['total']
                            .toString()) !=
                        null
                    ? double.parse(array['capacity']['kilobytes']['total']
                            .toString()) /
                        1024 /
                        1024
                    : 0
                : 0;
            int sizeGB = size.round();
            //Used size in GB
            double used = array['capacity']['kilobytes']['used'] != null
                ? double.tryParse(array['capacity']['kilobytes']['used']
                            .toString()) !=
                        null
                    ? double.parse(
                            array['capacity']['kilobytes']['used'].toString()) /
                        1024 /
                        1024
                    : 0
                : 0;
            double fillPercent = size > 0 ? (used / size) : 0;
            int sizeUsedGB = used.round();

            return Card(
              elevation: 4,
              child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const FaIcon(FontAwesomeIcons.hardDrive),
                          const SizedBox(width: 16),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Array',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                      fontSize: 16,
                                    )),
                                Row(children: [
                                  Text('State: '),
                                  Text('${array['state']}',
                                      style: TextStyle(
                                        color: array['state'] == 'STARTED'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ]),
                              ]),
                        ]),
                        const SizedBox(height: 6),
                        const Divider(),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: fillPercent,
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  fillPercent > 0.85
                                      ? Colors.red
                                      : fillPercent > 0.65
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(fillPercent * 100).toStringAsFixed(1)}%',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$sizeUsedGB GB / $sizeGB GB',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ])),
            );
          } else {
            return const SizedBox.shrink();
          }
        });
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
}
