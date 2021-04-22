import 'package:firebase_auth/firebase_auth.dart';
import 'is_email_verified.dart';
import 'package:flutter/material.dart';
import 'user_roles_screen.dart';
import 'home.dart';
import 'service_provider_homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g_captcha/g_captcha.dart'; // import "captcha.dart";
// import 'package:flutter_recaptcha_v2/flutter_recaptcha_v2.dart';

class EmailLogIn extends StatefulWidget {
  @override
  _EmailLogInState createState() => _EmailLogInState();
}

class _EmailLogInState extends State<EmailLogIn> {
  // RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();

  // String verifyResult = "";
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
// const St ring CAPTCHA_SITE_KEY = "CAPTCHA_SITE_KEY_HERE";
  TextEditingController passwordResetController = TextEditingController();
  bool isLoading = false;
  dynamic role;

  Future _asyncSimpleDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Details '),
            children: <Widget>[
              SimpleDialogOption(
                child: Form(
                    key: _formKey1,
                    child: Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          controller: passwordResetController,
                          decoration: InputDecoration(
                            labelText: "Enter Email*",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter Email Address*';
                            } else if (!value.contains('@')) {
                              return 'Please enter a valid email address!';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : RaisedButton(
                                color: Colors.lightBlueAccent,
                                onPressed: () {
                                  if (_formKey1.currentState.validate()) {
                                    // setState(() {
                                    //   isLoading = true;
                                    // });
                                    sendMessage();
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('Send Email'),
                              ),
                      )
                    ])),
              ),
            ],
          );
        });
  }

  void sendMessage() {
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: passwordResetController.text)
        .whenComplete(() => showDialog(
                context: context,
                builder: (BuildContext context) {
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.of(context).pop(true);
                  });
                  return AlertDialog(
                    content: Text("Sent Email to reset password."),
                  );
                }).catchError((err) {
              print(err.message);
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.of(context).pop(true);
                    });
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text(err.message),
                    );
                  });
            }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text("Login")),
          body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Enter Email Address*",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Email Address*';
                      } else if (!value.contains('@')) {
                        return 'Please enter a valid email address!';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Enter Password*",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Password';
                      } else if (value.length < 6) {
                        return 'Password must be atleast 6 characters!';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: isLoading
                      ? CircularProgressIndicator()
                      : RaisedButton(
                          color: Colors.lightBlueAccent,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              logInToFb();
                            }
                          },
                          child: Text('Submit'),
                        ),
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: GestureDetector(
                        child: Text("Forgot Password",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue)),
                        onTap: () async {
                          await _asyncSimpleDialog(context);
                        })),
              ])))),
      debugShowCheckedModeBanner: false,
    );
  }

  void logInToFb() {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) {
      isLoading = false;

      // Navigator.of(context).push(
      //   MaterialPageRoute(builder: (context) {
      //     return Captcha((String code) => print("Code returned: " + code));
      //   }),
      // );
      Firestore.instance
          .collection("users")
          .document(result.user.uid)
          .get()
          .then((doc) {
        if (result.user.isEmailVerified) {
          if (doc["role"] == "Customer") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Home(uid: result.user.uid)),
            );
          } else if (doc["role"] == "Service Provider") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ServiceProviderHome(uid: result.user.uid)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => UserRoles(uid: result.user.uid)),
            );
          }
        } else {
          print(doc["role"]);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => IsEmailVerified(
                    email: emailController.text,
                    password: passwordController.text,
                    role: doc["role"])),
            // IsEmailVerified(res: result, role: doc["role"])),
          );
        }
      });
    }).catchError((err) {
      print(err.message);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    isLoading = false;
                    setState(() {});
                  },
                )
              ],
            );
          });
    });
  }
}
