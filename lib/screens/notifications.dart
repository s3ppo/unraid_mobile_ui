import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/queries.dart';
import 'package:unmobile/notifiers/auth_state.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _MyNotificationPageState createState() => _MyNotificationPageState();
}

class _MyNotificationPageState extends State<NotificationPage> {
  AuthState? _state;
  Future<QueryResult>? _notifications;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    if(_state!.client != null) {
      _state!.client!.resetStore();
      getNotifications();
    }
  }

  void getNotifications() {
    dynamic filter = {"limit": 100, "offset": 0, "type": "UNREAD"};
    _notifications = _state!.client!.query(QueryOptions(
        document: gql(Queries.getNotifications),
        variables: {"filter": filter}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: <Widget>[],
          elevation: 0,
        ),
        body: Container(child: showNotificationContent()));
  }

  Widget showNotificationContent() {
    return FutureBuilder<QueryResult>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final result = snapshot.data!;

            // Extract the data from the result
            List notifications = result.data!['notifications']['list'];

            return ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const Divider(thickness: 0.5),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                      title: Text(notification['title'] ?? 'No Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notification['subject'] ?? '<empty>',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['description'] ?? '<empty>',
                            maxLines: null,
                            softWrap: true,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            notification['timestamp'] != null
                                ? DateTime.tryParse(
                                            notification['timestamp']) !=
                                        null
                                    ? "${MaterialLocalizations.of(context).formatMediumDate(DateTime.parse(notification['timestamp']))} "
                                        "${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.parse(notification['timestamp'])), alwaysUse24HourFormat: false)}"
                                    : notification['timestamp']
                                : '<empty>',
                          )
                        ],
                      ));
                });
          } else {
            return const Center(child: Text('No notifications available'));
          }
        });
  }
}
