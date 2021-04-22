import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/customer_orders/customer_in_progress_or_completed_orders.dart';
import 'package:workforce/screens/customer_orders/customer_order_new.dart';
import 'package:workforce/screens/customer_orders/place_order.dart';
import 'package:workforce/screens/customer_orders/customer_cancelled_orders.dart';
import 'main.dart';

class Home extends StatelessWidget {
  Home({this.uid});
  final String uid;
  final String title = "Customer Home";
  final List<Map<dynamic, dynamic>> lists = [];

  @override
  Widget build(BuildContext context) {
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
                  Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                        title: Text("Place Order"),
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
                        title: Text("Orders In Progress"),
                        onTap: () {
                          Navigator.push(
                              context,
                              //builder of MaterialPageRoute will call TodoDetail class
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
                        title: Text("Orders Completed"),
                        onTap: () {
                          Navigator.push(
                              context,
                              //builder of MaterialPageRoute will call TodoDetail class
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
                        title: Text("Orders Cancelled"),
                        onTap: () {
                          Navigator.push(
                              context,
                              //builder of MaterialPageRoute will call TodoDetail class
                              MaterialPageRoute(
                                builder: (context) =>
                                    CustomerCancelledOrders(uid: uid),
                              ));
                        },
                      )),
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
                        builder: (context) => Home(uid: widget.uid)),
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
