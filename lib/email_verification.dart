import 'package:firebase_auth/firebase_auth.dart';
import 'service_provider_homepage.dart';
import 'package:flutter/material.dart';
import 'user_roles_screen.dart';
import 'customer_home.dart';

class IsEmailVerified extends StatefulWidget {
  IsEmailVerified({this.email, this.password, this.role});
  final String email, password;
  final String role;
  @override
  State<StatefulWidget> createState() =>
      IsEmailVerifiedState(email, password, role);
}

class IsEmailVerifiedState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String _role, email, password;

  IsEmailVerifiedState(String email, String password, String _role) {
    this.email = email;
    this.password = password;
    this._role = _role;
  }

  @override
  Widget build(BuildContext context) {
    AuthResult result;
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((res) {
      result = res;
      if (res.user.isEmailVerified) {
        if (_role == 'Customer') {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerHome(uid: res.user.uid),
              ));
        } else if (_role == "Service Provider") {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceProviderHome(uid: res.user.uid),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserRoles(uid: res.user.uid),
              ));
        }
      }
    });
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(title: Text("Email Verification")),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      "Your email is not verified. Please verify your email to proceed."),
                  RaisedButton(
                    onPressed: () async {
                      sendEmailLink(result);
                    },
                    child: const Text(
                      "Send Email verification link",
                      style: TextStyle(fontSize: 15.0),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: Colors.lightBlueAccent,
                  ),
                  Text("Proceed after verification of email"),
                  RaisedButton(
                    onPressed: () async {
                      setState(() {
                        build(context);
                      });
                    },
                    child: const Text(
                      "Click after verifying email",
                      style: TextStyle(fontSize: 15.0),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: Colors.lightBlueAccent,
                  ),
                  Text("Entered invalid email? Go to previous page"),
                  RaisedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Go Back",
                      style: TextStyle(fontSize: 15.0),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: Colors.lightBlueAccent,
                  ),
                ])));
  }

  sendEmailLink(AuthResult result) {
    result.user
        .sendEmailVerification()
        .whenComplete(() => showDialog(
            context: context,
            builder: (BuildContext context) {
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pop(true);
              });
              return AlertDialog(
                content: Text(
                    "Email verification link sent. Please verify your email to proceed."),
              );
            }))
        .catchError((err) {
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

  @override
  void dispose() {
    super.dispose();
  }
}
