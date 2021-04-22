import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'signup.dart';
import 'user_roles_screen.dart';
import 'home.dart';
import 'service_provider_homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'is_email_verified.dart';
import 'email_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkForce',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IntroScreen(),
    );
  }
}

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((res) {
      print(res);
      if (res != null) {
        Firestore.instance
            .collection("users")
            .document(res.uid)
            .get()
            .then((doc) {
          if (res.isEmailVerified) {
            if (doc["role"] == "Customer") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home(uid: res.uid)),
              );
            } else if (doc["role"] == "Service Provider") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ServiceProviderHome(uid: res.uid)),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => UserRoles(uid: res.uid)),
              );
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmailLogIn()),
            );
// Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => IsEmailVerified(
//                       email: res.email,
//                       password: ,
//                       role: doc["role"])),          //   print(doc["role"]);
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => IsEmailVerified(
            //           email: res.email,
            //           password: ,
            //           role: doc["role"])),
            // IsEmailVerified(res: result, role: doc["role"])),
            // );
          }
          // }
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUp()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 5,
        title: new Text(
          'Welcome To WorkForce!',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: Image.asset('images/workforce.png', fit: BoxFit.scaleDown),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("flutter"),
        loaderColor: Colors.blueAccent);
  }
}
