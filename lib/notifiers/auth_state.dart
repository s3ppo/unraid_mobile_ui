import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthException implements Exception {
  String msg;
  AuthException(this.msg);
}

class AuthState extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  ValueNotifier<GraphQLClient>? _client;
  bool _initialized = false;
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  ValueNotifier<GraphQLClient>? get client => _client;
  bool get initialized => _initialized;

  AuthState() {
    init();
  }

  init() async {
    await getPackageInfos();
    String? token = await storage.read(key: 'token');
    String? ip = await storage.read(key: 'ip');
    if (token != null && ip != null) {
      await connectUnraid(token: token, ip: ip);
    }
    _initialized = true;
    notifyListeners();
  }

  connectUnraid({required String token, required String ip}) async {
    String endPoint = 'http://$ip/graphql';
    var link = HttpLink(endPoint, defaultHeaders: {
      'Origin': packageName,
      'Authorization': 'bearer $token',
      'x-api-key': token
    });
    try {
      _client = ValueNotifier(GraphQLClient(link: link, cache: GraphQLCache()));
      // Test the connection by making a simple query
      final result = await _client!.value.query(
      QueryOptions(document: gql('{ __typename }')),
      );
      if (result.hasException) {
      throw AuthException('Failed to connect: ${result.exception.toString()}');
      }
    } catch (e) {
      _client = null;
      throw AuthException('Connection failed: $e');
    }

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

  getPackageInfos() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
}
