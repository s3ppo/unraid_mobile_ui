import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unmobile/global/globals.dart';
import 'package:unmobile/global/queries.dart';

class AuthException implements Exception {
  String msg;
  AuthException(this.msg);
}

class AuthState extends ChangeNotifier {
  late SharedPreferences storage;

  GraphQLClient? _client;
  bool _initialized = false;
  dynamic _userData;
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  String _connectVersion = "";

  GraphQLClient? get client => _client;
  String get connectVersion => _connectVersion;
  bool get initialized => _initialized;
  dynamic get userData => _userData;

  AuthState() {
    init();
  }

  void init() async {
    storage = await SharedPreferences.getInstance();
    await getPackageInfos();

    String? token = storage.getString('token');
    String? ip = storage.getString('ip');
    String? prot = storage.getString('prot');

    if (token != null && ip != null && prot != null) {
      try {
        await connectUnraid(token: token, ip: ip, prot: prot);
      } on AuthException {
        _initialized = true;
        logout();
      }
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> connectUnraid(
      {required String token, required String ip, required String prot}) async {
    String endPoint;
    if (prot == 'https' || prot == 'https_insecure') {
      endPoint = 'https://$ip/graphql';
    } else {
      endPoint = 'http://$ip/graphql';
    }

    IOClient getInsecureIOClient() {
      var httpClient = HttpClient();
      if (prot == 'https_insecure') {
        httpClient.badCertificateCallback =
            (X509Certificate cert, String ip, int port) => true;
      }
      return IOClient(httpClient);
    }

    var link = HttpLink(
      endPoint,
      defaultHeaders: {'Origin': packageName, 'x-api-key': token},
      httpClient: getInsecureIOClient(),
    );

    _client = GraphQLClient(link: link, cache: GraphQLCache());

    await testConnection();
    await getMe();

    await storage.setString('token', token);
    await storage.setString('ip', ip);
    await storage.setString('prot', prot);

    notifyListeners();
  }

  void logout() async {
    await storage.remove('token');
    await storage.remove('ip');
    await storage.remove('prot');
    _connectVersion = "";
    _client = null;
    notifyListeners();
  }

  Future<void> getPackageInfos() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  Future<void> testConnection() async {
    final result =
        await _client!.query(QueryOptions(document: gql(Queries.getServices)));
    if (result.hasException) {
      logout();
      throw AuthException('Connection failed');
    }

    // Check if the Unraid Connect version is compatible
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
  }

  Future<void> getMe() async {
    final result = await _client!.query(QueryOptions(document: gql(Queries.getMe)));
    if (result.hasException) {
      logout();
      throw AuthException('Failed to fetch user data');
    }

    _userData = result.data!['me'];
  }

}
