import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile/constants/const.dart';
import 'package:mobile/onboarding/onboard.dart';
import 'package:mobile/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  localUser = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wytness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EntryPointPage(),
    );
  }
}

class EntryPointPage extends StatefulWidget {
  const EntryPointPage({super.key});

  @override
  State<EntryPointPage> createState() => _EntryPointPageState();
}

class _EntryPointPageState extends State<EntryPointPage> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAppLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeAppLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleIncomingLink(uri);
      }
    });
  }

  void _handleIncomingLink(Uri uri) async {
    Map<String, String> queryParameters = uri.queryParameters;
    if (queryParameters.containsKey('code') &&
        queryParameters.containsKey('service') &&
        queryParameters.containsKey('state')) {
      final service = queryParameters['service'];
      final code = queryParameters['code'];
      final state = queryParameters['state'];
      if (service != null && code != null && state != null) {
        print(jsonEncode({
          'code': code,
          'state': state,
        }));
        try {
          final data = await http.post(
            Uri.parse('http://localhost:4040/api/services/$service/connect'),
            headers: {
              'Authorization':
                  'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken()}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'code': code,
              'state': state,
            }),
          );
          print(data.statusCode);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  Widget pageEntrypointPage() {
    if (localUser.getString('token') == null) {
      return const OnBoardPage();
    }
    return const HomePage();
  }

  @override
  Widget build(BuildContext context) {
    return pageEntrypointPage();
  }
}
