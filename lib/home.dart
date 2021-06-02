import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import 'email_signup.dart';
import 'email_login.dart';
import 'package:workforce/screens/recommendations/recommendations.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

final List<String> imgList = [
  "images/sales/1.jpg",
  "images/sales/2.jpg",
  "images/sales/3.jpg",
  "images/sales/4.jpg",
  "images/sales/5.jpg",
  "images/sales/6.jpg",
];

List<String> listPathsLabels = [
  "Avail service anywhere ",
  "Cut a deal on charges",
  "Nearby service providers available",
  "Several services to avail from",
  "Recommendations are provided",
  "Advanced search filters",
];
final List<Widget> imageSliders = imgList
    .map((item) => Container(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(item,
                          width: 1000.0, height: 700.0, fit: BoxFit.cover),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          listPathsLabels[imgList.indexOf(item)],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ))
    .toList();

class HomeState extends State {
  final String title = "Sign Up";
  int currentPos = 0;
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/home_page_background_image.jpg"),
                  fit: BoxFit.fill)),
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
                            child: Image.asset('images/workforce.png',
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
                                  fontSize: 20.0,
                                  color: Colors.blue),
                            ),
                          ),
                          CarouselSlider(
                            items: imageSliders,
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
                            children: imgList.map((url) {
                              int index = imgList.indexOf(url);
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
                                  Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: SignInButton(
                                        Buttons.Email,
                                        text: "Sign up with Email",
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EmailSignUp()),
                                          );
                                        },
                                      )),
                                  Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: SignInButton(
                                        Buttons.Email,
                                        text: "Log In Using Email",
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EmailLogIn()),
                                          );
                                        },
                                      )),
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
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
