import 'package:workforce/utils/corousel_sliders.dart';
import 'package:workforce/utils/images_and_Labels.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import 'email_signup.dart';
import 'email_login.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State {
  final String title = "Sign Up";
  int currentPos = 0;
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    final Shader linearGradient = LinearGradient(
      colors: <Color>[Color(0xFF40C4FF), Color(0xFF1976D2)],
    ).createShader(new Rect.fromLTWH(
      0.0,
      0.0,
      200.0,
      70.0,
    ));
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(homePageBackgroundImage), fit: BoxFit.fill)),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(),
                child: IntrinsicHeight(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Image.asset(workForceLogo,
                              height: 220.0,
                              width: 220.0,
                              fit: BoxFit.scaleDown),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Text(
                            'Greetings From WorkForce!',
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              foreground: new Paint()..shader = linearGradient,
                              fontSize: 24.0,
                              // color: Colors.lightBlueAccent
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                        ),
                        CarouselSlider(
                          items: salesImageSliders,
                          options: CarouselOptions(
                              viewportFraction: 1,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              aspectRatio: 2.0,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: salesList.map((url) {
                            int index = salesList.indexOf(url);
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == index
                                    ? Color.fromRGBO(0, 0, 0, 0.9)
                                    : Color.fromRGBO(0, 0, 0, 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Column(
                              // Vertically center the widget inside the column
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Center(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          // top: 20.0,
                                          bottom: 10.0,
                                          left: 20.0,
                                          // right: 20.0
                                        ),
                                        child: Icon(
                                          Icons.email,
                                          color: Colors.blue,
                                          size: 30.0,
                                          semanticLabel: 'Email',
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            // top: 20.0,
                                            bottom: 10.0,
                                            left: 20.0,
                                            right: 20.0),
                                        child: RaisedButton(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EmailSignUp()),
                                            );
                                          },
                                          child: const Text(
                                            "Sign up with Email",
                                            style: TextStyle(fontSize: 15.0),
                                          ),
                                          color: Colors.lightBlueAccent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              side: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2)),
                                        ),
                                      )
                                    ]),
                                  ),
                                ),
                                Center(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          // top: 20.0,
                                          bottom: 10.0,
                                          left: 20.0,
                                          // right: 20.0
                                        ),
                                        child: Icon(
                                          Icons.email,
                                          color: Colors.blue,
                                          size: 30.0,
                                          semanticLabel: 'Email',
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            // top: 20.0,
                                            bottom: 10.0,
                                            left: 20.0,
                                            right: 20.0),
                                        child: RaisedButton(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EmailLogIn()),
                                            );
                                          },
                                          child: Text(
                                            "Log In Using Email",
                                            style: TextStyle(fontSize: 15.0),
                                          ),
                                          color: Colors.lightBlueAccent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              side: BorderSide(
                                                  color: Colors.blue,
                                                  width: 2)),
                                        ),
                                      )
                                    ]),
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: GestureDetector(
                                        child: Text(
                                          "T & C",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                        onTap: () {})),
                              ]),
                        )
                      ]),
                )),
          ),
        ),
      ),
    );
  }
}
