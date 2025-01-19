import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:mobile/constants/const.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/service/auth.service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<SignInPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _emailController = TextEditingController();
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
        Center(
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
                height: dh(context) / 1.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome Back!",
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
                            'Enter email',
                            controller: _emailController,
                            isEmail: true,
                          ),
                          _entryFeild(
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
      ],
    );
  }

  Widget _entryFeild(
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
            isPassword ? CupertinoIcons.lock_fill : CupertinoIcons.mail_solid,
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
        "Login",
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
    final data = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );
    if (data == 'token') {
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
            data,
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
        centerTitle: true,
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
