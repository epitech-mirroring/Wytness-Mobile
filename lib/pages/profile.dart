import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/constants/const.dart';
import 'package:mobile/onboarding/onboard.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User? user;
  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    super.initState();
  }

  void logout() async {
    FirebaseAuth.instance.signOut();
    localUser.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OnBoardPage(),
      ),
    );
    apis.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Email: ${user?.email ?? ''}'),
          sh(20),
          CupertinoButton(
            color: const Color(0xff574ae2),
            onPressed: logout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
