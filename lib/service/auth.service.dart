import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/constants/const.dart';
import 'package:mobile/model/apis.module.dart';
import 'package:mobile/model/node.module.dart';

class AuthService {
  static Future<String> login(String email, String password) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$url/api/auth/login'),
        body: {'email': email, 'password': password},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        localUser.setString('token', data['token']);
        await FirebaseAuth.instance.signInWithCustomToken(data['token']);
        return 'token';
      } else {
        return data['message'] ?? response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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
        Uri.parse('$url/api/auth/register'),
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
          localUser.setString('token', data['token']);
          FirebaseAuth.instance.signInWithCustomToken(data['token']);
          return 'token';
        } else {
          return data['message'] ?? data.toString();
        }
      } else {
        return data['message'] ?? data.toString();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return '';
    }
  }

  static Future<void> services() async {
    try {
      final response = await http.get(
        Uri.parse('$url/api/services'),
        headers: {
          'Authorization':
              'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}',
        },
      );
      final connected = await http.get(
        Uri.parse('$url/api/services/connected'),
        headers: {
          'Authorization':
              'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}',
        },
      );
      List<dynamic> data = jsonDecode(response.body);
      List<dynamic> auth = jsonDecode(connected.body);
      for (var service in data) {
        if (apis.map((e) => e.name).contains(service['name'])) {
          continue;
        }
        final connection = await http.get(
          Uri.parse('$url/api/services/${service['name']}/nodes'),
          headers: {
            'Authorization':
                'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}',
          },
        );
        final connected = jsonDecode(connection.body);
        var nodes = connected as List<dynamic>;

        List<NodeModel> triggers = nodes
            .where((e) => e['type'] == 'trigger')
            .map((e) => NodeModel.fromJson(e))
            .toList();

        List<NodeModel> actions = nodes
            .cast<Map<String, dynamic>>()
            .where((e) => e['type'] == 'action')
            .map((e) => NodeModel.fromJson(e))
            .toList();

        apis.add(
          ApiModel(
            name: service['name'],
            imageUrl: service['logo'],
            description: service['description'],
            actions: actions,
            reactions: triggers,
            auth: auth.firstWhere(
              (element) => element['serviceId'] == service['name'],
              orElse: () => {},
            ),
            color: parseColor(service['color'] ?? '#000000'),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

Color parseColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}
