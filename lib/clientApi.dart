import 'dart:convert' show JsonCodec, json, jsonDecode;
import 'dart:developer';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class Storage {
  static final Storage _storage = Storage._internal();

  factory Storage() {
    return _storage;
  }

  Storage._internal();

  final FlutterSecureStorage flutterSecureStorage = const FlutterSecureStorage();
  var login = false;
  var accessToken;
  var expiresIn;
  var refreshToken;
  final client = http.Client();


  Future<void> setAccessToken(String? accessToken) async {
    this.accessToken = accessToken;
    if (accessToken == null) return;
    await flutterSecureStorage.write(key: 'accessToken', value: accessToken);
  }

  Future<String?> getAccessToken() async {
    if (accessToken != null) {
      return accessToken;
    } else {
      accessToken = await flutterSecureStorage.read(key: 'accessToken');
      return accessToken;
    }
  }

  Future<void> setRefreshToken(String? refreshToken) async {
    this.refreshToken = refreshToken;
    if (refreshToken == null) return;
    await flutterSecureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    if (refreshToken != null) {
      return refreshToken;
    } else {
      refreshToken = await flutterSecureStorage.read(key: 'refreshToken');
      return refreshToken;
    }
  }

  Future<void> setExpiresIn(DateTime? expiresIn) async {
    this.expiresIn = expiresIn;
    if (expiresIn == null) return;
    await flutterSecureStorage.write(key: 'expiresIn', value: expiresIn.millisecondsSinceEpoch.toString());
  }

  Future<DateTime?> getExpiresIn() async {
    if (expiresIn != null) {
      return expiresIn;
    } else {
      var tmp = await flutterSecureStorage.read(key: 'expiresIn');
      if (tmp == null) return null;
      int tmp2 = int.parse(tmp);
      expiresIn = DateTime.fromMillisecondsSinceEpoch(tmp2);
      return expiresIn;
    }
  }

  void setLogin(bool login) {
    this.login = login;
  }

  bool getLogin() {
    return login;
  }

}

class ClientApi {

  final clientId = 'XXXX';
  final clientSecret = 'XXXX';
  final redirectUri = 'swifty://login/';
  final coolDown = 1;
  DateTime? _lastUpdate;

  final storage = Storage();

  Future<bool> authenticate(result) async {
    if (!storage.login) {
      try {
        final code = Uri
            .parse(result)
            .queryParameters['code'];
        final response = await storage.client.post(
            Uri.parse('https://api.intra.42.fr/oauth/token'), body: {
          'client_id': clientId,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
          'client_secret': clientSecret,
          'code': code,
        });

        var body = jsonDecode(response.body);
        storage.setAccessToken(body['access_token']);
        storage.setRefreshToken(body['refresh_token']);
        storage.setExpiresIn(DateTime.now().add(Duration(seconds: body['expires_in'])));
        storage.setLogin(true);
        return true;
      } catch (e) {
        log(e.toString());
        return false;
      }
    }
    return false;
  }

  Future<void> login() async {
    final url = Uri.https('api.intra.42.fr', '/oauth/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'public',
      'client_secret': clientSecret
    });
    if (Platform.isIOS) {
      if (!await launch(url.toString(),
          forceSafariVC: false,
          enableJavaScript: true)) throw 'Could not launch $url';
    } else if (Platform.isAndroid) {
      if (!await launch(url.toString(),
          forceWebView: false,
          enableJavaScript: true)) throw 'Could not launch $url';
    }
  }

  Future<void> logout() async {
    await storage.flutterSecureStorage.deleteAll();
    storage.setLogin(false);
    storage.setAccessToken(null);
    storage.setExpiresIn(null);
    storage.setRefreshToken(null);
  }

  Future<bool> refreshToken() async {
    try {
      final rt = await storage.getRefreshToken();

      if (rt == null) return false;
      final response = await storage.client.post(
          Uri.parse('https://api.intra.42.fr/oauth/token'), body: {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'grant_type': 'refresh_token',
        'client_secret': clientSecret,
        'refresh_token': rt
      });

      var body = jsonDecode(response.body);
      storage.setAccessToken(body['access_token']);
      storage.setRefreshToken(body['refresh_token']);

      var duration = body['expires_in'];
      if (duration != null) {
        storage.setExpiresIn(DateTime.now().add(Duration(seconds: body['expires_in'])));
      } else {
        return false;
      }
      storage.setLogin(true);
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  Future<dynamic> get(String url) async {
    if (_lastUpdate != null && _lastUpdate!.isAfter(DateTime.now().subtract(Duration(seconds: coolDown)))) return null; //Delay one update max per second
    _lastUpdate = DateTime.now();

    if (!await checkTokenLife()) {
      refreshToken();
    }
    try {
      String? token = await storage.getAccessToken();
      if (token == null) return null;
      final response = await storage.client.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token'
      });
      var tmp = jsonDecode(response.body);
      return tmp;
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }
  
  Future<bool> checkTokenLife() async {
    var expiresIn = await storage.getExpiresIn();

    if (expiresIn != null && expiresIn.isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }
  
  Future<bool> needToLogIn() async {
    var token = await storage.getAccessToken();

    storage.setLogin(false);
    if (token == null) return true;
    if (!await checkTokenLife() && !await refreshToken()) return true; //Need to log if token is not alive anymore and refreshing it failed
    storage.setLogin(true);
    return false;
  }
}
