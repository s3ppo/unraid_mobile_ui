import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unraid_ui/notifiers/auth_state.dart';

class SharesPage extends StatefulWidget {
  const SharesPage({Key? key}) : super(key: key);

  @override
  _MySharesPageState createState() => _MySharesPageState();
}

class _MySharesPageState extends State<SharesPage> {
  AuthState? _state;

  @override
  void initState() {
    super.initState();
    _state = Provider.of<AuthState>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: _state!.client,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Shares'),
              actions: <Widget>[
                IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _state!.logout())
              ],
              elevation: 0,
            ),
            body: Container(child: showSharesContent())));
  }

  Widget showSharesContent() {
    String readAllShares = """
      query Query {
        shares {
          name
          free
          used
          size
          include
          exclude
          cache
          nameOrig
          comment
          allocator
          splitLevel
          floor
          cow
          color
          luksStatus
        }
      }
     """;

    return Query(
      options: QueryOptions(
        document: gql(readAllShares),
        queryRequestTimeout: Duration(seconds: 30),
      ),
      builder: (QueryResult? result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result!.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return Container(
              padding: const EdgeInsets.all(10),
              child: const CircularProgressIndicator());
        }

        List shares = result.data!['shares'];
        shares.sort((a, b) => a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase()));

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
                  title: Text(share['name']), trailing: Text('Free: $sizeGB GB'),
                  leading: Icon(FontAwesomeIcons.solidCircle, size: 15, color: iconColor)
                  );

            });
      },
    );
  }

}
