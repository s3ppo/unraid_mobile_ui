import 'dart:core';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unraid_ui/global/globals.dart';
import 'package:unraid_ui/global/queries.dart';

class AuthException implements Exception {
  String msg;
  AuthException(this.msg);
}

class AuthState extends ChangeNotifier {
  late SharedPreferences storage;
  //ValueNotifier<GraphQLClient>? _client;
  GraphQLClient? _client;
  bool _initialized = false;
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  String _connectVersion = "";

  //ValueNotifier<GraphQLClient>? get client => _client;
  GraphQLClient? get client => _client;
  String get connectVersion => _connectVersion;
  bool get initialized => _initialized;

  AuthState() {
    init();
  }

  init() async {
    storage = await SharedPreferences.getInstance();
    await getPackageInfos();

    String? token = storage.getString('token');
    String? ip = storage.getString('ip');
    String? prot = storage.getString('prot');

    if (token != null && ip != null && prot != null) {
      try {
        await connectUnraid(token: token, ip: ip, prot: prot);
      } on AuthException catch (e) {
        _initialized = true;
        logout();
        throw AuthException(e.msg);
      }
    }

    _initialized = true;
    notifyListeners();
  }

  connectUnraid(
      {required String token, required String ip, required String prot}) async {
    String endPoint;
    if (prot == 'https') {
      endPoint = 'https://$ip/graphql';
    } else {
      endPoint = 'http://$ip/graphql';
    }
    var link = HttpLink(endPoint,
        defaultHeaders: {'Origin': packageName, 'x-api-key': token});

    _client = GraphQLClient(link: link, cache: GraphQLCache());
    // Test the connection by making a simple query
    final result =
        await _client!.query(QueryOptions(document: gql(Queries.getServices)));
    if (result.hasException) {
      logout();
      throw AuthException('Connection failed');
    }

    for (var service in result.data!['services']) {
      if (service['name'] == 'unraid-api') {
        _connectVersion = service['version'];
      }
      break;
    }

    if (Version.parse(_connectVersion) <
        Version.parse(Globals.minConnectVersion)) {
      logout();
      throw AuthException(
          'Backend version is too old, please update "Unraid Connect" plugin on your Unraid server');
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
    _connectVersion = "";
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
