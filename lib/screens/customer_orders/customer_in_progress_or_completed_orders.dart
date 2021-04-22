import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'customer_completed_order_details.dart';
import 'customer_in_progress_order_details.dart';
// import 'package:synchronized/synchronized.dart';

class CustomerInProgressOrCompletedOrders extends StatefulWidget {
  CustomerInProgressOrCompletedOrders({this.uid, this.status});
  final String uid;
  final String status;
  @override
  State<StatefulWidget> createState() =>
      CustomerInProgressOrCompletedOrdersState(uid, status);
}

class CustomerInProgressOrCompletedOrdersState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String uid;
  String status;
  _onDropDownChanged(String value) {
    setState(() {
      this.filter = value;
    });
  }

  final filters = [
    'No Filter',
    'Price (Min To Max)',
    'Price (Max To Min)',
    "Order Completion Time (Asc)",
    "Order Completion Time(Dsc)"
  ];

  String filter = 'No Filter';
  // final _lock = new Lock();
  CustomerInProgressOrCompletedOrdersState(String uid, String status) {
    this.uid = uid;
    this.status = status;
  }

  // Future<DocumentSnapshot> myMethod(DocumentSnapshot course) async {
  //   await _lock.synchronized(() async {
  //     Firestore.instance
  //         .collection("orders")
  //         .document(course["order id"])
  //         .get()
  //         .then((doc) {
  //       return doc;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (filter == 'No Filter') {
      return Scaffold(
          appBar: AppBar(title: Text("Orders (" + status + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: status)
                  // .orderBy("order id")
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
                                      // var orderDoc = myMethod(
                                      //     course); // var lock = new Lock(reentrant: true);
                                      // DocumentSnapshot doc;
                                      // orderDoc.then((value) => doc = value);
                                      // DocumentSnapshot orderDoc;
                                      // myMethod(course).then((value) {
                                      //   print(value);
                                      //   orderDoc = value;
                                      // });

                                      return Card(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text("Order id: " +
                                                course["order id"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("WSP id: " + course["wsp id"]),
                                            Text("Distance: " +
                                                course["distance"]
                                                    .toString()), // orderDoc != null ? Text("Hi") : Container(),
                                            RaisedButton(
                                              onPressed: () async {
                                                if (status == "In Progress") {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CustomerInProgressOrderDetails(
                                                          uid: uid,
                                                          wspId:
                                                              course["wsp id"],
                                                          orderId: course[
                                                              "order id"],
                                                        ),
                                                      ));
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerCompletedOrderDetails(
                                                                uid: uid,
                                                                wspId: course[
                                                                    "wsp id"],
                                                                orderId: course[
                                                                    "order id"],
                                                              )));
                                                }
                                              },
                                              child: const Text(
                                                "See Details",
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              color: Colors.lightBlueAccent,
                                            ),
                                          ],
                                        ),
                                      );
                                      // });
                                      // });
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Price (Min To Max)') {
      return Scaffold(
          appBar: AppBar(title: Text("Orders (" + status + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: status)
                  .orderBy("price")
                  // .orderBy("order id")
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
                                      // var orderDoc = myMethod(
                                      //     course); // var lock = new Lock(reentrant: true);
                                      // DocumentSnapshot doc;
                                      // orderDoc.then((value) => doc = value);
                                      // DocumentSnapshot orderDoc;
                                      // myMethod(course).then((value) {
                                      //   print(value);
                                      //   orderDoc = value;
                                      // });

                                      return Card(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text("Order id: " +
                                                course["order id"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("WSP id: " + course["wsp id"]),
                                            Text("Distance: " +
                                                course["distance"]
                                                    .toString()), // orderDoc != null ? Text("Hi") : Container(),
                                            RaisedButton(
                                              onPressed: () async {
                                                if (status == "In Progress") {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CustomerInProgressOrderDetails(
                                                          uid: uid,
                                                          wspId:
                                                              course["wsp id"],
                                                          orderId: course[
                                                              "order id"],
                                                        ),
                                                      ));
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerCompletedOrderDetails(
                                                                uid: uid,
                                                                wspId: course[
                                                                    "wsp id"],
                                                                orderId: course[
                                                                    "order id"],
                                                              )));
                                                }
                                              },
                                              child: const Text(
                                                "See Details",
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              color: Colors.lightBlueAccent,
                                            ),
                                          ],
                                        ),
                                      );
                                      // });
                                      // });
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Price (Max To Min)') {
      return Scaffold(
          appBar: AppBar(title: Text("Orders (" + status + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: status)
                  .orderBy("price", descending: true)
                  // .orderBy("order id")
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
                                      // var orderDoc = myMethod(
                                      //     course); // var lock = new Lock(reentrant: true);
                                      // DocumentSnapshot doc;
                                      // orderDoc.then((value) => doc = value);
                                      // DocumentSnapshot orderDoc;
                                      // myMethod(course).then((value) {
                                      //   print(value);
                                      //   orderDoc = value;
                                      // });

                                      return Card(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text("Order id: " +
                                                course["order id"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("WSP id: " + course["wsp id"]),
                                            Text("Distance: " +
                                                course["distance"]
                                                    .toString()), // orderDoc != null ? Text("Hi") : Container(),
                                            RaisedButton(
                                              onPressed: () async {
                                                if (status == "In Progress") {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CustomerInProgressOrderDetails(
                                                          uid: uid,
                                                          wspId:
                                                              course["wsp id"],
                                                          orderId: course[
                                                              "order id"],
                                                        ),
                                                      ));
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerCompletedOrderDetails(
                                                                uid: uid,
                                                                wspId: course[
                                                                    "wsp id"],
                                                                orderId: course[
                                                                    "order id"],
                                                              )));
                                                }
                                              },
                                              child: const Text(
                                                "See Details",
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              color: Colors.lightBlueAccent,
                                            ),
                                          ],
                                        ),
                                      );
                                      // });
                                      // });
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (status != "In Progress") {
      if (filter == "Order Completion Time (Asc)") {
        return Scaffold(
            appBar: AppBar(title: Text("Orders (" + status + " )")),
            body: StreamBuilder(
                stream: Firestore.instance
                    .collection('placed orders')
                    .where("user id", isEqualTo: uid)
                    .where("status", isEqualTo: status)
                    .orderBy("order completion time")
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
                                        // var orderDoc = myMethod(
                                        //     course); // var lock = new Lock(reentrant: true);
                                        // DocumentSnapshot doc;
                                        // orderDoc.then((value) => doc = value);
                                        // DocumentSnapshot orderDoc;
                                        // myMethod(course).then((value) {
                                        //   print(value);
                                        //   orderDoc = value;
                                        // });

                                        return Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text("Order id: " +
                                                  course["order id"]),
                                              Text("Price: " +
                                                  course["price"].toString()),
                                              Text("WSP id: " +
                                                  course["wsp id"]),
                                              Text("Distance: " +
                                                  course["distance"]
                                                      .toString()), // orderDoc != null ? Text("Hi") : Container(),
                                              RaisedButton(
                                                onPressed: () async {
                                                  if (status == "In Progress") {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerInProgressOrderDetails(
                                                            uid: uid,
                                                            wspId: course[
                                                                "wsp id"],
                                                            orderId: course[
                                                                "order id"],
                                                          ),
                                                        ));
                                                  } else {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CustomerCompletedOrderDetails(
                                                                  uid: uid,
                                                                  wspId: course[
                                                                      "wsp id"],
                                                                  orderId: course[
                                                                      "order id"],
                                                                )));
                                                  }
                                                },
                                                child: const Text(
                                                  "See Details",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.lightBlueAccent,
                                              ),
                                            ],
                                          ),
                                        );
                                        // });
                                        // });
                                      }
                                  }
                                }
                              }))
                    ]);
                  } else {
                    return Text("No orders yet!");
                  }
                }));
      } else if (filter == "Order Completion Time(Dsc)") {
        return Scaffold(
            appBar: AppBar(title: Text("Orders (" + status + " )")),
            body: StreamBuilder(
                stream: Firestore.instance
                    .collection('placed orders')
                    .where("user id", isEqualTo: uid)
                    .where("status", isEqualTo: status)
                    .orderBy("order completion time", descending: true)
                    // .orderBy("order id")
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
                                        // var orderDoc = myMethod(
                                        //     course); // var lock = new Lock(reentrant: true);
                                        // DocumentSnapshot doc;
                                        // orderDoc.then((value) => doc = value);
                                        // DocumentSnapshot orderDoc;
                                        // myMethod(course).then((value) {
                                        //   print(value);
                                        //   orderDoc = value;
                                        // });

                                        return Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text("Order id: " +
                                                  course["order id"]),
                                              Text("Price: " +
                                                  course["price"].toString()),
                                              Text("WSP id: " +
                                                  course["wsp id"]),
                                              Text("Distance: " +
                                                  course["distance"]
                                                      .toString()), // orderDoc != null ? Text("Hi") : Container(),
                                              RaisedButton(
                                                onPressed: () async {
                                                  if (status == "In Progress") {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerInProgressOrderDetails(
                                                            uid: uid,
                                                            wspId: course[
                                                                "wsp id"],
                                                            orderId: course[
                                                                "order id"],
                                                          ),
                                                        ));
                                                  } else {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CustomerCompletedOrderDetails(
                                                                  uid: uid,
                                                                  wspId: course[
                                                                      "wsp id"],
                                                                  orderId: course[
                                                                      "order id"],
                                                                )));
                                                  }
                                                },
                                                child: const Text(
                                                  "See Details",
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                color: Colors.lightBlueAccent,
                                              ),
                                            ],
                                          ),
                                        );
                                        // });
                                        // });
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
    } else {
      return Scaffold(
          appBar: AppBar(title: Text("Orders (" + status + " )")),
          body: Column(children: [
            Center(child: Text("Choose Filter")),
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
            Text("Order are In Progress...")
          ]));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
