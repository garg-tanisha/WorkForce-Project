import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:workforce/screens/wsp_orders/wsp_order_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';

final List<String> imgList = [
  "images/customer_home/carpenter.jpg",
  "images/customer_home/electrician.jpg",
  "images/customer_home/mechanic.jpg",
  "images/customer_home/plumber.jpg",
  "images/customer_home/sofa_cleaning.jpg",
  "images/customer_home/women_hair_cut_and_styling.jpg",
];

final List<String> preventCorona = [
  "images/preventive_measures/handwash_for_20_sec.jpg",
  "images/preventive_measures/use_soap_or_sanitizers.PNG",
  "images/preventive_measures/social_distancing.PNG",
  "images/preventive_measures/donot_touch_face_eyes_nose_mouth_with_dirty_hands.jpg",
  "images/preventive_measures/cover_nose_and_mouth_with_mask.PNG",
  "images/preventive_measures/isolation.jpg",
];

List<String> listPathsLabels = [
  "Carpenter",
  "Electrician",
  "Mechanic",
  "Plumber",
  "Sofa Cleaning",
  "Women's Hair Cut and Spa"
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

class ServiceProviderHome extends StatefulWidget {
  ServiceProviderHome({this.uid});
  final String uid;
  @override
  State<StatefulWidget> createState() => ServiceProviderHomeState(uid);
}

class ServiceProviderHomeState extends State {
  String uid;
  final String title = "WSP HomePage";
  List<dynamic> roles = [];
  List<dynamic> rating = [];
  ServiceProviderHomeState(String uid) {
    this.uid = uid;
  }
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    int imageCount = (imgList.length / 2).round();
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Services",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0)),
                  ),
                ),
                StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document(uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      roles.clear();
                      if (!snapshot.hasData) {
                        return new Text("Loading");
                      }

                      var roles_check = snapshot.data;
                      var userDocument = snapshot.data["roles"];

                      if (roles_check == null ||
                          snapshot.data["role"] == "Customer")
                        return Center(child: Text("No specific roles!"));

                      for (var key in userDocument.keys) {
                        roles.add(key);
                      }

                      for (var value in userDocument.values) {
                        rating.add(value);
                      }

                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: roles.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              width: 0.98 *
                                  MediaQuery.of(context)
                                      .size
                                      .width
                                      .roundToDouble(),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black12,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(
                                        5.0) //                 <--- border radius here
                                    ),
                              ),
                              child: ListTile(
                                // leading: Icon(
                                //   Icons.add_location_alt_sharp,
                                //   color: Colors.blue,
                                //   size: 30.0,
                                //   semanticLabel: 'Customer Role',
                                // ),
                                trailing: Icon(
                                  Icons.arrow_right_outlined,
                                  color: Colors.blue,
                                  size: 40.0,
                                  semanticLabel: 'Right Arrow',
                                ),
                                title: Text(roles[index]),
                                subtitle: rating[index] != "null"
                                    ? Text(
                                        "(Rating: " +
                                            rating[index].toString() +
                                            " )",
                                      )
                                    : Text("(Rating: No rating yet)"),
                                onTap: () {
                                  print(roles[index]);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderHistory(
                                            uid: uid, role: roles[index]),
                                      ));
                                },
                              ),
                            );
                          });
                    }),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black12,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(
                              5.0) //                 <--- border radius here
                          ),
                    ),
                    child: ListTile(
                      // leading: Icon(
                      //   Icons.add_location_alt_sharp,
                      //   color: Colors.blue,
                      //   size: 30.0,
                      //   semanticLabel: 'Customer Role',
                      // ),
                      trailing: Icon(
                        Icons.arrow_right_outlined,
                        color: Colors.blue,
                        size: 40.0,
                        semanticLabel: 'Right Arrow',
                      ),
                      title: Text("Other"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderHistory(uid: uid, role: "Other"),
                            ));
                      },
                    )),
                Container(
                  width: MediaQuery.of(context).size.width.roundToDouble(),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(
                            5.0) //                 <--- border radius here
                        ),
                  ),
                  child: Column(children: [
                    Container(
                      width: MediaQuery.of(context).size.width.roundToDouble(),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //                 <--- border radius here
                            ),
                      ),
                      child: Column(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text("Preventive Measures To Fight Covid",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0)),
                          ),
                        ),
                        Container(
                            width: 0.98 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black12,
                              ),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                        child: Card(
                                      color: Colors.white,
                                      elevation: 2.0,
                                      child: ListTile(
                                          title: Text(
                                              "Wash your hands timely for atleast 20 seconds.",
                                              style: TextStyle(fontSize: 13.0)),
                                          leading: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                              ),
                                            ),
                                            child: Image.asset(preventCorona[0],
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover),
                                          )),
                                    )),
                                    Expanded(
                                        child: Card(
                                      color: Colors.white,
                                      elevation: 2.0,
                                      child: ListTile(
                                          title: Text(
                                              "Use soaps or alcohol based sanitizers.",
                                              style: TextStyle(fontSize: 13.0)),
                                          leading: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                              ),
                                            ),
                                            child: Image.asset(preventCorona[1],
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover),
                                          )),
                                    ))
                                  ]),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                        child: Card(
                                      color: Colors.white,
                                      elevation: 2.0,
                                      child: ListTile(
                                          title: Text(
                                              "Do social distancing. Avoid any close contact with sick people.",
                                              style: TextStyle(fontSize: 13.0)),
                                          leading: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                              ),
                                            ),
                                            child: Image.asset(preventCorona[2],
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover),
                                          )),
                                    )),
                                    Expanded(
                                        child: Card(
                                      color: Colors.white,
                                      elevation: 2.0,
                                      child: ListTile(
                                          title: Text(
                                              "Avoid touching your nose, eyes or face with unclean hands.",
                                              style: TextStyle(fontSize: 13.0)),
                                          leading: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                              ),
                                            ),
                                            child: Image.asset(preventCorona[3],
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover),
                                          )),
                                    ))
                                  ]),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                        child: Card(
                                      color: Colors.white,
                                      elevation: 2.0,
                                      child: ListTile(
                                          title: Text(
                                              "Cover nose and mouth with mask. Sneeze/cough into your elbow.",
                                              style: TextStyle(fontSize: 13.0)),
                                          leading: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 2,
                                                ),
                                              ),
                                              child: Image.asset(
                                                  preventCorona[4],
                                                  width: 40.0,
                                                  height: 40.0,
                                                  fit: BoxFit.cover))),
                                    )),
                                    Expanded(
                                        child: Card(
                                      color: Colors.white,
                                      elevation: 2.0,
                                      child: ListTile(
                                          title: Text(
                                              "Isolation and social distancing are very important to stay safe.",
                                              style: TextStyle(fontSize: 13.0)),
                                          leading: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                              ),
                                            ),
                                            child: Image.asset(preventCorona[5],
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover),
                                          )),
                                    ))
                                  ]),
                            ]))
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10.0),
                      width: MediaQuery.of(context).size.width.roundToDouble(),
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                5.0) //                 <--- border radius here
                            ,
                            topRight: Radius.circular(
                                5.0) //                 <--- border radius here
                            ),
                      ),
                      child: Column(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                              "images/customer_home/contact_us.jpg",
                              width: MediaQuery.of(context)
                                  .size
                                  .width
                                  .roundToDouble(),
                              height: 0.25 *
                                  MediaQuery.of(context)
                                      .size
                                      .height
                                      .roundToDouble(),
                              fit: BoxFit.cover),
                        ),
                        Container(
                            // width: 0.98 *
                            //     MediaQuery.of(context)
                            //         .size
                            //         .width
                            //         .roundToDouble(),
                            // margin:
                            //     const EdgeInsets.symmetric(horizontal: 10.0),
                            margin: EdgeInsets.only(top: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black12,
                              ),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: ListTile(
                              title: RichText(
                                text: new TextSpan(
                                  style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: 'For any questions or enquires ',
                                        style: TextStyle(fontSize: 18.0)),
                                    new TextSpan(
                                        text: 'contact us or whatsapp us',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    new TextSpan(text: ' at 98xxxxxxxx'),
                                  ],
                                ),
                              ),
                              leading: Icon(
                                Icons.call_outlined,
                                color: Colors.blue,
                                size: 30.0,
                                semanticLabel: 'Query',
                              ),
                            )),
                      ]),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width.roundToDouble(),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //                 <--- border radius here
                            ),
                      ),
                      child: Column(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, left: 10.0, right: 10.0),
                            child: Text("In Demand Services",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0)),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.all(10.0),
                            child: CarouselSlider.builder(
                              options: CarouselOptions(
                                aspectRatio: 2.0,
                                enlargeCenterPage: false,
                                viewportFraction: 1,
                              ),
                              itemCount: imageCount,
                              itemBuilder: (context, index) {
                                final int first = index * 2;
                                int second;
                                imgList.length % 2 == 0
                                    ? (second = index <= imageCount - 1
                                        ? first + 1
                                        : null)
                                    : (second = index < imageCount - 1
                                        ? first + 1
                                        : null);
                                return Row(
                                  children: [first, second].map((idx) {
                                    return idx != null
                                        ? Expanded(
                                            flex: 1,
                                            child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Stack(children: <Widget>[
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Image.asset(
                                                        imgList[idx],
                                                        width: 1000.0,
                                                        height: 700.0,
                                                        fit: BoxFit.cover),
                                                  ),
                                                  Positioned(
                                                    bottom: 0.0,
                                                    left: 0.0,
                                                    right: 0.0,
                                                    child: Container(
                                                      height: 60.0,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        border: Border.all(
                                                          color: Colors.black,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10.0) //                 <--- border radius here
                                                                ,
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10.0) //                 <--- border radius here
                                                                ),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 20.0),
                                                      child: Text(
                                                        listPathsLabels[idx],
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ])))
                                        : Container();
                                  }).toList(),
                                );
                              },
                            )),
                      ]),
                    )
                  ]),
                ),
              ],
            ),
          ),
          drawer: NavigateDrawer(uid: this.uid),
        ));
  }
}

class NavigateDrawer extends StatefulWidget {
  final String uid;
  NavigateDrawer({Key key, this.uid}) : super(key: key);
  @override
  _NavigateDrawerState createState() => _NavigateDrawerState();
}

class _NavigateDrawerState extends State<NavigateDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      UserAccountsDrawerHeader(
        accountEmail: StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              var userDocument = snapshot.data;
              return Text(userDocument['email']);
            }),
        accountName: StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              var userDocument = snapshot.data;
              return Text(userDocument['first name']);
            }),
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
      ),
      ListTile(
        leading: new IconButton(
          icon: new Icon(Icons.home, color: Colors.black),
          onPressed: () => null,
        ),
        title: Text('Home'),
        onTap: () {
          print(widget.uid);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ServiceProviderHome(uid: widget.uid)),
          );
        },
      ),
    ]));
  }
}
