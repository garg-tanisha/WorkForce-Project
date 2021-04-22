import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/wsp_orders/wsp_completed_order_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WSPCompletedOrders extends StatefulWidget {
  WSPCompletedOrders({this.uid, this.role});
  final String uid;
  final String role;
  @override
  State<StatefulWidget> createState() => WSPCompletedOrdersState(uid, role);
}

class WSPCompletedOrdersState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String uid;
  String role;
  final filters = [
    'No Filter',
    'Price (Low To High)',
    'Price (High To Low)',
    "Order Completion Time (Asc)",
    "Order Completion Time (Dsc)"
  ];
  String filter = 'No Filter';

  WSPCompletedOrdersState(String uid, String role) {
    this.uid = uid;
    this.role = role;
  }

  _onDropDownChanged(String value) {
    setState(() {
      this.filter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (filter == 'No Filter') {
      return Scaffold(
          appBar: AppBar(title: Text("Orders Completed" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("wsp id", isEqualTo: uid)
                  .where("status", isEqualTo: "Completed")
                  .where("service type", isEqualTo: role)
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
                                              title: Text("Order Id: " +
                                                  course["order id"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n Distance: " +
                                                  course["distance"]
                                                      .toString()),
                                              trailing: RaisedButton(
                                                  onPressed: () async {
                                                    Navigator.push(
                                                        context,
                                                        //builder of MaterialPageRoute will call TodoDetail class
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              WSPCompletedOrderDetails(
                                                                  wspId: uid,
                                                                  orderId: course[
                                                                      "order id"]),
                                                        ));
                                                  },
                                                  child: const Text(
                                                    "See Details",
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  color:
                                                      Colors.lightBlueAccent),
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
                  return Text("No orders completed yet!");
                }
              }));
    } else if (filter == 'Price (Low To High)') {
      return Scaffold(
          appBar: AppBar(title: Text("Orders Completed" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("wsp id", isEqualTo: uid)
                  .where("status", isEqualTo: "Completed")
                  .where("service type", isEqualTo: role)
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
                                              title: Text("Order Id: " +
                                                  course["order id"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n Distance: " +
                                                  course["distance"]
                                                      .toString()),
                                              trailing: RaisedButton(
                                                  onPressed: () async {
                                                    Navigator.push(
                                                        context,
                                                        //builder of MaterialPageRoute will call TodoDetail class
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              WSPCompletedOrderDetails(
                                                                  wspId: uid,
                                                                  orderId: course[
                                                                      "order id"]),
                                                        ));
                                                  },
                                                  child: const Text(
                                                    "See Details",
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  color:
                                                      Colors.lightBlueAccent),
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
                  return Text("No orders completed yet!");
                }
              }));
    } else if (filter == 'Price (High To Low)') {
      return Scaffold(
          appBar: AppBar(title: Text("Orders Completed" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("wsp id", isEqualTo: uid)
                  .where("status", isEqualTo: "Completed")
                  .where("service type", isEqualTo: role)
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
                                              title: Text("Order Id: " +
                                                  course["order id"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n Distance: " +
                                                  course["distance"]
                                                      .toString()),
                                              trailing: RaisedButton(
                                                  onPressed: () async {
                                                    Navigator.push(
                                                        context,
                                                        //builder of MaterialPageRoute will call TodoDetail class
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              WSPCompletedOrderDetails(
                                                                  wspId: uid,
                                                                  orderId: course[
                                                                      "order id"]),
                                                        ));
                                                  },
                                                  child: const Text(
                                                    "See Details",
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  color:
                                                      Colors.lightBlueAccent),
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
                  return Text("No orders completed yet!");
                }
              }));
    } else if (filter == "Order Completion Time (Asc)") {
      return Scaffold(
          appBar: AppBar(title: Text("Orders Completed" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("wsp id", isEqualTo: uid)
                  .where("status", isEqualTo: "Completed")
                  .where("service type", isEqualTo: role)
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
                                      return Card(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            ListTile(
                                              title: Text("Order Id: " +
                                                  course["order id"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n Distance: " +
                                                  course["distance"]
                                                      .toString()),
                                              trailing: RaisedButton(
                                                  onPressed: () async {
                                                    Navigator.push(
                                                        context,
                                                        //builder of MaterialPageRoute will call TodoDetail class
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              WSPCompletedOrderDetails(
                                                                  wspId: uid,
                                                                  orderId: course[
                                                                      "order id"]),
                                                        ));
                                                  },
                                                  child: const Text(
                                                    "See Details",
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  color:
                                                      Colors.lightBlueAccent),
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
                  return Text("No orders completed yet!");
                }
              }));
    } else if (filter == "Order Completion Time (Dsc)") {
      return Scaffold(
          appBar: AppBar(title: Text("Orders Completed" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("wsp id", isEqualTo: uid)
                  .where("status", isEqualTo: "Completed")
                  .where("service type", isEqualTo: role)
                  .orderBy("order completion time", descending: true)
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
                                              title: Text("Order Id: " +
                                                  course["order id"]),
                                              subtitle: Text("Price: " +
                                                  course["price"].toString() +
                                                  "\n Distance: " +
                                                  course["distance"]
                                                      .toString()),
                                              trailing: RaisedButton(
                                                  onPressed: () async {
                                                    Navigator.push(
                                                        context,
                                                        //builder of MaterialPageRoute will call TodoDetail class
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              WSPCompletedOrderDetails(
                                                                  wspId: uid,
                                                                  orderId: course[
                                                                      "order id"]),
                                                        ));
                                                  },
                                                  child: const Text(
                                                    "See Details",
                                                    style: TextStyle(
                                                        fontSize: 15.0),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  color:
                                                      Colors.lightBlueAccent),
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
                  return Text("No orders completed yet!");
                }
              }));
    }
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
