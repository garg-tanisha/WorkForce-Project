import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderResponses extends StatefulWidget {
  OrderResponses({this.uid, this.orderId});
  final String uid;
  final String orderId;
  @override
  State<StatefulWidget> createState() => OrderResponsesState(uid, orderId);
}

class OrderResponsesState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String uid;
  String orderId;
  final List<Map<dynamic, dynamic>> lists = [];

  OrderResponsesState(String uid, String orderId) {
    this.uid = uid;
    this.orderId = orderId;
  }
  _onDropDownChanged(String value) {
    setState(() {
      this.filter = value;
    });
  }

  final filters = [
    'No Filter',
    'Ratings (Low To High)',
    'Ratings (High To Low)',
    'Price (Min To Max)',
    'Price (Max To Min)',
    'Response (Oldest to Latest)',
    'Response (Latest to Oldest)'
  ];
  String filter = 'No Filter';
  @override
  Widget build(BuildContext context) {
    if (filter == 'No Filter') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("ratings", descending: true)
                  .orderBy("price", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return Column(children: [
                    Text("Choose Filter"),
                    Card(
                      child: DropdownButton<String>(
                        //create an array of strings
                        items: filters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: filter,
                        onChanged: (String value) {
                          _onDropDownChanged(value);
                        },
                      ),
                    ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                    Expanded(
                        // height: 200.0,
                        child: ListView.builder(
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
                                            ListTile(
                                              title: Text("Description: " +
                                                  course["description"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n" +
                                                  "Ratings:" +
                                                  course["ratings"].toString() +
                                                  "\n" +
                                                  "Distance:" +
                                                  course["distance"]
                                                      .toString()),
                                              leading: RaisedButton(
                                                onPressed: () async {
                                                  //update "rejected" response
                                                  CollectionReference ref =
                                                      Firestore.instance.collection(
                                                          'accepted responses');

                                                  QuerySnapshot eventsQuery =
                                                      await ref
                                                          .where('order id',
                                                              isEqualTo:
                                                                  orderId)
                                                          .getDocuments();

                                                  eventsQuery.documents
                                                      .forEach((msgDoc) {
                                                    msgDoc.reference
                                                        .updateData({
                                                      "customer response":
                                                          "rejected",
                                                    });
                                                  });

                                                  //accepted request
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "accepted",
                                                  });

                                                  //changed order to "in progress"
                                                  Firestore.instance
                                                      .collection("orders")
                                                      .document(
                                                          course["order id"])
                                                      .updateData({
                                                    "status": "In Progress",
                                                  });

                                                  //added to placed orders
                                                  Firestore.instance
                                                      .collection(
                                                          "placed orders")
                                                      .add({
                                                    "wsp id": course["wsp id"],
                                                    "status": "In Progress",
                                                    "order id":
                                                        course["order id"],
                                                    "description":
                                                        course["description"],
                                                    "user id": uid,
                                                    "price": course["price"],
                                                    "service type":
                                                        course["role"],
                                                    // "service date and time": course[
                                                    //     "service date and time"]
                                                  });

                                                  //popped screen out
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "Accept",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.green,
                                              ),
                                              trailing: RaisedButton(
                                                onPressed: () async {
                                                  print(
                                                      "Reject the response and remove it from the feed");
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "rejected",
                                                  });

                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  "Reject",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No responses yet!");
                }
              }));
    } else if (filter == 'Ratings (Low To High)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("ratings")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return Column(children: [
                    Text("Choose Filter"),
                    Card(
                      child: DropdownButton<String>(
                        //create an array of strings
                        items: filters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: filter,
                        onChanged: (String value) {
                          _onDropDownChanged(value);
                        },
                      ),
                    ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                    Expanded(
                        // height: 200.0,
                        child: ListView.builder(
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
                                            ListTile(
                                              title: Text("Description: " +
                                                  course["description"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n" +
                                                  "Ratings:" +
                                                  course["ratings"].toString() +
                                                  "\n" +
                                                  "Distance:" +
                                                  course["distance"]
                                                      .toString()),
                                              leading: RaisedButton(
                                                onPressed: () async {
                                                  //update "rejected" response
                                                  CollectionReference ref =
                                                      Firestore.instance.collection(
                                                          'accepted responses');

                                                  QuerySnapshot eventsQuery =
                                                      await ref
                                                          .where('order id',
                                                              isEqualTo:
                                                                  orderId)
                                                          .getDocuments();

                                                  eventsQuery.documents
                                                      .forEach((msgDoc) {
                                                    msgDoc.reference
                                                        .updateData({
                                                      "customer response":
                                                          "rejected",
                                                    });
                                                  });

                                                  //accepted request
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "accepted",
                                                  });

                                                  //changed order to "in progress"
                                                  Firestore.instance
                                                      .collection("orders")
                                                      .document(
                                                          course["order id"])
                                                      .updateData({
                                                    "status": "In Progress",
                                                  });

                                                  //added to placed orders
                                                  Firestore.instance
                                                      .collection(
                                                          "placed orders")
                                                      .add({
                                                    "wsp id": course["wsp id"],
                                                    "status": "In Progress",
                                                    "order id":
                                                        course["order id"],
                                                    "description":
                                                        course["description"],
                                                    "user id": uid,
                                                    "price": course["price"],
                                                    "service type":
                                                        course["role"],
                                                    // "service date and time": course[
                                                    //     "service date and time"]
                                                  });

                                                  //popped screen out
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "Accept",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.green,
                                              ),
                                              trailing: RaisedButton(
                                                onPressed: () async {
                                                  print(
                                                      "Reject the response and remove it from the feed");
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "rejected",
                                                  });

                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  "Reject",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No responses yet!");
                }
              }));
    } else if (filter == 'Ratings (High To Low)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("ratings", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return Column(children: [
                    Text("Choose Filter"),
                    Card(
                      child: DropdownButton<String>(
                        //create an array of strings
                        items: filters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: filter,
                        onChanged: (String value) {
                          _onDropDownChanged(value);
                        },
                      ),
                    ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                    Expanded(
                        // height: 200.0,
                        child: ListView.builder(
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
                                            ListTile(
                                              title: Text("Description: " +
                                                  course["description"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n" +
                                                  "Ratings:" +
                                                  course["ratings"].toString() +
                                                  "\n" +
                                                  "Distance:" +
                                                  course["distance"]
                                                      .toString()),
                                              leading: RaisedButton(
                                                onPressed: () async {
                                                  //update "rejected" response
                                                  CollectionReference ref =
                                                      Firestore.instance.collection(
                                                          'accepted responses');

                                                  QuerySnapshot eventsQuery =
                                                      await ref
                                                          .where('order id',
                                                              isEqualTo:
                                                                  orderId)
                                                          .getDocuments();

                                                  eventsQuery.documents
                                                      .forEach((msgDoc) {
                                                    msgDoc.reference
                                                        .updateData({
                                                      "customer response":
                                                          "rejected",
                                                    });
                                                  });

                                                  //accepted request
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "accepted",
                                                  });

                                                  //changed order to "in progress"
                                                  Firestore.instance
                                                      .collection("orders")
                                                      .document(
                                                          course["order id"])
                                                      .updateData({
                                                    "status": "In Progress",
                                                  });

                                                  //added to placed orders
                                                  Firestore.instance
                                                      .collection(
                                                          "placed orders")
                                                      .add({
                                                    "wsp id": course["wsp id"],
                                                    "status": "In Progress",
                                                    "order id":
                                                        course["order id"],
                                                    "description":
                                                        course["description"],
                                                    "user id": uid,
                                                    "price": course["price"],
                                                    "service type":
                                                        course["role"],
                                                    // "service date and time": course[
                                                    //     "service date and time"]
                                                  });

                                                  //popped screen out
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "Accept",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.green,
                                              ),
                                              trailing: RaisedButton(
                                                onPressed: () async {
                                                  print(
                                                      "Reject the response and remove it from the feed");
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "rejected",
                                                  });

                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  "Reject",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No responses yet!");
                }
              }));
    } else if (filter == 'Price (Min To Max)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("price")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return Column(children: [
                    Text("Choose Filter"),
                    Card(
                      child: DropdownButton<String>(
                        //create an array of strings
                        items: filters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: filter,
                        onChanged: (String value) {
                          _onDropDownChanged(value);
                        },
                      ),
                    ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                    Expanded(
                        // height: 200.0,
                        child: ListView.builder(
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
                                            ListTile(
                                              title: Text("Description: " +
                                                  course["description"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n" +
                                                  "Ratings:" +
                                                  course["ratings"].toString() +
                                                  "\n" +
                                                  "Distance:" +
                                                  course["distance"]
                                                      .toString()),
                                              leading: RaisedButton(
                                                onPressed: () async {
                                                  //update "rejected" response
                                                  CollectionReference ref =
                                                      Firestore.instance.collection(
                                                          'accepted responses');

                                                  QuerySnapshot eventsQuery =
                                                      await ref
                                                          .where('order id',
                                                              isEqualTo:
                                                                  orderId)
                                                          .getDocuments();

                                                  eventsQuery.documents
                                                      .forEach((msgDoc) {
                                                    msgDoc.reference
                                                        .updateData({
                                                      "customer response":
                                                          "rejected",
                                                    });
                                                  });

                                                  //accepted request
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "accepted",
                                                  });

                                                  //changed order to "in progress"
                                                  Firestore.instance
                                                      .collection("orders")
                                                      .document(
                                                          course["order id"])
                                                      .updateData({
                                                    "status": "In Progress",
                                                  });

                                                  //added to placed orders
                                                  Firestore.instance
                                                      .collection(
                                                          "placed orders")
                                                      .add({
                                                    "wsp id": course["wsp id"],
                                                    "status": "In Progress",
                                                    "order id":
                                                        course["order id"],
                                                    "description":
                                                        course["description"],
                                                    "user id": uid,
                                                    "price": course["price"],
                                                    "service type":
                                                        course["role"],
                                                    // "service date and time": course[
                                                    //     "service date and time"]
                                                  });

                                                  //popped screen out
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "Accept",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.green,
                                              ),
                                              trailing: RaisedButton(
                                                onPressed: () async {
                                                  print(
                                                      "Reject the response and remove it from the feed");
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "rejected",
                                                  });

                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  "Reject",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No responses yet!");
                }
              }));
    } else if (filter == 'Price (Max To Min)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("price", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return Column(children: [
                    Text("Choose Filter"),
                    Card(
                      child: DropdownButton<String>(
                        //create an array of strings
                        items: filters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: filter,
                        onChanged: (String value) {
                          _onDropDownChanged(value);
                        },
                      ),
                    ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                    Expanded(
                        // height: 200.0,
                        child: ListView.builder(
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
                                            ListTile(
                                              title: Text("Description: " +
                                                  course["description"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n" +
                                                  "Ratings:" +
                                                  course["ratings"].toString() +
                                                  "\n" +
                                                  "Distance:" +
                                                  course["distance"]
                                                      .toString()),
                                              leading: RaisedButton(
                                                onPressed: () async {
                                                  //update "rejected" response
                                                  CollectionReference ref =
                                                      Firestore.instance.collection(
                                                          'accepted responses');

                                                  QuerySnapshot eventsQuery =
                                                      await ref
                                                          .where('order id',
                                                              isEqualTo:
                                                                  orderId)
                                                          .getDocuments();

                                                  eventsQuery.documents
                                                      .forEach((msgDoc) {
                                                    msgDoc.reference
                                                        .updateData({
                                                      "customer response":
                                                          "rejected",
                                                    });
                                                  });

                                                  //accepted request
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "accepted",
                                                  });

                                                  //changed order to "in progress"
                                                  Firestore.instance
                                                      .collection("orders")
                                                      .document(
                                                          course["order id"])
                                                      .updateData({
                                                    "status": "In Progress",
                                                  });

                                                  //added to placed orders
                                                  Firestore.instance
                                                      .collection(
                                                          "placed orders")
                                                      .add({
                                                    "wsp id": course["wsp id"],
                                                    "status": "In Progress",
                                                    "order id":
                                                        course["order id"],
                                                    "description":
                                                        course["description"],
                                                    "user id": uid,
                                                    "price": course["price"],
                                                    "service type":
                                                        course["role"],
                                                    // "service date and time": course[
                                                    //     "service date and time"]
                                                  });

                                                  //popped screen out
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "Accept",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.green,
                                              ),
                                              trailing: RaisedButton(
                                                onPressed: () async {
                                                  print(
                                                      "Reject the response and remove it from the feed");
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "rejected",
                                                  });

                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  "Reject",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No responses yet!");
                }
              }));
    } else if (filter == 'Response (Oldest to Latest)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("date time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return Column(children: [
                    Text("Choose Filter"),
                    Card(
                      child: DropdownButton<String>(
                        //create an array of strings
                        items: filters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: filter,
                        onChanged: (String value) {
                          _onDropDownChanged(value);
                        },
                      ),
                    ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                    Expanded(
                        // height: 200.0,
                        child: ListView.builder(
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
                                            ListTile(
                                              title: Text("Description: " +
                                                  course["description"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n" +
                                                  "Ratings:" +
                                                  course["ratings"].toString() +
                                                  "\n" +
                                                  "Distance:" +
                                                  course["distance"]
                                                      .toString()),
                                              leading: RaisedButton(
                                                onPressed: () async {
                                                  //update "rejected" response
                                                  CollectionReference ref =
                                                      Firestore.instance.collection(
                                                          'accepted responses');

                                                  QuerySnapshot eventsQuery =
                                                      await ref
                                                          .where('order id',
                                                              isEqualTo:
                                                                  orderId)
                                                          .getDocuments();

                                                  eventsQuery.documents
                                                      .forEach((msgDoc) {
                                                    msgDoc.reference
                                                        .updateData({
                                                      "customer response":
                                                          "rejected",
                                                    });
                                                  });

                                                  //accepted request
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "accepted",
                                                  });

                                                  //changed order to "in progress"
                                                  Firestore.instance
                                                      .collection("orders")
                                                      .document(
                                                          course["order id"])
                                                      .updateData({
                                                    "status": "In Progress",
                                                  });

                                                  //added to placed orders
                                                  Firestore.instance
                                                      .collection(
                                                          "placed orders")
                                                      .add({
                                                    "wsp id": course["wsp id"],
                                                    "status": "In Progress",
                                                    "order id":
                                                        course["order id"],
                                                    "description":
                                                        course["description"],
                                                    "user id": uid,
                                                    "price": course["price"],
                                                    "service type":
                                                        course["role"],
                                                    // "service date and time": course[
                                                    //     "service date and time"]
                                                  });

                                                  //popped screen out
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "Accept",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.green,
                                              ),
                                              trailing: RaisedButton(
                                                onPressed: () async {
                                                  print(
                                                      "Reject the response and remove it from the feed");
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "rejected",
                                                  });

                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  "Reject",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No responses yet!");
                }
              }));
    } else if (filter == 'Response (Latest to Oldest)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("date time", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return Column(children: [
                    Text("Choose Filter"),
                    Card(
                      child: DropdownButton<String>(
                        //create an array of strings
                        items: filters.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: filter,
                        onChanged: (String value) {
                          _onDropDownChanged(value);
                        },
                      ),
                    ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                    Expanded(
                        // height: 200.0,
                        child: ListView.builder(
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
                                            ListTile(
                                              title: Text("Description: " +
                                                  course["description"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n" +
                                                  "Ratings:" +
                                                  course["ratings"].toString() +
                                                  "\n" +
                                                  "Distance:" +
                                                  course["distance"]
                                                      .toString()),
                                              leading: RaisedButton(
                                                onPressed: () async {
                                                  //update "rejected" response
                                                  CollectionReference ref =
                                                      Firestore.instance.collection(
                                                          'accepted responses');

                                                  QuerySnapshot eventsQuery =
                                                      await ref
                                                          .where('order id',
                                                              isEqualTo:
                                                                  orderId)
                                                          .getDocuments();

                                                  eventsQuery.documents
                                                      .forEach((msgDoc) {
                                                    msgDoc.reference
                                                        .updateData({
                                                      "customer response":
                                                          "rejected",
                                                    });
                                                  });

                                                  //accepted request
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "accepted",
                                                  });

                                                  //changed order to "in progress"
                                                  Firestore.instance
                                                      .collection("orders")
                                                      .document(
                                                          course["order id"])
                                                      .updateData({
                                                    "status": "In Progress",
                                                  });

                                                  //added to placed orders
                                                  Firestore.instance
                                                      .collection(
                                                          "placed orders")
                                                      .add({
                                                    "wsp id": course["wsp id"],
                                                    "status": "In Progress",
                                                    "order id":
                                                        course["order id"],
                                                    "description":
                                                        course["description"],
                                                    "user id": uid,
                                                    "price": course["price"],
                                                    "service type":
                                                        course["role"],
                                                    "distance":
                                                        course["distance"]
                                                    // "service date and time": course[
                                                    //     "service date and time"]
                                                  });

                                                  //popped screen out
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "Accept",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.green,
                                              ),
                                              trailing: RaisedButton(
                                                onPressed: () async {
                                                  print(
                                                      "Reject the response and remove it from the feed");
                                                  Firestore.instance
                                                      .collection(
                                                          "accepted responses")
                                                      .document(
                                                          course.documentID)
                                                      .updateData({
                                                    "customer response":
                                                        "rejected",
                                                  });

                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  "Reject",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No responses yet!");
                }
              }));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
