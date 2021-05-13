import 'package:workforce/service_provider_homepage.dart';
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
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Choose your role",
                  ),
                ),
                Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: ListTile(
                      title: Text("Customer"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerHome(
                                uid: uid,
                              ),
                            ));
                      },
                    )),
                Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: ListTile(
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
                    builder: (context) => UserRoles(uid: widget.uid)),
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
    );
  }
}
