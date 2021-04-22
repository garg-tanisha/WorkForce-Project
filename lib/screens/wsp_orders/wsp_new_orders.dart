import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' show cos, sqrt, asin;

class Orders extends StatefulWidget {
  Orders({this.uid, this.role});
  final String uid;
  final String role;
  @override
  State<StatefulWidget> createState() => OrdersState(uid, role);
}

class OrdersState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final filters = [
    'No filter',
    'Oldest Orders To Latest Orders',
    'Latest Orders To Oldest Orders',
    'Price (Low To High)',
    'Price (High To Low)',
    'Distance (Close To Far)',
    'Service Date And Time (Asc)',
    'Service Date And Time (Dsc)',
    'Time Window (Min to Max)',
    'Time Window (Max to Min'
  ];
  String filter = 'No filter';
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String uid;
  String role;
  List<String> orders = [];
  bool isLiked = false;
  double rating;
  bool ratingIsNull = false;
  double wsp_latitude;
  double wsp_longitude;
  OrdersState(String uid, String role) {
    this.uid = uid;
    this.role = role;
  }

  bool checkDistance(
      double orderlatitude, double orderLongitude, var orderDistance) {
    return (calculateDistance(
            orderlatitude, orderLongitude, wsp_latitude, wsp_longitude) <=
        orderDistance);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    super.initState();
    initRating();
  }

  void initRating() {
    Firestore.instance.collection("users").document(uid).get().then((doc) {
      wsp_latitude = doc["latitude"];
      wsp_longitude = doc["longitude"];
      if (doc["roles"][role] != "null") {
        rating = double.parse(doc["roles"][role]);
        ratingIsNull = false;
      } else {
        ratingIsNull = true;
      }
    });
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
    if (filter == 'No filter') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return Column(children: [
                    Text("Choose Filter"),
                    Flexible(
                      child: Card(
                        child: Flexible(
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
                        ),
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");
                                      else if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      else {
                                        DocumentSnapshot course =
                                            snapshot.data.documents[index];
                                        Firestore.instance
                                            .collection("orders")
                                            .document(course.documentID)
                                            .collection("responses")
                                            .document(uid)
                                            .get()
                                            .then((doc) {
                                          if (!doc.exists) {
                                            orders.add(course.documentID);
                                            print('No such document! ' +
                                                course.documentID);
                                          } else {
                                            print("Document exists! " +
                                                course.documentID);
                                          }
                                        });

                                        if (course["ratings"] != null) {
                                          if (checkDistance(
                                                  course["latitude"],
                                                  course["longitude"],
                                                  course["distance"]) &&
                                              (ratingIsNull ||
                                                  (rating >=
                                                      course["ratings"]))) {
                                            return Card(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  ListTile(
                                                    title: Text("Title: " +
                                                        course["title"]),
                                                    subtitle: Text("Price: " +
                                                        course["price"]
                                                            .toString()),
                                                    leading: RaisedButton(
                                                      onPressed: () async {
                                                        print(
                                                            "REMOVE from feed and move to confirmations sent page/tab.");
                                                        await _asyncSimpleDialog(
                                                            context,
                                                            course.documentID,
                                                            calculateDistance(
                                                                course[
                                                                    "latitude"],
                                                                course[
                                                                    "longitude"],
                                                                wsp_latitude,
                                                                wsp_longitude));
                                                      },
                                                      child: const Text(
                                                        "Accept",
                                                        style: TextStyle(
                                                            fontSize: 15.0),
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),
                                                      color: Colors.green,
                                                    ),
                                                    trailing: RaisedButton(
                                                      onPressed: () async {
                                                        print(
                                                            "Remove from feed!");
                                                        Firestore.instance
                                                            .collection(
                                                                "orders")
                                                            .document(course
                                                                .documentID)
                                                            .collection(
                                                                "responses")
                                                            .document(uid)
                                                            .setData({
                                                          "wsp response":
                                                              "rejected",
                                                        });

                                                        Firestore.instance
                                                            .collection(
                                                                "rejected responses")
                                                            .add({
                                                          "wsp id": uid,
                                                          "order id":
                                                              course.documentID,
                                                          "date time":
                                                              DateTime.now()
                                                        }).then((res) {
                                                          isLoading = false;
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  content: Text(
                                                                      "Rejected Order"),
                                                                  actions: [
                                                                    FlatButton(
                                                                      child: Text(
                                                                          "Ok"),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                    )
                                                                  ],
                                                                );
                                                              });

                                                          setState(() {});
                                                        }).catchError((err) {
                                                          print(err.message);
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Error"),
                                                                  content: Text(
                                                                      err.message),
                                                                  actions: [
                                                                    FlatButton(
                                                                      child: Text(
                                                                          "Ok"),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                    )
                                                                  ],
                                                                );
                                                              });
                                                        });
                                                      },
                                                      child: const Text(
                                                        "Reject",
                                                        style: TextStyle(
                                                            fontSize: 15.0),
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  course["photos"] != null
                                                      ? images(course["photos"])
                                                      : Container(
                                                          width: 0.0,
                                                          height: 0.0),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return Container(
                                                width: 0.0, height: 0.0);
                                          }
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
                // }
              }));
    } else if (filter == 'Oldest Orders To Latest Orders') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .orderBy("time window")
                  .orderBy('date time')
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");

                                      if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);

                                      DocumentSnapshot course =
                                          snapshot.data.documents[index];
                                      Firestore.instance
                                          .collection("orders")
                                          .document(course.documentID)
                                          .collection("responses")
                                          .document(uid)
                                          .get()
                                          .then((doc) {
                                        if (!doc.exists) {
                                          orders.add(course.documentID);
                                          print('No such document! ' +
                                              course.documentID);
                                        } else {
                                          print("Document exists! " +
                                              course.documentID);
                                        }
                                      });

                                      // if (orders.contains(course.documentID)) {
                                      if (course["ratings"] != null) {
                                        if (checkDistance(
                                                course["latitude"],
                                                course["longitude"],
                                                course["distance"]) &&
                                            (ratingIsNull ||
                                                (rating >=
                                                    course["ratings"]))) {
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  title: Text("Title: " +
                                                      course["title"]),
                                                  subtitle: Text("Price: " +
                                                      course["price"]
                                                          .toString()),
                                                  leading: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "REMOVE from feed and move to confirmations sent page/tab.");
                                                      await _asyncSimpleDialog(
                                                          context,
                                                          course.documentID,
                                                          calculateDistance(
                                                              course[
                                                                  "latitude"],
                                                              course[
                                                                  "longitude"],
                                                              wsp_latitude,
                                                              wsp_longitude));
                                                    },
                                                    child: const Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.green,
                                                  ),
                                                  trailing: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "Remove from feed!");
                                                      Firestore.instance
                                                          .collection("orders")
                                                          .document(
                                                              course.documentID)
                                                          .collection(
                                                              "responses")
                                                          .document(uid)
                                                          .setData({
                                                        "wsp response":
                                                            "rejected"
                                                      });

                                                      Firestore.instance
                                                          .collection(
                                                              "rejected responses")
                                                          .add({
                                                        "wsp id": uid,
                                                        "order id":
                                                            course.documentID,
                                                      }).then((res) {
                                                        isLoading = false;
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Rejected Order"),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        setState(() {});
                                                      }).catchError((err) {
                                                        print(err.message);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Error"),
                                                                content: Text(
                                                                    err.message),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                course["photos"] != null
                                                    ? images(course["photos"])
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      } else {
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
                // }
              }));
    } else if (filter == 'Latest Orders To Oldest Orders') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .orderBy("time window")
                  .orderBy('date time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");

                                      if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);

                                      DocumentSnapshot course =
                                          snapshot.data.documents[index];
                                      Firestore.instance
                                          .collection("orders")
                                          .document(course.documentID)
                                          .collection("responses")
                                          .document(uid)
                                          .get()
                                          .then((doc) {
                                        if (!doc.exists) {
                                          orders.add(course.documentID);
                                          print('No such document! ' +
                                              course.documentID);
                                        } else {
                                          print("Document exists! " +
                                              course.documentID);
                                        }
                                      });

                                      // if (orders.contains(course.documentID)) {
                                      if (course["ratings"] != null) {
                                        if (checkDistance(
                                                course["latitude"],
                                                course["longitude"],
                                                course["distance"]) &&
                                            (ratingIsNull ||
                                                (rating >=
                                                    course["ratings"]))) {
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  title: Text("Title: " +
                                                      course["title"]),
                                                  subtitle: Text("Price: " +
                                                      course["price"]
                                                          .toString()),
                                                  leading: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "REMOVE from feed and move to confirmations sent page/tab.");
                                                      await _asyncSimpleDialog(
                                                          context,
                                                          course.documentID,
                                                          calculateDistance(
                                                              course[
                                                                  "latitude"],
                                                              course[
                                                                  "longitude"],
                                                              wsp_latitude,
                                                              wsp_longitude));
                                                    },
                                                    child: const Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.green,
                                                  ),
                                                  trailing: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "Remove from feed!");
                                                      Firestore.instance
                                                          .collection("orders")
                                                          .document(
                                                              course.documentID)
                                                          .collection(
                                                              "responses")
                                                          .document(uid)
                                                          .setData({
                                                        "wsp response":
                                                            "rejected"
                                                      });

                                                      Firestore.instance
                                                          .collection(
                                                              "rejected responses")
                                                          .add({
                                                        "wsp id": uid,
                                                        "order id":
                                                            course.documentID,
                                                      }).then((res) {
                                                        isLoading = false;
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Rejected Order"),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        setState(() {});
                                                      }).catchError((err) {
                                                        print(err.message);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Error"),
                                                                content: Text(
                                                                    err.message),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                course["photos"] != null
                                                    ? images(course["photos"])
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      } else {
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
                // }
              }));
    } else if (filter == 'Price (Low To High)') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .orderBy("time window")
                  .orderBy('price')
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");

                                      if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);

                                      DocumentSnapshot course =
                                          snapshot.data.documents[index];
                                      Firestore.instance
                                          .collection("orders")
                                          .document(course.documentID)
                                          .collection("responses")
                                          .document(uid)
                                          .get()
                                          .then((doc) {
                                        if (!doc.exists) {
                                          orders.add(course.documentID);
                                          print('No such document! ' +
                                              course.documentID);
                                        } else {
                                          print("Document exists! " +
                                              course.documentID);
                                        }
                                      });

                                      // if (orders.contains(course.documentID)) {
                                      if (course["ratings"] != null) {
                                        if (checkDistance(
                                                course["latitude"],
                                                course["longitude"],
                                                course["distance"]) &&
                                            (ratingIsNull ||
                                                (rating >=
                                                    course["ratings"]))) {
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  title: Text("Title: " +
                                                      course["title"]),
                                                  subtitle: Text("Price: " +
                                                      course["price"]
                                                          .toString()),
                                                  leading: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "REMOVE from feed and move to confirmations sent page/tab.");
                                                      await _asyncSimpleDialog(
                                                          context,
                                                          course.documentID,
                                                          calculateDistance(
                                                              course[
                                                                  "latitude"],
                                                              course[
                                                                  "longitude"],
                                                              wsp_latitude,
                                                              wsp_longitude));
                                                    },
                                                    child: const Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.green,
                                                  ),
                                                  trailing: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "Remove from feed!");
                                                      Firestore.instance
                                                          .collection("orders")
                                                          .document(
                                                              course.documentID)
                                                          .collection(
                                                              "responses")
                                                          .document(uid)
                                                          .setData({
                                                        "wsp response":
                                                            "rejected"
                                                      });

                                                      Firestore.instance
                                                          .collection(
                                                              "rejected responses")
                                                          .add({
                                                        "wsp id": uid,
                                                        "order id":
                                                            course.documentID,
                                                      }).then((res) {
                                                        isLoading = false;
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Rejected Order"),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        setState(() {});
                                                      }).catchError((err) {
                                                        print(err.message);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Error"),
                                                                content: Text(
                                                                    err.message),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                course["photos"] != null
                                                    ? images(course["photos"])
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      } else {
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
                // }
              }));
    } else if (filter == 'Price (High To Low)') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .orderBy("time window")
                  .orderBy('price', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");

                                      if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);

                                      DocumentSnapshot course =
                                          snapshot.data.documents[index];
                                      Firestore.instance
                                          .collection("orders")
                                          .document(course.documentID)
                                          .collection("responses")
                                          .document(uid)
                                          .get()
                                          .then((doc) {
                                        if (!doc.exists) {
                                          orders.add(course.documentID);
                                          print('No such document! ' +
                                              course.documentID);
                                        } else {
                                          print("Document exists! " +
                                              course.documentID);
                                        }
                                      });

                                      // if (orders.contains(course.documentID)) {
                                      if (course["ratings"] != null) {
                                        if (checkDistance(
                                                course["latitude"],
                                                course["longitude"],
                                                course["distance"]) &&
                                            (ratingIsNull ||
                                                (rating >=
                                                    course["ratings"]))) {
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  title: Text("Title: " +
                                                      course["title"]),
                                                  subtitle: Text("Price: " +
                                                      course["price"]
                                                          .toString()),
                                                  leading: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "REMOVE from feed and move to confirmations sent page/tab.");
                                                      await _asyncSimpleDialog(
                                                          context,
                                                          course.documentID,
                                                          calculateDistance(
                                                              course[
                                                                  "latitude"],
                                                              course[
                                                                  "longitude"],
                                                              wsp_latitude,
                                                              wsp_longitude));
                                                    },
                                                    child: const Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.green,
                                                  ),
                                                  trailing: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "Remove from feed!");
                                                      Firestore.instance
                                                          .collection("orders")
                                                          .document(
                                                              course.documentID)
                                                          .collection(
                                                              "responses")
                                                          .document(uid)
                                                          .setData({
                                                        "wsp response":
                                                            "rejected"
                                                      });

                                                      Firestore.instance
                                                          .collection(
                                                              "rejected responses")
                                                          .add({
                                                        "wsp id": uid,
                                                        "order id":
                                                            course.documentID,
                                                      }).then((res) {
                                                        isLoading = false;
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Rejected Order"),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        setState(() {});
                                                      }).catchError((err) {
                                                        print(err.message);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Error"),
                                                                content: Text(
                                                                    err.message),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                course["photos"] != null
                                                    ? images(course["photos"])
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      } else {
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
                // }
              }));
    } else if (filter == 'Distance (Close To Far)') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .orderBy("time window")
                  .orderBy('distance')
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");

                                      if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);

                                      DocumentSnapshot course =
                                          snapshot.data.documents[index];
                                      Firestore.instance
                                          .collection("orders")
                                          .document(course.documentID)
                                          .collection("responses")
                                          .document(uid)
                                          .get()
                                          .then((doc) {
                                        if (!doc.exists) {
                                          orders.add(course.documentID);
                                          print('No such document! ' +
                                              course.documentID);
                                        } else {
                                          print("Document exists! " +
                                              course.documentID);
                                        }
                                      });

                                      // if (orders.contains(course.documentID)) {
                                      if (course["ratings"] != null) {
                                        if (checkDistance(
                                                course["latitude"],
                                                course["longitude"],
                                                course["distance"]) &&
                                            (ratingIsNull ||
                                                (rating >=
                                                    course["ratings"]))) {
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  title: Text("Title: " +
                                                      course["title"]),
                                                  subtitle: Text("Price: " +
                                                      course["price"]
                                                          .toString()),
                                                  leading: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "REMOVE from feed and move to confirmations sent page/tab.");
                                                      await _asyncSimpleDialog(
                                                          context,
                                                          course.documentID,
                                                          calculateDistance(
                                                              course[
                                                                  "latitude"],
                                                              course[
                                                                  "longitude"],
                                                              wsp_latitude,
                                                              wsp_longitude));
                                                    },
                                                    child: const Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.green,
                                                  ),
                                                  trailing: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "Remove from feed!");
                                                      Firestore.instance
                                                          .collection("orders")
                                                          .document(
                                                              course.documentID)
                                                          .collection(
                                                              "responses")
                                                          .document(uid)
                                                          .setData({
                                                        "wsp response":
                                                            "rejected"
                                                      });

                                                      Firestore.instance
                                                          .collection(
                                                              "rejected responses")
                                                          .add({
                                                        "wsp id": uid,
                                                        "order id":
                                                            course.documentID,
                                                      }).then((res) {
                                                        isLoading = false;
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Rejected Order"),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        setState(() {});
                                                      }).catchError((err) {
                                                        print(err.message);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Error"),
                                                                content: Text(
                                                                    err.message),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                course["photos"] != null
                                                    ? images(course["photos"])
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      } else {
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
                // }
              }));
    } else if (filter == 'Service Date And Time (Asc)') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .orderBy("time window")
                  .orderBy('service date and time')
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");

                                      if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);

                                      DocumentSnapshot course =
                                          snapshot.data.documents[index];
                                      Firestore.instance
                                          .collection("orders")
                                          .document(course.documentID)
                                          .collection("responses")
                                          .document(uid)
                                          .get()
                                          .then((doc) {
                                        if (!doc.exists) {
                                          orders.add(course.documentID);
                                          print('No such document! ' +
                                              course.documentID);
                                        } else {
                                          print("Document exists! " +
                                              course.documentID);
                                        }
                                      });

                                      // if (orders.contains(course.documentID)) {
                                      if (course["ratings"] != null) {
                                        if (checkDistance(
                                                course["latitude"],
                                                course["longitude"],
                                                course["distance"]) &&
                                            (ratingIsNull ||
                                                (rating >=
                                                    course["ratings"]))) {
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  title: Text("Title: " +
                                                      course["title"]),
                                                  subtitle: Text("Price: " +
                                                      course["price"]
                                                          .toString()),
                                                  leading: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "REMOVE from feed and move to confirmations sent page/tab.");
                                                      await _asyncSimpleDialog(
                                                          context,
                                                          course.documentID,
                                                          calculateDistance(
                                                              course[
                                                                  "latitude"],
                                                              course[
                                                                  "longitude"],
                                                              wsp_latitude,
                                                              wsp_longitude));
                                                    },
                                                    child: const Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.green,
                                                  ),
                                                  trailing: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "Remove from feed!");
                                                      Firestore.instance
                                                          .collection("orders")
                                                          .document(
                                                              course.documentID)
                                                          .collection(
                                                              "responses")
                                                          .document(uid)
                                                          .setData({
                                                        "wsp response":
                                                            "rejected"
                                                      });

                                                      Firestore.instance
                                                          .collection(
                                                              "rejected responses")
                                                          .add({
                                                        "wsp id": uid,
                                                        "order id":
                                                            course.documentID,
                                                      }).then((res) {
                                                        isLoading = false;
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Rejected Order"),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        setState(() {});
                                                      }).catchError((err) {
                                                        print(err.message);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Error"),
                                                                content: Text(
                                                                    err.message),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                course["photos"] != null
                                                    ? images(course["photos"])
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      } else {
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
                // }
              }));
    } else if (filter == 'Service Date And Time (Dsc)') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .orderBy("time window")
                  .orderBy('service date and time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");

                                      if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);

                                      DocumentSnapshot course =
                                          snapshot.data.documents[index];
                                      Firestore.instance
                                          .collection("orders")
                                          .document(course.documentID)
                                          .collection("responses")
                                          .document(uid)
                                          .get()
                                          .then((doc) {
                                        if (!doc.exists) {
                                          orders.add(course.documentID);
                                          print('No such document! ' +
                                              course.documentID);
                                        } else {
                                          print("Document exists! " +
                                              course.documentID);
                                        }
                                      });

                                      // if (orders.contains(course.documentID)) {
                                      if (course["ratings"] != null) {
                                        if (checkDistance(
                                                course["latitude"],
                                                course["longitude"],
                                                course["distance"]) &&
                                            (ratingIsNull ||
                                                (rating >=
                                                    course["ratings"]))) {
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  title: Text("Title: " +
                                                      course["title"]),
                                                  subtitle: Text("Price: " +
                                                      course["price"]
                                                          .toString()),
                                                  leading: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "REMOVE from feed and move to confirmations sent page/tab.");
                                                      await _asyncSimpleDialog(
                                                          context,
                                                          course.documentID,
                                                          calculateDistance(
                                                              course[
                                                                  "latitude"],
                                                              course[
                                                                  "longitude"],
                                                              wsp_latitude,
                                                              wsp_longitude));
                                                    },
                                                    child: const Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.green,
                                                  ),
                                                  trailing: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "Remove from feed!");
                                                      Firestore.instance
                                                          .collection("orders")
                                                          .document(
                                                              course.documentID)
                                                          .collection(
                                                              "responses")
                                                          .document(uid)
                                                          .setData({
                                                        "wsp response":
                                                            "rejected"
                                                      });

                                                      Firestore.instance
                                                          .collection(
                                                              "rejected responses")
                                                          .add({
                                                        "wsp id": uid,
                                                        "order id":
                                                            course.documentID,
                                                      }).then((res) {
                                                        isLoading = false;
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Rejected Order"),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        setState(() {});
                                                      }).catchError((err) {
                                                        print(err.message);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Error"),
                                                                content: Text(
                                                                    err.message),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                course["photos"] != null
                                                    ? images(course["photos"])
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      } else {
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
                // }
              }));
    } else if (filter == 'Time Window (Min to Max)') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .orderBy('time window')
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");

                                      if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);

                                      DocumentSnapshot course =
                                          snapshot.data.documents[index];
                                      Firestore.instance
                                          .collection("orders")
                                          .document(course.documentID)
                                          .collection("responses")
                                          .document(uid)
                                          .get()
                                          .then((doc) {
                                        if (!doc.exists) {
                                          orders.add(course.documentID);
                                          print('No such document! ' +
                                              course.documentID);
                                        } else {
                                          print("Document exists! " +
                                              course.documentID);
                                        }
                                      });

                                      // if (orders.contains(course.documentID)) {
                                      if (course["ratings"] != null) {
                                        if (checkDistance(
                                                course["latitude"],
                                                course["longitude"],
                                                course["distance"]) &&
                                            (ratingIsNull ||
                                                (rating >=
                                                    course["ratings"]))) {
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  title: Text("Title: " +
                                                      course["title"]),
                                                  subtitle: Text("Price: " +
                                                      course["price"]
                                                          .toString()),
                                                  leading: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "REMOVE from feed and move to confirmations sent page/tab.");
                                                      await _asyncSimpleDialog(
                                                          context,
                                                          course.documentID,
                                                          calculateDistance(
                                                              course[
                                                                  "latitude"],
                                                              course[
                                                                  "longitude"],
                                                              wsp_latitude,
                                                              wsp_longitude));
                                                    },
                                                    child: const Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.green,
                                                  ),
                                                  trailing: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "Remove from feed!");
                                                      Firestore.instance
                                                          .collection("orders")
                                                          .document(
                                                              course.documentID)
                                                          .collection(
                                                              "responses")
                                                          .document(uid)
                                                          .setData({
                                                        "wsp response":
                                                            "rejected"
                                                      });

                                                      Firestore.instance
                                                          .collection(
                                                              "rejected responses")
                                                          .add({
                                                        "wsp id": uid,
                                                        "order id":
                                                            course.documentID,
                                                      }).then((res) {
                                                        isLoading = false;
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Rejected Order"),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        setState(() {});
                                                      }).catchError((err) {
                                                        print(err.message);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Error"),
                                                                content: Text(
                                                                    err.message),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                course["photos"] != null
                                                    ? images(course["photos"])
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      } else {
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
                // }
              }));
    } else if (filter == 'Time Window (Max to Min') {
      return Scaffold(
          appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("service type", isEqualTo: role)
                  .where("status", isEqualTo: "New")
                  .where('time window', isGreaterThan: DateTime.now())
                  .orderBy('time window', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                initRating();
                orders.clear();
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
                                    return new CircularProgressIndicator();
                                  default:
                                    {
                                      if (!snapshot.hasData)
                                        return Text("Loading orders...");

                                      if (snapshot.data.documents[index]
                                              ["user id"] ==
                                          uid)
                                        return Container(
                                            width: 0.0, height: 0.0);

                                      DocumentSnapshot course =
                                          snapshot.data.documents[index];
                                      Firestore.instance
                                          .collection("orders")
                                          .document(course.documentID)
                                          .collection("responses")
                                          .document(uid)
                                          .get()
                                          .then((doc) {
                                        if (!doc.exists) {
                                          orders.add(course.documentID);
                                          print('No such document! ' +
                                              course.documentID);
                                        } else {
                                          print("Document exists! " +
                                              course.documentID);
                                        }
                                      });

                                      // if (orders.contains(course.documentID)) {
                                      if (course["ratings"] != null) {
                                        if (checkDistance(
                                                course["latitude"],
                                                course["longitude"],
                                                course["distance"]) &&
                                            (ratingIsNull ||
                                                (rating >=
                                                    course["ratings"]))) {
                                          return Card(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ListTile(
                                                  title: Text("Title: " +
                                                      course["title"]),
                                                  subtitle: Text("Price: " +
                                                      course["price"]
                                                          .toString()),
                                                  leading: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "REMOVE from feed and move to confirmations sent page/tab.");
                                                      await _asyncSimpleDialog(
                                                          context,
                                                          course.documentID,
                                                          calculateDistance(
                                                              course[
                                                                  "latitude"],
                                                              course[
                                                                  "longitude"],
                                                              wsp_latitude,
                                                              wsp_longitude));
                                                    },
                                                    child: const Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.green,
                                                  ),
                                                  trailing: RaisedButton(
                                                    onPressed: () async {
                                                      print(
                                                          "Remove from feed!");
                                                      Firestore.instance
                                                          .collection("orders")
                                                          .document(
                                                              course.documentID)
                                                          .collection(
                                                              "responses")
                                                          .document(uid)
                                                          .setData({
                                                        "wsp response":
                                                            "rejected"
                                                      });

                                                      Firestore.instance
                                                          .collection(
                                                              "rejected responses")
                                                          .add({
                                                        "wsp id": uid,
                                                        "order id":
                                                            course.documentID,
                                                      }).then((res) {
                                                        isLoading = false;
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                content: Text(
                                                                    "Rejected Order"),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });

                                                        setState(() {});
                                                      }).catchError((err) {
                                                        print(err.message);
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Error"),
                                                                content: Text(
                                                                    err.message),
                                                                actions: [
                                                                  FlatButton(
                                                                    child: Text(
                                                                        "Ok"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      });
                                                    },
                                                    child: const Text(
                                                      "Reject",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                course["photos"] != null
                                                    ? images(course["photos"])
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container(
                                              width: 0.0, height: 0.0);
                                        }
                                      } else {
                                        return Container(
                                            width: 0.0, height: 0.0);
                                      }
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    }
  }

  Future _asyncSimpleDialog(
      BuildContext context, String orderId, double distance) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Send Details '),
            children: <Widget>[
              SimpleDialogOption(
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: "Price*",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter a Price you can provide service for';
                            } else if (value.contains('-')) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: "Enter Description (if any)",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : RaisedButton(
                                color: Colors.lightBlueAccent,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    sendMessage(orderId, distance);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('Send'),
                              ),
                      )
                    ]))),
              ),
            ],
          );
        });
  }

  void sendMessage(String orderId, double distance) {
    Firestore.instance
        .collection("orders")
        .document(orderId)
        .collection("responses")
        .document(uid)
        .setData({
      "price": double.parse(priceController.text),
      "description": descriptionController.text,
      "role": role,
      "customer response": "None",
      "wsp response": "accepted",
      "ratings": rating,
      "distance": distance
    });

    Firestore.instance.collection("accepted responses").add({
      "wsp id": uid,
      "price": double.parse(priceController.text),
      "description": descriptionController.text,
      "order id": orderId,
      "role": role,
      "customer response": "None",
      "ratings": rating,
      "date time": DateTime.now(),
      "distance": distance
    }).then((res) {
      isLoading = false;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Sent Response"),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      setState(() {});
    }).catchError((err) {
      print(err.message);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }

  _onDropDownChanged(String value) {
    setState(() {
      this.filter = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }
}
