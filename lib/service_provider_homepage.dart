import 'package:workforce/screens/wsp_orders/wsp_order_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class ServiceProviderHome extends StatelessWidget {
  ServiceProviderHome({this.uid});
  final String uid;
  final String title = "WSP HomePage";
  List<dynamic> roles = [];
  List<dynamic> rating = [];

  @override
  Widget build(BuildContext context) {
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
            body: Column(
              children: [
                Text("Services"),
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
                            return Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ListTile(
                                    title: rating[index] != "null"
                                        ? Text(roles[index] +
                                            " (Rating: " +
                                            rating[index] +
                                            " )")
                                        : Text(roles[index] +
                                            " (Rating: No rating yet )"),
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
                                ],
                              ),
                            );
                          });
                    }),
                Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: ListTile(
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
              ],
            ),
            drawer: NavigateDrawer(uid: this.uid)));
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
