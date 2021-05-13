import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerCancelledOrders extends StatefulWidget {
  CustomerCancelledOrders({this.uid});
  final String uid;
  @override
  State<StatefulWidget> createState() => CustomerCancelledOrdersState(uid);
}

class CustomerCancelledOrdersState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String uid;
  final filters = [
    'No Filter',
    'Date (Order Posted, Asc)',
    'Date (Order Posted, Desc)',
    'Price (Low To High)',
    'Price (High To Low)',
    'Service date and time (Asc)',
    'Service date and time (Dsc)',
    'Time window (Min To Max)',
    'Time window (Max To Min)'
  ];
  String filter = 'No Filter';

  CustomerCancelledOrdersState(String uid) {
    this.uid = uid;
  }
  _onDropDownChanged(String value) {
    setState(() {
      this.filter = value;
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
    if (filter == 'No Filter') {
      return Scaffold(
          appBar: AppBar(title: Text("Cancelled Orders")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: "Cancelled")
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
                                            Text("Title: " + course["title"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("distance: " +
                                                course["distance"].toString()),
                                            //Text("Photos:"),
                                            course["photos"] != null
                                                ? images(course["photos"])
                                                : Container(),
                                            // Image.network(course["photos"][0],
                                            //     height: 150, width: 150),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     Navigator.pushReplacement(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OrderResponses(
                                            //                 uid: uid,
                                            //                 orderId: course
                                            //                     .documentID,
                                            //               )),
                                            //     );
                                            //   },
                                            //   child: const Text(
                                            //     "See Responses",
                                            //     style:
                                            //         TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               8.0)),
                                            //   color: Colors.lightBlueAccent,
                                            // ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Date (Order Posted, Asc)') {
      return Scaffold(
          appBar: AppBar(title: Text("Cancelled Orders")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: "Cancelled")
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
                                            Text("Title: " + course["title"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("distance: " +
                                                course["distance"].toString()),
                                            //Text("Photos:"),
                                            course["photos"] != null
                                                ? images(course["photos"])
                                                : Container(),
                                            // Image.network(course["photos"][0],
                                            //     height: 150, width: 150),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     Navigator.pushReplacement(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OrderResponses(
                                            //                 uid: uid,
                                            //                 orderId: course
                                            //                     .documentID,
                                            //               )),
                                            //     );
                                            //   },
                                            //   child: const Text(
                                            //     "See Responses",
                                            //     style:
                                            //         TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               8.0)),
                                            //   color: Colors.lightBlueAccent,
                                            // ),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     print("REMOVE FROM ALL TABLES");
                                            //   },
                                            //   child: const Text(
                                            //     "Cancel Order",
                                            //     style: TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(8.0)),
                                            //   color: Colors.red,
                                            // ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Date (Order Posted, Desc)') {
      return Scaffold(
          appBar: AppBar(title: Text("Cancelled Orders")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: "Cancelled")
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
                                            Text("Title: " + course["title"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("distance: " +
                                                course["distance"].toString()),
                                            //Text("Photos:"),
                                            course["photos"] != null
                                                ? images(course["photos"])
                                                : Container(),
                                            // Image.network(course["photos"][0],
                                            //     height: 150, width: 150),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     Navigator.pushReplacement(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OrderResponses(
                                            //                 uid: uid,
                                            //                 orderId: course
                                            //                     .documentID,
                                            //               )),
                                            //     );
                                            //   },
                                            //   child: const Text(
                                            //     "See Responses",
                                            //     style:
                                            //         TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               8.0)),
                                            //   color: Colors.lightBlueAccent,
                                            // ),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     print("REMOVE FROM ALL TABLES");
                                            //   },
                                            //   child: const Text(
                                            //     "Cancel Order",
                                            //     style: TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(8.0)),
                                            //   color: Colors.red,
                                            // ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Price (Low To High)') {
      return Scaffold(
          appBar: AppBar(title: Text("Cancelled Orders")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: "Cancelled")
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
                                            Text("Title: " + course["title"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("distance: " +
                                                course["distance"].toString()),
                                            //Text("Photos:"),
                                            course["photos"] != null
                                                ? images(course["photos"])
                                                : Container(),
                                            // Image.network(course["photos"][0],
                                            //     height: 150, width: 150),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     Navigator.pushReplacement(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OrderResponses(
                                            //                 uid: uid,
                                            //                 orderId: course
                                            //                     .documentID,
                                            //               )),
                                            //     );
                                            //   },
                                            //   child: const Text(
                                            //     "See Responses",
                                            //     style:
                                            //         TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               8.0)),
                                            //   color: Colors.lightBlueAccent,
                                            // ),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     print("REMOVE FROM ALL TABLES");
                                            //   },
                                            //   child: const Text(
                                            //     "Cancel Order",
                                            //     style: TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(8.0)),
                                            //   color: Colors.red,
                                            // ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Price (High To Low)') {
      return Scaffold(
          appBar: AppBar(title: Text("Cancelled Orders")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: "Cancelled")
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
                                            Text("Title: " + course["title"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("distance: " +
                                                course["distance"].toString()),
                                            //Text("Photos:"),
                                            course["photos"] != null
                                                ? images(course["photos"])
                                                : Container(),
                                            // Image.network(course["photos"][0],
                                            //     height: 150, width: 150),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     Navigator.pushReplacement(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OrderResponses(
                                            //                 uid: uid,
                                            //                 orderId: course
                                            //                     .documentID,
                                            //               )),
                                            //     );
                                            //   },
                                            //   child: const Text(
                                            //     "See Responses",
                                            //     style:
                                            //         TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               8.0)),
                                            //   color: Colors.lightBlueAccent,
                                            // ),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     print("REMOVE FROM ALL TABLES");
                                            //   },
                                            //   child: const Text(
                                            //     "Cancel Order",
                                            //     style: TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(8.0)),
                                            //   color: Colors.red,
                                            // ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Service date and time (Asc)') {
      return Scaffold(
          appBar: AppBar(title: Text("Cancelled Orders")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: "Cancelled")
                  .orderBy("service date and time")
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
                                            Text("Title: " + course["title"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("distance: " +
                                                course["distance"].toString()),
                                            //Text("Photos:"),
                                            course["photos"] != null
                                                ? images(course["photos"])
                                                : Container(),
                                            // Image.network(course["photos"][0],
                                            //     height: 150, width: 150),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     Navigator.pushReplacement(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OrderResponses(
                                            //                 uid: uid,
                                            //                 orderId: course
                                            //                     .documentID,
                                            //               )),
                                            //     );
                                            //   },
                                            //   child: const Text(
                                            //     "See Responses",
                                            //     style:
                                            //         TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               8.0)),
                                            //   color: Colors.lightBlueAccent,
                                            // ),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     print("REMOVE FROM ALL TABLES");
                                            //   },
                                            //   child: const Text(
                                            //     "Cancel Order",
                                            //     style: TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(8.0)),
                                            //   color: Colors.red,
                                            // ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Service date and time (Dsc)') {
      return Scaffold(
          appBar: AppBar(title: Text("Cancelled Orders")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: "Cancelled")
                  .orderBy("service date and time", descending: true)
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
                                            Text("Title: " + course["title"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("distance: " +
                                                course["distance"].toString()),
                                            //Text("Photos:"),
                                            course["photos"] != null
                                                ? images(course["photos"])
                                                : Container(),
                                            // Image.network(course["photos"][0],
                                            //     height: 150, width: 150),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     Navigator.pushReplacement(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OrderResponses(
                                            //                 uid: uid,
                                            //                 orderId: course
                                            //                     .documentID,
                                            //               )),
                                            //     );
                                            //   },
                                            //   child: const Text(
                                            //     "See Responses",
                                            //     style:
                                            //         TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               8.0)),
                                            //   color: Colors.lightBlueAccent,
                                            // ),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     print("REMOVE FROM ALL TABLES");
                                            //   },
                                            //   child: const Text(
                                            //     "Cancel Order",
                                            //     style: TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(8.0)),
                                            //   color: Colors.red,
                                            // ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Time window (Min To Max)') {
      return Scaffold(
          appBar: AppBar(title: Text("Cancelled Orders")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: "Cancelled")
                  .orderBy("time window")
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
                                            Text("Title: " + course["title"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("distance: " +
                                                course["distance"].toString()),
                                            //Text("Photos:"),
                                            course["photos"] != null
                                                ? images(course["photos"])
                                                : Container(),
                                            // Image.network(course["photos"][0],
                                            //     height: 150, width: 150),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     Navigator.pushReplacement(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OrderResponses(
                                            //                 uid: uid,
                                            //                 orderId: course
                                            //                     .documentID,
                                            //               )),
                                            //     );
                                            //   },
                                            //   child: const Text(
                                            //     "See Responses",
                                            //     style:
                                            //         TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               8.0)),
                                            //   color: Colors.lightBlueAccent,
                                            // ),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     print("REMOVE FROM ALL TABLES");
                                            //   },
                                            //   child: const Text(
                                            //     "Cancel Order",
                                            //     style: TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(8.0)),
                                            //   color: Colors.red,
                                            // ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            }))
                  ]);
                } else {
                  return Text("No orders yet!");
                }
              }));
    } else if (filter == 'Time window (Max To Min)') {
      return Scaffold(
          appBar: AppBar(title: Text("Cancelled Orders")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('orders')
                  .where("user id", isEqualTo: uid)
                  .where("status", isEqualTo: "Cancelled")
                  .orderBy("time window", descending: true)
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
                                            Text("Title: " + course["title"]),
                                            Text("Price: " +
                                                course["price"].toString()),
                                            Text("distance: " +
                                                course["distance"].toString()),
                                            //Text("Photos:"),
                                            course["photos"] != null
                                                ? images(course["photos"])
                                                : Container(),
                                            // Image.network(course["photos"][0],
                                            //     height: 150, width: 150),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     Navigator.pushReplacement(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               OrderResponses(
                                            //                 uid: uid,
                                            //                 orderId: course
                                            //                     .documentID,
                                            //               )),
                                            //     );
                                            //   },
                                            //   child: const Text(
                                            //     "See Responses",
                                            //     style:
                                            //         TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               8.0)),
                                            //   color: Colors.lightBlueAccent,
                                            // ),
                                            // RaisedButton(
                                            //   onPressed: () async {
                                            //     print("REMOVE FROM ALL TABLES");
                                            //   },
                                            //   child: const Text(
                                            //     "Cancel Order",
                                            //     style: TextStyle(fontSize: 15.0),
                                            //   ),
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(8.0)),
                                            //   color: Colors.red,
                                            // ),
                                          ],
                                        ),
                                      );
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

  @override
  void dispose() {
    super.dispose();
  }
}
