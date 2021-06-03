import 'package:workforce/utils/corousel_sliders.dart';
import 'package:workforce/utils/widgets/preventive_measures_for_covid_19.dart';
import 'package:workforce/utils/widgets/contact_us.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workforce/main.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/wsp_orders/wsp_in_progress_orders.dart';
import 'wsp_new_orders.dart';
import 'package:workforce/screens/wsp_orders/order_confirmations.dart';
import 'wsp_completed_orders.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:workforce/utils/images_and_Labels.dart';

class OrderHome extends StatefulWidget {
  OrderHome({this.uid, this.role});
  final String uid;
  final String role;
  @override
  State<StatefulWidget> createState() => OrderHomeState(uid, role);
}

class OrderHomeState extends State {
  String uid;
  String role;
  int _current = 0;
  OrderHomeState(String uid, String role) {
    this.uid = uid;
    this.role = role;
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(role),
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
          body: SingleChildScrollView(
            child: Column(
              children: [
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
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index
                            ? Color.fromRGBO(0, 0, 0, 0.9)
                            : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                ),
                PreventiveMeasuresForCovid19(),
                ContactUs()
              ],
            ),
          ),
        ));
  }
}
