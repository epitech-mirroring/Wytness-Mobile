import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/animations/w_row.dart';

import 'package:mobile/constants/const.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
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
        Transform.scale(
          scaleX: -1,
          child: Transform.rotate(
            angle: 0.2,
            child: const AnimatedScreen(),
          ),
        ),
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
        "Signup",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  void _submitForm() {
    if (_emailController.text.length > 30) {
      // Utility.customSnackBar(
      //     _scaffoldKey, 'Username length cannot exceed 50 character', context);
      return;
    }
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Utility.customSnackBar(
      //     _scaffoldKey, 'Please fill form carefully', context);
      return;
    }

    // var state = Provider.of<AuthState>(context, listen: false);

    // UserModel user = UserModel(
    //   email: _emailController.text.toLowerCase(),
    //   displayName: widget.name,
    //   userName: "@" + "${widget.name}" + "${Random().nextInt(1000)}",
    //   bio: widget.bio,
    //   profilePic:
    //       "https://static.vecteezy.com/system/resources/previews/005/544/718/original/profile-icon-design-free-vector.jpg",
    //   link: widget.link,
    // );
    // state.updateUserProfile(
    //   user,
    //   image: widget.image,
    // );
    // state
    //     .signUp(
    //   user,
    //   context,
    //   password: _passwordController.text,
    //   scaffoldKey: _scaffoldKey,
    // )
    //     .then((status) {
    //   print(status);
    // }).whenComplete(
    //   () {
    //     Future.delayed(const Duration(seconds: 0)).then((_) {
    //       var state = Provider.of<AuthState>(context, listen: false);
    //       state.getCurrentUser();
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: ((context) => PrivacyPage())),
    //       );
    //     });
    //   },
    // );
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
              color: const Color(0xff574ae2),
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