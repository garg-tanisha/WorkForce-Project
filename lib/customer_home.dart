import 'package:workforce/screens/customer_orders/customer_in_progress_or_completed_orders.dart';
import 'package:workforce/screens/customer_orders/customer_cancelled_orders.dart';
import 'package:workforce/screens/customer_orders/customer_order_new.dart';
import 'package:workforce/screens/customer_orders/place_order.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:getwidget/getwidget.dart';
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
// List<String> listPaths = [
//   "images/customer_home/carpenter.jpg",
//   "images/customer_home/electrician.jpg",
//   "images/customer_home/mechanic.jpg",
//   "images/customer_home/plumber.jpg",
//   "images/customer_home/sofa_cleaning.jpg",
//   "images/customer_home/women_hair_cut_and_styling.jpg",
// ];
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WillPopScope(
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
              body: ListView(
                padding: const EdgeInsets.all(8),
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
                  Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                        title: Text("Place Order"),
                        leading: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Place Order',
                        ),
                        trailing: Icon(
                          Icons.arrow_right_outlined,
                          color: Colors.blue,
                          size: 40.0,
                          semanticLabel: 'Right Arrow',
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaceOrder(
                                  uid: uid,
                                ),
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Order's Status",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0)),
                        ),
                      ),
                      Card(
                          color: Colors.white,
                          elevation: 2.0,
                          child: ListTile(
                            leading: Icon(
                              Icons.add_location_alt_sharp,
                              color: Colors.blue,
                              size: 30.0,
                              semanticLabel: 'New Orders',
                            ),
                            trailing: Icon(
                              Icons.arrow_right_outlined,
                              color: Colors.blue,
                              size: 40.0,
                              semanticLabel: 'Right Arrow',
                            ),
                            title: Text("New"),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  //builder of MaterialPageRoute will call TodoDetail class
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerNewOrders(uid: uid),
                                  ));
                            },
                          )),
                      Card(
                          color: Colors.white,
                          elevation: 2.0,
                          child: ListTile(
                            leading: Icon(
                              Icons.add_location_alt_sharp,
                              color: Colors.blue,
                              size: 30.0,
                              semanticLabel: 'In Progress Orders',
                            ),
                            trailing: Icon(
                              Icons.arrow_right_outlined,
                              color: Colors.blue,
                              size: 40.0,
                              semanticLabel: 'Right Arrow',
                            ),
                            title: Text("In Progress"),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerInProgressOrCompletedOrders(
                                            uid: uid, status: "In Progress"),
                                  ));
                            },
                          )),
                      Card(
                          color: Colors.white,
                          elevation: 2.0,
                          child: ListTile(
                            leading: Icon(
                              Icons.arrow_right_outlined,
                              color: Colors.blue,
                              size: 40.0,
                              semanticLabel: 'Completed Orders',
                            ),
                            trailing: Icon(
                              Icons.arrow_right_outlined,
                              color: Colors.blue,
                              size: 40.0,
                              semanticLabel: 'Right Arrow',
                            ),
                            title: Text("Completed"),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerInProgressOrCompletedOrders(
                                            uid: uid, status: "Completed"),
                                  ));
                            },
                          )),
                      Card(
                          color: Colors.white,
                          elevation: 2.0,
                          child: ListTile(
                            leading: Icon(
                              Icons.add_location_alt_sharp,
                              color: Colors.blue,
                              size: 30.0,
                              semanticLabel: 'Cancelled Orders',
                            ),
                            trailing: Icon(
                              Icons.arrow_right_outlined,
                              color: Colors.blue,
                              size: 40.0,
                              semanticLabel: 'Right Arrow',
                            ),
                            title: Text("Cancelled"),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerCancelledOrders(uid: uid),
                                  ));
                            },
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
                          padding: EdgeInsets.all(10.0),
                          child: Text("Preventive Measures To Fight Covid",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0)),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Card(
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: ListTile(
                                    title: Text(
                                        "Wash your hands timely for atleast 30 seconds.",
                                        style: TextStyle(fontSize: 13.0)),
                                    leading: Image.asset(imgList[0],
                                        width: 40.0,
                                        height: 40.0,
                                        fit: BoxFit.cover),
                                  )),
                            ),
                            Expanded(
                              child: Card(
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: ListTile(
                                    title: Text(
                                        "Use soaps or alcohol based sanitizers.",
                                        style: TextStyle(fontSize: 13.0)),
                                    leading: Image.asset(imgList[0],
                                        width: 40.0,
                                        height: 40.0,
                                        fit: BoxFit.cover),
                                  )),
                            )
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Card(
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: ListTile(
                                    title: Text(
                                        "Do social distancing. Avoid any close contact with sick people.",
                                        style: TextStyle(fontSize: 13.0)),
                                    leading: Image.asset(imgList[0],
                                        width: 40.0,
                                        height: 40.0,
                                        fit: BoxFit.cover),
                                  )),
                            ),
                            Expanded(
                              child: Card(
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: ListTile(
                                    title: Text(
                                        "Avoid touching your nose, eyes or face with unclean hands.",
                                        style: TextStyle(fontSize: 13.0)),
                                    leading: Image.asset(imgList[0],
                                        width: 40.0,
                                        height: 40.0,
                                        fit: BoxFit.cover),
                                  )),
                            )
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Card(
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: ListTile(
                                      title: Text(
                                          "Cover nose and mouth with mask. Sneeze/cough into your elbow.",
                                          style: TextStyle(fontSize: 13.0)),
                                      leading: Image.asset(imgList[0],
                                          width: 40.0,
                                          height: 40.0,
                                          fit: BoxFit.cover))),
                            ),
                            Expanded(
                              child: Card(
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: ListTile(
                                    title: Text(
                                        "Isolation and social distancing are very important to stay safe.",
                                        style: TextStyle(fontSize: 13.0)),
                                    leading: Image.asset(imgList[0],
                                        width: 40.0,
                                        height: 40.0,
                                        fit: BoxFit.cover),
                                  )),
                            )
                          ]),
                    ]),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width.roundToDouble(),
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
                      Card(
                          color: Colors.white,
                          elevation: 2.0,
                          child: ListTile(
                            title: RichText(
                              text: new TextSpan(
                                style: new TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
                                  new TextSpan(
                                      text: 'For any questions or enquires '),
                                  new TextSpan(
                                      text: 'contact us or whatsapp us',
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold)),
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
                          padding: EdgeInsets.all(10.0),
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
                ],
              ),
              drawer: NavigateDrawer(uid: this.uid))),
    );
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
