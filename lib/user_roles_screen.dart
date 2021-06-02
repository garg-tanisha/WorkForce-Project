import 'package:workforce/screens/customer_orders/customer_order_status.dart';
import 'package:workforce/service_provider_homepage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workforce/customer_home.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class UserRoles extends StatelessWidget {
  UserRoles({this.uid});
  final String uid;
  final String title = "Roles";

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              leading: Container(),
              centerTitle: true,
              title: Text(title),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    auth.signOut().then((res) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    });
                  },
                )
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Image.asset('images/workforce.png',
                      height: 170.0, width: 170.0, fit: BoxFit.scaleDown),
                ),
                // CarouselSlider(
                //   items: imageSliders,
                //   options: CarouselOptions(
                //       viewportFraction: 1,
                //       autoPlay: true,
                //       enlargeCenterPage: true,
                //       aspectRatio: 2.0,
                //       onPageChanged: (index, reason) {
                //         setState(() {
                //           _current = index;
                //         });
                //       }),
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: imgList.map((url) {
                //     int index = imgList.indexOf(url);
                //     return Container(
                //       width: 8.0,
                //       height: 8.0,
                //       margin:
                //           EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                //       decoration: BoxDecoration(
                //         shape: BoxShape.circle,
                //         color: _current == index
                //             ? Color.fromRGBO(0, 0, 0, 0.9)
                //             : Color.fromRGBO(0, 0, 0, 0.4),
                //       ),
                //     );
                //   }).toList(),
                // ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Choose your role",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0)),
                ),
                Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: Colors.blue,
                        size: 30.0,
                        semanticLabel: 'Customer Role',
                      ),
                      trailing: Icon(
                        Icons.arrow_right_outlined,
                        color: Colors.blue,
                        size: 40.0,
                        semanticLabel: 'Right Arrow',
                      ),
                      title: Text("Customer"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerOrderStatus(
                                uid: uid,
                              ),
                            ));
                      },
                    )),
                Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: Colors.blue,
                        size: 30.0,
                        semanticLabel: 'Service Provider Role',
                      ),
                      trailing: Icon(
                        Icons.arrow_right_outlined,
                        color: Colors.blue,
                        size: 40.0,
                        semanticLabel: 'Right Arrow',
                      ),
                      title: Text("Service Provider"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceProviderHome(
                                uid: uid,
                              ),
                            ));
                      },
                    )),
              ],
            )));
  }
}
