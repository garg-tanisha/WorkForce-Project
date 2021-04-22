import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
// import 'package:workforce/phone_login.dart';
import 'email_login.dart';
import 'email_signup.dart';
// import 'google_maps.dart';

class SignUp extends StatelessWidget {
  final String title = "Sign Up";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text(this.title),
          ),
          body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("WorkForce",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            fontFamily: 'Roboto')),
                  ),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SignInButton(
                        Buttons.Email,
                        text: "Sign up with Email",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmailSignUp()),
                          );
                        },
                      )),
                  // Padding(
                  //     padding: EdgeInsets.all(10.0),
                  //     child: SignInButton(
                  //       Buttons.Apple,
                  //       text: "Login with Phone",
                  //       onPressed: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => PhoneLoginScreen()),
                  //         );
                  //       },
                  //     )),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SignInButton(
                        Buttons.Google,
                        text: "Sign up with Google",
                        onPressed: () {},
                      )),
                  // Padding(
                  //     padding: EdgeInsets.all(10.0),
                  //     child: SignInButton(
                  //       Buttons.Google,
                  //       text: "Google Maps",
                  //       onPressed: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => GoogleMapsScreen()),
                  //         );
                  //       },
                  //     )),
                  // Padding(
                  //     padding: EdgeInsets.all(10.0),
                  //     child: SignInButton(
                  //       Buttons.Twitter,
                  //       text: "Sign up with Twitter",
                  //       onPressed: () {},
                  //     )),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: GestureDetector(
                          child: Text("Log In Using Email",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EmailLogIn()),
                            );
                          }))
                ]),
          )),
      debugShowCheckedModeBanner: false,
    );
  }
}
