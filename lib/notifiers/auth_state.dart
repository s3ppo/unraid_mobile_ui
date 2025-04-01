import 'dart:core';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  String msg;
  AuthException(this.msg);
}

class AuthState extends ChangeNotifier {
  
  late SharedPreferences storage;
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
    storage = await SharedPreferences.getInstance();
    await getPackageInfos();
    String? token = await storage.getString('token');
    String? ip = await storage.getString('ip');
    String? prot = await storage.getString('prot');
    if (token != null && ip != null && prot != null) {
      await connectUnraid(token: token, ip: ip, prot: prot);
    }
    _initialized = true;
    notifyListeners();
  }

  connectUnraid({ required String token, required String ip, required String prot }) async {
    String endPoint;
    if (prot == 'https') {
      endPoint = 'https://$ip/graphql';
    } else {
      endPoint = 'http://$ip/graphql';
    }
    var link = HttpLink(endPoint, defaultHeaders: {
      'Origin': packageName,
      'Authorization': 'bearer $token',
      'x-api-key': token
    });
    try {
      _client = ValueNotifier(GraphQLClient(link: link, cache: GraphQLCache()));
      // Test the connection by making a simple query
      final result = await _client!.value.query(
      QueryOptions(document: gql("""
        query Me {
          me {
            id
          }
        }
      """)),
      );
      if (result.hasException) {
        throw AuthException('Connection failed');
      }
    } catch (e) {
      _client = null;
      throw AuthException('Connection failed');
    }

    await storage.setString('token', token);
    await storage.setString('ip', ip);
    await storage.setString('prot', prot);

    notifyListeners();
  }

  logout() async {
    await storage.remove('token');
    await storage.remove('ip');
    await storage.remove('prot');
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
