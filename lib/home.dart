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

class HomeState extends State {
  final String title = "Sign Up";
  int currentPos = 0;
  List<String> listPaths = [
    "Avail service anywhere ",
    "Cut a deal on charges",
    "Nearby service providers available",
    "Several services to avail from",
    "Recommendations are provided",
    "Advanced search filters",
  ];
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
                                height: 170.0,
                                width: 170.0,
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
                          CarouselSlider.builder(
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
                                  margin: const EdgeInsets.only(
                                      top: 10.0, bottom: 0.0),
                                  child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Container(
                                          width: 200,
                                          height: 50,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 15),
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
