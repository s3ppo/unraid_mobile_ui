import 'dart:core';
import 'package:flutter/material.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

class AuthException implements Exception {
  String msg;
  AuthException(this.msg);
}

class AuthState extends ChangeNotifier {
  ValueNotifier<GraphQLClient>? _client;

  ValueNotifier<GraphQLClient>? get client => _client;

  AuthState() {
    init();
  }

  init() async {}

  connectUnraid({required String token, required String ip, GraphQLCache? cache}) {
    String endPoint = 'http://$ip/graphql';
    var link = HttpLink(endPoint, defaultHeaders: {
      'Authorization': 'bearer $token',
    });
    _client = ValueNotifier(GraphQLClient(link: link, cache: GraphQLCache()));
    notifyListeners();
  }
}
