import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/const.dart';

class AuthService {
  static Future<String> login(String email, String password) async {
    try {
      http.Response response = await http.post(
        Uri.parse('http://localhost:3000/auth/login'),
        body: {
          'email': email,
          'password': password,
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        FirebaseAuth.instance.signInWithCustomToken(data['token']);
        localUser.setString('token', data['token']);
        return 'token';
      } else {
        return data['message'] ?? response.body;
      }
    } catch (e) {
      print(e);
      return '';
    }
  }

  static Future<String> register(
    String email,
    String password,
    String name,
    String surname,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/auth/register'),
        body: {
          'email': email,
          'password': password,
          'name': name,
          'surname': surname,
        },
      );
      Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (data.containsKey('token')) {
          FirebaseAuth.instance.signInWithCustomToken(data['token']);
          localUser.setString('token', data['token']);
          return 'token';
        } else {
          return data['message'] ?? data.toString();
        }
      } else {
        return data['message'] ?? data.toString();
      }
    } catch (e) {
      print(e);
      return '';
    }
  }
}
