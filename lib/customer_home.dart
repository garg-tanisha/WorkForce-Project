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
List<String> listPaths = [
  "images/customer_home/carpenter.jpg",
  "images/customer_home/electrician.jpg",
  "images/customer_home/mechanic.jpg",
  "images/customer_home/plumber.jpg",
  "images/customer_home/sofa_cleaning.jpg",
  "images/customer_home/women_hair_cut_and_styling.jpg",
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
                          width: 1000.0,
                          // width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover),
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

  String uid;
  final String title = "Customer Home";
  final List<Map<dynamic, dynamic>> lists = [];
  CustomerHomeState(String uid) {
    this.uid = uid;
  }
  int currentPos = 0;

  @override
  Widget build(BuildContext context) {
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
                  GFCarousel(
                    autoPlay: true,
                    items: listPaths.map(
                      (url) {
                        return Container(
                          margin: EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(url,
                                  height: 500,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover),
                            ),
                            // Image.network(url,
                            //     fit: BoxFit.cover, width: 1000.0),
                          ),
                        );
                      },
                    ).toList(),
                    onPageChanged: (index) {
                      setState(() {
                        index;
                      });
                    },
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
                      return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Expanded(
                                      child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 0.0,
                                              bottom: 10.0,
                                              left: 5.0,
                                              right: 5.0),
                                          padding: EdgeInsets.only(
                                              top: 0.0,
                                              bottom: 5.0,
                                              left: 0.0,
                                              right: 0.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          child:
                                              // Column(children: <Widget>[
                                              Column(
                                                  // To centralize the children.
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: Image.asset(
                                                      listPaths[index],
                                                      height: 500,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      fit: BoxFit.cover),
                                                ),
                                                Text(listPathsLabels[index])
                                              ]))))));
                    },
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        CarouselSlider(
                          options: CarouselOptions(
                            autoPlay: true,
                            aspectRatio: 2.0,
                            enlargeCenterPage: true,
                          ),
                          items: imageSliders,
                        ),
                      ],
                    ),
                  ),
                  Container(
                      child: Column(
                    children: <Widget>[
                      CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                          enlargeStrategy: CenterPageEnlargeStrategy.height,
                        ),
                        items: imageSliders,
                      ),
                    ],
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: listPaths.map((url) {
                      int index = listPaths.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.only(
                            bottom: 20.0, left: 2.0, right: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPos == index
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
                        trailing: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
                        ),
                        leading: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
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
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Orders History",
                    ),
                  ),
                  Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                        trailing: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
                        ),
                        leading: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
                        ),
                        title: Text("Order Requests"),
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
                        trailing: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
                        ),
                        leading: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
                        ),
                        title: Text("Orders In Progress"),
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
                        trailing: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
                        ),
                        leading: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
                        ),
                        title: Text("Orders Completed"),
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
                        trailing: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
                        ),
                        leading: Icon(
                          Icons.add_location_alt_sharp,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Address',
                        ),
                        title: Text("Orders Cancelled"),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CustomerCancelledOrders(uid: uid),
                              ));
                        },
                      )),
                  Text("Preventive Measures To Fight Covid"),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Card(
                              color: Colors.white,
                              elevation: 2.0,
                              child: ListTile(
                                title: Text("Orders Cancelled"),
                                leading: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.blue,
                                  size: 30.0,
                                  semanticLabel: 'Password',
                                ),
                              )),
                        ),
                        Expanded(
                          child: Card(
                              color: Colors.white,
                              elevation: 2.0,
                              child: ListTile(
                                title: Text("Orders Cancelled"),
                                leading: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.blue,
                                  size: 30.0,
                                  semanticLabel: 'Password',
                                ),
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
                                title: Text("Orders Cancelled"),
                                leading: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.blue,
                                  size: 30.0,
                                  semanticLabel: 'Password',
                                ),
                              )),
                        ),
                        Expanded(
                          child: Card(
                              color: Colors.white,
                              elevation: 2.0,
                              child: ListTile(
                                title: Text("Orders Cancelled"),
                                leading: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.blue,
                                  size: 30.0,
                                  semanticLabel: 'Password',
                                ),
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
                                title: Text("Orders Cancelled"),
                                leading: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.blue,
                                  size: 30.0,
                                  semanticLabel: 'Password',
                                ),
                              )),
                        ),
                        Expanded(
                          child: Card(
                              color: Colors.white,
                              elevation: 2.0,
                              child: ListTile(
                                title: Text("Orders Cancelled"),
                                leading: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.blue,
                                  size: 30.0,
                                  semanticLabel: 'Password',
                                ),
                              )),
                        )
                      ]),
                  Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                        title: Text(
                            "For any questions or enquires contact us or whatsapp us at 98xxxxxxxx"),
                        leading: Icon(
                          Icons.lock_outlined,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Password',
                        ),
                      )),
                  Text("Recommeded Services"),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/customer_home/electrician.jpg',
                              width: 200,
                            ),
                            Text('Electrician')
                          ],
                        ),
                      )),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/customer_home/electrician.jpg',
                              width: 200,
                            ),
                            Text('Electrician')
                          ],
                        ),
                      )),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/customer_home/electrician.jpg',
                              width: 200,
                            ),
                            Text('Electrician')
                          ],
                        ),
                      )),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/customer_home/electrician.jpg',
                              width: 200,
                            ),
                            Text('Electrician')
                          ],
                        ),
                      )),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/customer_home/electrician.jpg',
                              width: 200,
                            ),
                            Text('Electrician')
                          ],
                        ),
                      )),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/customer_home/electrician.jpg',
                              width: 200,
                            ),
                            Text('Electrician')
                          ],
                        ),
                      )),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/customer_home/electrician.jpg',
                              width: 200,
                            ),
                            Text('Electrician')
                          ],
                        ),
                      )),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/customer_home/electrician.jpg',
                              width: 200,
                            ),
                            Text('Electrician')
                          ],
                        ),
                      )),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'images/customer_home/electrician.jpg',
                              width: 200,
                            ),
                            Text('Electrician')
                          ],
                        ),
                      )),
                    ],
                  )
                  // )
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
