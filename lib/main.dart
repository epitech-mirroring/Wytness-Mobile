import 'package:flutter/material.dart';
import 'package:mobile/constants/const.dart';
import 'package:mobile/onboarding/onboard.dart';
import 'package:mobile/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  Widget pageEntrypointPage() {
    if (localUser.getString('token') == null) {
      return const OnBoardPage();
    }
    return HomePage(
      workflow: workflowService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageEntrypointPage();
  }
}
