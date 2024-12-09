import 'package:flutter/material.dart';
import 'package:mobile/onboarding/onboard.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/service/workflows.dart';

void main() {
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
  WorkflowService workflowService = WorkflowService();
  Widget pageEntrypointPage() {
    return OnBoardPage();
    return HomePage(
      workflow: workflowService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageEntrypointPage();
  }
}
