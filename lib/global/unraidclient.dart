import 'package:graphql/client.dart';

class UnraidClient {
  // The instance of GraphQLClient
  late GraphQLClient _client;

  GraphQLClient get client => _client;

  UnraidClient({required String token, required String ip, GraphQLCache? cache}) {
    String endPoint = 'http://$ip/graphql';
    var link = HttpLink(endPoint, defaultHeaders: {
      'Authorization': 'bearer $token',
    });
    _client = GraphQLClient(link: link, cache: cache ?? GraphQLCache());
  }

  // Make a raw query by passing the query definition inside a query
  Future<Map<String, dynamic>> rawQuery(
      {required String queryDefinition,
      Map<String, dynamic> variable = const {},
      String? queryName}) async {
    var query = QueryOptions(document: gql(queryDefinition), variables: variable);
    var response = await _client.query(query);
    if (response.hasException) {
      throw Exception(response.exception);
    }
    if (queryName != null) {
      return response.data![queryName]!;
    }
    return response.data!;
  }
}
