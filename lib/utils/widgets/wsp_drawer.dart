import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workforce/service_provider_homepage.dart';
import 'package:flutter/material.dart';

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
