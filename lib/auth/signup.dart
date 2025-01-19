import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mobile/constants/const.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/service/auth.service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _passwordController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _surnameController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  width: dw(context) / 1.2,
                  height: dh(context) / 1.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome to Wytness!",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      sh(10),
                      const Text(
                        "Enter your email and password to continue",
                        style: TextStyle(
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _entryFeild(
                              CupertinoIcons.person,
                              'Name',
                              controller: _nameController,
                              isEmail: true,
                            ),
                            _entryFeild(
                              CupertinoIcons.person,
                              'Surname',
                              controller: _surnameController,
                              isEmail: true,
                            ),
                            _entryFeild(
                              CupertinoIcons.mail,
                              'Enter email',
                              controller: _emailController,
                              isEmail: true,
                            ),
                            _entryFeild(
                              CupertinoIcons.padlock,
                              'Enter password',
                              controller: _passwordController,
                              isPassword: true,
                            ),
                            sh(10),
                            _submitButton(context),
                            sh(20),
                            Container(
                              color: Colors.grey,
                              height: 0.5,
                              width: dw(context) / 1.2,
                            ),
                            sh(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      final GoogleSignIn googleSignIn =  GoogleSignIn();
                                      final GoogleSignInAccount? googleUser =
                                          await googleSignIn.signIn();

                                      if (googleUser == null) {
                                        return;
                                      }

                                      final GoogleSignInAuthentication
                                          googleAuth =
                                          await googleUser.authentication;

                                      final credential =
                                          GoogleAuthProvider.credential(
                                        accessToken: googleAuth.accessToken,
                                        idToken: googleAuth.idToken,
                                      );
                                      googleUser.email;
                                      // final UserCredential userCredential =
                                      //     await _auth
                                      //         .signInWithCredential(credential);

                                      // setState(() {
                                      //   _user = userCredential.user;
                                      // });

                                      // print(
                                      //     'Signed in as ${_user!.displayName}');
                                    } catch (error) {
                                      print(
                                          'Error during Google sign-in: $error');
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Image.asset(
                                            'assets/signin/google.png',
                                          ),
                                        ),
                                        sw(5),
                                        const Text(
                                          'Google',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        sw(5),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.apple_outlined,
                                          size: 26,
                                        ),
                                      ),
                                      sw(5),
                                      const Text(
                                        'Apple',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      sw(5),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _entryFeild(
    IconData icon,
    String hint, {
    required TextEditingController controller,
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        keyboardAppearance: Brightness.dark,
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: const TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0.0),
          labelText: hint,
          hintText: hint,
          fillColor: Colors.white,
          labelStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
          hintStyle: const TextStyle(
            fontSize: 14.0,
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 18.0,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return CupertinoButton(
      onPressed: _submitForm,
      color: const Color(0xff574ae2),
      child: const Text(
        "Signup",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_emailController.text.length > 30) {
      return;
    }
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }
    final message = await AuthService.register(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      _surnameController.text,
    );
    if (message == 'token') {
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute<Widget>(
          builder: (BuildContext context) => const HomePage(),
        ),
        (Route route) => true,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          backgroundColor: const Color(0xff574ae2),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/logo.svg',
              colorFilter: const ColorFilter.mode(
                Color(0xff574ae2),
                BlendMode.srcIn,
              ),
              width: 40,
            ),
            sw(10),
            const Text(
              'Wytness',
              style: TextStyle(
                fontFamily: 'Parkinsans',
                letterSpacing: -0.8,
                color: Color(0xff574ae2),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            sw(70),
          ],
        ),
      ),
      body: _body(context),
    );
  }
}
