import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unmobile/global/queries.dart';
import 'package:unmobile/notifiers/auth_state.dart';

class SharesPage extends StatefulWidget {
  const SharesPage({Key? key}) : super(key: key);

  @override
  _MySharesPageState createState() => _MySharesPageState();
}

class _MySharesPageState extends State<SharesPage> {
  AuthState? _state;
  Future<QueryResult>? _shares;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
    if(_state!.client != null) {
      _state!.client!.resetStore();
      getShares();
    }
  }

  void getShares() {
    _shares = _state!.client!.query(QueryOptions(
      document: gql(Queries.getShares),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Shares'),
          actions: <Widget>[],
          elevation: 0,
        ),
        body: showSharesContent());
  }

  Widget showSharesContent() {
    return FutureBuilder<QueryResult>(
        future: _shares,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.data != null) {
            final result = snapshot.data!;

            List shares = result.data!['shares'];
            shares.sort((a, b) => a['name']
                .toString()
                .toLowerCase()
                .compareTo(b['name'].toString().toLowerCase()));

            return ListView.builder(
                itemCount: shares.length,
                itemBuilder: (context, index) {
                  final share = shares[index];

                  double size = share['free'] / 1024 / 1024;
                  int sizeGB = size.round();

                  Color iconColor = Colors.red;
                  if (share['color'] == 'green-on') {
                    iconColor = Colors.green;
                  } else if (share['color'] == 'yellow-on') {
                    iconColor = Colors.yellow;
                  } else if (share['color'] == 'red-on') {
                    iconColor = Colors.red;
                  }

                  return ListTile(
                      title: Text(share['name']),
                      subtitle: Text(share['comment'] ?? ''),
                      trailing: Text('Free: $sizeGB GB'),
                      leading: Icon(FontAwesomeIcons.solidCircle,
                          size: 15, color: iconColor));
                });
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }
}
