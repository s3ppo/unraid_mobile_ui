import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

class AuthException implements Exception {
  String msg;
  AuthException(this.msg);
}

class AuthState extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  ValueNotifier<GraphQLClient>? _client;

  ValueNotifier<GraphQLClient>? get client => _client;

  AuthState() {
    init();
  }

  init() async {
    String? token = await storage.read(key: 'token');
    String? ip = await storage.read(key: 'ip');
    if (token != null && ip != null) {
      connectUnraid(token: token, ip: ip);
    }
  }

  connectUnraid({required String token, required String ip}) async {
    String endPoint = 'http://$ip/graphql';
    var link = HttpLink(endPoint, defaultHeaders: {
      'Authorization': 'bearer $token',
    });
    _client = ValueNotifier(GraphQLClient(link: link, cache: GraphQLCache()));

    await storage.write(key: 'token', value: token);
    await storage.write(key: 'ip', value: ip);

    notifyListeners();
  }

  logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'ip');
    _client = null;
    notifyListeners();
  }
}
