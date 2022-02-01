import 'dart:convert' show jsonDecode;
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
  String accessToken = '';
  String refreshToken = '';

}

class ClientApi {

  final clientId = 'c40f23829f08538d4fe58d099ce17155fbf5115478ac0bcb674b21837895cabd';
  final clientSecret = 'ea598d6f22881a8ade6edd59f41d3e81dd1c8fab0a1e34002516dbd7ea9b3de1';
  final redirectUri = 'swifty://login/';

  final storage = Storage();

  Future<void> authenticate(result) async {
    if (!storage.login) {
      try {
        final code = Uri
            .parse(result)
            .queryParameters['code'];
        final response = await http.post(
            Uri.parse('https://api.intra.42.fr/oauth/token'), body: {
          'client_id': clientId,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
          'client_secret': clientSecret,
          'code': code,
        });
        storage.accessToken =
        jsonDecode(response.body)['access_token'] as String;
        storage.refreshToken =
        jsonDecode(response.body)['refresh_token'] as String;
        await storage.flutterSecureStorage.write(key: 'token', value: storage.accessToken);
        await storage.flutterSecureStorage.write(key: 'refresh_token', value: storage.refreshToken);
        storage.login = true;
      } catch (e) {
        log(e.toString());
      }
    }
  }

  void login() async {
    final url = Uri.https('api.intra.42.fr', '/oauth/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'public',
      'client_secret': clientSecret
    });
    if (!await launch(url.toString(), forceWebView: false, forceSafariVC: false)) throw 'Could not launch $url';
  }

  void logout() async {
    await storage.flutterSecureStorage.delete(key: 'token');
  }

  void refreshToken() async {
    final response = await http.post(Uri.parse('https://api.intra.42.fr/oauth/token'), body: {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'refresh_token',
      'client_secret': clientSecret,
      'refresh_token': await storage.flutterSecureStorage.read(key: 'refreshToken')
    });
    storage.accessToken =
    jsonDecode(response.body)['access_token'] as String;
    storage.refreshToken =
    jsonDecode(response.body)['refresh_token'] as String;
    await storage.flutterSecureStorage.write(key: 'token', value: storage.accessToken);
    await storage.flutterSecureStorage.write(key: 'refresh_token', value: storage.refreshToken);
    storage.login = true;
  }

  void get(String url) async {
    final response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: storage.accessToken
    });
  }
}