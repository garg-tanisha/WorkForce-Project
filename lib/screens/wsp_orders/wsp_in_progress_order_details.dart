import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workforce/screens/chat/chat.dart';

class WSPInProgressOrderDetails extends StatefulWidget {
  WSPInProgressOrderDetails({this.wspId, this.orderId});
  // final String uid;
  final String wspId;
  final String orderId;
  @override
  State<StatefulWidget> createState() =>
      WSPInProgressOrderDetailsState(wspId, orderId);
}

class WSPInProgressOrderDetailsState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String wspId, orderId;

  WSPInProgressOrderDetailsState(String wspId, String orderId) {
    // this.uid = uid;
    this.wspId = wspId;
    this.orderId = orderId;
  }

  _makingPhoneCall(String phoneNo) async {
    String url = 'tel:' + phoneNo;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget images(var _images) {
    List<Widget> list = new List<Widget>();
    _images.forEach((image) async {
      list.add(Expanded(
          child: Image.network(
        image,
        width: 100,
        height: 100,
      )));
    });

    return new Row(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Order ( " + orderId + " )")),
        body: Column(children: [
          Padding(padding: EdgeInsets.all(20.0), child: Text("Order Details")),
          StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .document(orderId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return new Text("Loading");
                }
                var userDocument = snapshot.data;
                // return Text("Title: " + userDocument["title"]);
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(5.0)),
                      Text("Title: " + userDocument["title"]),
                      Text("Distance: " + userDocument["distance"].toString()),
                      Text("Service date and time: " +
                          DateTime.fromMicrosecondsSinceEpoch(
                                  userDocument["service date and time"]
                                      .microsecondsSinceEpoch)
                              .toString()),
                      Text("Time window: " +
                          DateTime.fromMicrosecondsSinceEpoch(
                                  userDocument["time window"]
                                      .microsecondsSinceEpoch)
                              .toString()),
                      Text("Service type: " + userDocument["service type"]),
                      Text("User id: " + userDocument["user id"]),
                      // images(userDocument["photos"]),
                      userDocument["photos"] != null
                          ? images(userDocument["photos"])
                          : CircularProgressIndicator(),

                      Padding(padding: EdgeInsets.all(5.0)),
                    ],
                  ),
                );
              }),
          Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("WSP Response Details")),
          StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("order id", isEqualTo: orderId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return Expanded(
                      child: SizedBox(
                          height: 200.0,
                          child: new ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                if (snapshot.hasError) {
                                  print(snapshot.error);
                                  return new Text('Error: ${snapshot.error}');
                                } else {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return new Text('Loading...');
                                    default:
                                      {
                                        if (!snapshot.hasData)
                                          return Text("Loading orders...");
                                        DocumentSnapshot course =
                                            snapshot.data.documents[index];
                                        return Card(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Description: " +
                                                    course["description"]),
                                                Text("Price: " +
                                                    course["price"].toString()),
                                                Text("Distance: " +
                                                    course["distance"]
                                                        .toString()),
                                                RaisedButton(
                                                  onPressed: () async {
                                                    print(
                                                        "Gives a platform to chat with customer");
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatPage(
                                                                  placedOrderId:
                                                                      course
                                                                          .documentID,
                                                                  userId:
                                                                      wspId)),
                                                    );
                                                  },
                                                  child: const Text(
                                                    "Chat",
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  color: Colors.lightBlueAccent,
                                                ),
                                                RaisedButton(
                                                  onPressed: () async {
                                                    print(Firestore.instance
                                                        .collection('users')
                                                        .document(
                                                            course["user id"])
                                                        .get()
                                                        .then((value) =>
                                                            _makingPhoneCall(value[
                                                                    "phone no"]
                                                                .toString())));
                                                  },
                                                  child: const Text(
                                                    "Call",
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  color: Colors.lightBlueAccent,
                                                ),
                                              ]),
                                        );
                                      }
                                  }
                                }
                              })));
                } else {
                  return Text("Invalid order id!");
                }
              }),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
