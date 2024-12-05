import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:io';

import 'package:mobile/constants/const.dart';

class EmailPage extends StatefulWidget {
  final String? name;
  final String? bio;
  final String? link;
  final File? image;

  const EmailPage({super.key, this.name, this.bio, this.link, this.image});
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<EmailPage> {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        sh(130),
        const Text(
          "Create an account with your email address",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        sh(30),
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
              Container(
                height: MediaQuery.of(context).size.height / 10,
              ),
              _submitButton(context),
            ],
          ),
        )
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
              color: Color.fromARGB(255, 163, 163, 163),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 18.0,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 61, 61, 61),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      height: 164,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  onPressed: _submitForm,
                  color: Colors.blue,
                  child: const Text(
                    "Continuer",
                    style: TextStyle(
                      fontFamily: "icons.ttf",
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            )
          ],
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
        title: const Text('Login'),
      ),
      body: _body(context),
    );
  }
}
