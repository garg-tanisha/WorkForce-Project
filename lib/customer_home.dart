import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:workforce/utils/widgets/preventive_measures_for_covid_19.dart';
import 'package:workforce/utils/widgets/contact_us.dart';
import 'package:workforce/utils/images_and_Labels.dart';
import 'package:workforce/utils/corousel_sliders.dart';

class CustomerHome extends StatefulWidget {
  CustomerHome({this.uid});
  // final String uid;
  final String uid;
  @override
  State<StatefulWidget> createState() => CustomerHomeState(uid);
}

class CustomerHomeState extends State {
// class CustomerHome extends StatelessWidget {
  final CarouselController _controller = CarouselController();
  String uid;
  final String title = "Customer Home";
  final List<Map<dynamic, dynamic>> lists = [];
  CustomerHomeState(String uid) {
    this.uid = uid;
  }
  int _current = 0;
  // int currentPos = 0;
  @override
  Widget build(BuildContext context) {
    int imageCount = (imgList.length / 2).round();
    List<int> list = [1, 2, 3, 4, 5];
    return WillPopScope(
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
          body: ListView(padding: const EdgeInsets.all(8), children: [
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
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
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
            ContactUs(),
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
                    padding:
                        EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                    child: Text("Recommended Services",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0)),
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
                        final int second =
                            index < imageCount - 1 ? first + 1 : null;

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
                                                BorderRadius.circular(10.0),
                                            child: Image.asset(imgList[idx],
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
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                        10.0) //                 <--- border radius here
                                                    ,
                                                    bottomRight: Radius.circular(
                                                        10.0) //                 <--- border radius here
                                                    ),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 20.0),
                                              child: Text(
                                                listPathsLabels[idx],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold,
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
    return new WillPopScope(
        onWillPop: () async => false,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
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
                        builder: (context) => CustomerHome(uid: widget.uid)),
                  );
                },
              ),
              ListTile(
                leading: new IconButton(
                  icon: new Icon(Icons.settings, color: Colors.black),
                  onPressed: () => null,
                ),
                title: Text('Settings'),
                onTap: () {
                  print(widget.uid);
                },
              ),
              ListTile(
                leading: new IconButton(
                  icon: new Icon(Icons.settings, color: Colors.black),
                  onPressed: () => null,
                ),
                title: Text('Notifications'),
                onTap: () {
                  print(widget.uid);
                },
              ),
            ],
          ),
        ));
  }
}
