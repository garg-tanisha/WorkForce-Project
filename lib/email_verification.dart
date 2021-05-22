import 'package:carousel_slider/carousel_slider.dart';
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
  int currentPos = 0;
  List<String> listPaths = [
    "Avail service anywhere ",
    "Cut a deal on charges",
    "Nearby service providers available",
    "Several services to avail from",
    "Recommendations are provided",
    "Advanced search filters",
  ];
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: CarouselSlider.builder(
                      itemCount: listPaths.length,
                      options: CarouselOptions(
                          autoPlay: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentPos = index;
                            });
                          }),
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin:
                                const EdgeInsets.only(top: 10.0, bottom: 0.0),
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                    width: 200,
                                    height: 50,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(listPaths[index],
                                          style: TextStyle(
                                              // fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 20.0)),
                                    ))));
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: listPaths.map((url) {
                      int index = listPaths.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPos == index
                              ? Color.fromRGBO(0, 0, 0, 0.9)
                              : Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
                    child: Text("Kindly verify your email to proceed",
                        style: TextStyle(fontSize: 16.0)),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      sendEmailLink(result);
                    },
                    child: const Text("Send Email verification link"),
                    // style: TextStyle(fontSize: 16.0)),
                    color: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Colors.blue, width: 2)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
                    child: Text("Proceed after verification of email",
                        style: TextStyle(fontSize: 16.0)),
                  ),
                  RaisedButton(
                    color: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Colors.blue, width: 2)),
                    onPressed: () async {
                      setState(() {
                        build(context);
                      });
                    },
                    child: const Text(
                      "Proceed",
                      // style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
                    child: Text("Entered invalid email?",
                        style: TextStyle(fontSize: 16.0)),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Go Back to Previous Page",
                      // style: TextStyle(fontSize: 16.0),
                    ),
                    color: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Colors.blue, width: 2)),
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
