import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderConfirmationsSent extends StatefulWidget {
  OrderConfirmationsSent({this.uid, this.role});
  final String uid;
  final String role;
  @override
  State<StatefulWidget> createState() => OrderConfirmationsSentState(uid, role);
}

class OrderConfirmationsSentState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String uid;
  String role;

  final filters = [
    'No filter',
    'Price (Low To High)',
    'Price (High To Low)',
    'Reponse (First Come First Serve)',
    'Response (Last Come First Serve)'
  ];
  String filter = 'No filter';
  OrderConfirmationsSentState(String uid, String role) {
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
    if (filter == 'No filter') {
      return Scaffold(
        appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('accepted responses')
                .where("wsp id", isEqualTo: uid)
                .where("role", isEqualTo: role)
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
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
                                                course["price"].toString()),
                                            leading: RaisedButton(
                                              onPressed: () async {
                                                if (course[
                                                        "customer response"] ==
                                                    "None") {
                                                  showCustomerResponse(
                                                      "No response yet.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "accepted") {
                                                  showCustomerResponse(
                                                      "Customer accepted your request and the order is in progress now.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "cancelled") {
                                                  showCustomerResponse(
                                                      "Customer cancelled the order.");
                                                } else {
                                                  showCustomerResponse(
                                                      "Customer rejected your request.");
                                                }
                                              },
                                              child: Text(
                                                course["customer response"],
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              color: Colors.lightBlueAccent,
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
                return Text("No accepted resposes yet!");
              }
            }),
      );
    } else if (filter == 'Price (Low To High)') {
      return Scaffold(
        appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('accepted responses')
                .where("wsp id", isEqualTo: uid)
                .where("role", isEqualTo: role)
                .orderBy("price")
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
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
                                                course["price"].toString()),
                                            leading: RaisedButton(
                                              onPressed: () async {
                                                if (course[
                                                        "customer response"] ==
                                                    "None") {
                                                  showCustomerResponse(
                                                      "No response yet.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "accepted") {
                                                  showCustomerResponse(
                                                      "Customer accepted your request and the order is in progress now.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "cancelled") {
                                                  showCustomerResponse(
                                                      "Customer cancelled the order.");
                                                } else {
                                                  showCustomerResponse(
                                                      "Customer rejected your request.");
                                                }
                                              },
                                              child: Text(
                                                course["customer response"],
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              color: Colors.lightBlueAccent,
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
                return Text("No accepted resposes yet!");
              }
            }),
      );
    } else if (filter == 'Price (High To Low)') {
      return Scaffold(
        appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('accepted responses')
                .where("wsp id", isEqualTo: uid)
                .where("role", isEqualTo: role)
                .orderBy("price", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
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
                                                course["price"].toString()),
                                            leading: RaisedButton(
                                              onPressed: () async {
                                                if (course[
                                                        "customer response"] ==
                                                    "None") {
                                                  showCustomerResponse(
                                                      "No response yet.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "accepted") {
                                                  showCustomerResponse(
                                                      "Customer accepted your request and the order is in progress now.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "cancelled") {
                                                  showCustomerResponse(
                                                      "Customer cancelled the order.");
                                                } else {
                                                  showCustomerResponse(
                                                      "Customer rejected your request.");
                                                }
                                              },
                                              child: Text(
                                                course["customer response"],
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              color: Colors.lightBlueAccent,
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
                return Text("No accepted resposes yet!");
              }
            }),
      );
    } else if (filter == 'Reponse (First Come First Serve)') {
      return Scaffold(
        appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('accepted responses')
                .where("wsp id", isEqualTo: uid)
                .where("role", isEqualTo: role)
                .orderBy("date time")
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
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
                                                course["price"].toString()),
                                            leading: RaisedButton(
                                              onPressed: () async {
                                                if (course[
                                                        "customer response"] ==
                                                    "None") {
                                                  showCustomerResponse(
                                                      "No response yet.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "accepted") {
                                                  showCustomerResponse(
                                                      "Customer accepted your request and the order is in progress now.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "cancelled") {
                                                  showCustomerResponse(
                                                      "Customer cancelled the order.");
                                                } else {
                                                  showCustomerResponse(
                                                      "Customer rejected your request.");
                                                }
                                              },
                                              child: Text(
                                                course["customer response"],
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              color: Colors.lightBlueAccent,
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
                return Text("No accepted resposes yet!");
              }
            }),
      );
    } else if (filter == 'Response (Last Come First Serve)') {
      return Scaffold(
        appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('accepted responses')
                .where("wsp id", isEqualTo: uid)
                .where("role", isEqualTo: role)
                .orderBy("date time", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
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
                                                course["price"].toString()),
                                            leading: RaisedButton(
                                              onPressed: () async {
                                                if (course[
                                                        "customer response"] ==
                                                    "None") {
                                                  showCustomerResponse(
                                                      "No response yet.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "accepted") {
                                                  showCustomerResponse(
                                                      "Customer accepted your request and the order is in progress now.");
                                                } else if (course[
                                                        "customer response"] ==
                                                    "cancelled") {
                                                  showCustomerResponse(
                                                      "Customer cancelled the order.");
                                                } else {
                                                  showCustomerResponse(
                                                      "Customer rejected your request.");
                                                }
                                              },
                                              child: Text(
                                                course["customer response"],
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              color: Colors.lightBlueAccent,
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
                return Text("No accepted resposes yet!");
              }
            }),
      );
    }
  }

  void showCustomerResponse(String response) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Response"),
            content: Text(response),
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
  }

  @override
  void dispose() {
    super.dispose();
  }
}
