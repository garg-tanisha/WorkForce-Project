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
  DocumentSnapshot orderDetails;
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

  DocumentSnapshot orderDetailsFunction(String orderId) {
    Firestore.instance.collection('orders').document(orderId).get().then((doc) {
      if (!doc.exists) {
        print("doc not found " + orderId);
      } else {
        print("found the doc " + orderId);
      }
      // setState(() {});
      return doc;
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
                  Container(
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
                          child: Text("Filter",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
                            child: Card(
                              child: DropdownButton<String>(
                                //create an array of strings
                                items: filters.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0,
                                          bottom: 0.0,
                                          left: 10.0,
                                          right: 0.0),
                                      child: Text(value,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black)),
                                    ),
                                  );
                                }).toList(),
                                value: filter,
                                onChanged: (String value) {
                                  _onDropDownChanged(value);
                                },
                              ),
                            ))
                      ]),
                    ),
                  ),
                  //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                  Expanded(
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

                                    {
                                      return Container(
                                          width: 0.98 *
                                              MediaQuery.of(context)
                                                  .size
                                                  .width
                                                  .roundToDouble(),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //                 <--- border radius here
                                                ),
                                          ),
                                          // child: Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              course["title"] != null
                                                  ? ListTile(
                                                      trailing: Image.network(
                                                        course["photos"][1],
                                                      ),
                                                      leading: Image.network(
                                                        course["photos"][0],
                                                      ),
                                                      title: Text("Title: " +
                                                          course["title"]),
                                                      subtitle: Text(
                                                          "Price (Customer): " +
                                                              course["price_by_customer"]
                                                                  .toString() +
                                                              "\nPrice (SP): " +
                                                              course["price"]
                                                                  .toString() +
                                                              "\nDistance: " +
                                                              course["distance"]
                                                                  .toStringAsFixed(
                                                                      4)
                                                                  .toString() +
                                                              " km"),
                                                    )
                                                  : ListTile(
                                                      title: Text("Order Id: " +
                                                          course["order id"]),
                                                      subtitle: Text(
                                                        "Price: " +
                                                            course["price"]
                                                                .toString() +
                                                            "\nDistance: " +
                                                            course["distance"]
                                                                .toStringAsFixed(
                                                                    4)
                                                                .toString() +
                                                            " km",
                                                      ),
                                                    ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Center(
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                      Text("Customer Reponse: ",
                                                          style: TextStyle(
                                                              fontSize: 14.0)),
                                                      RaisedButton(
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
                                                          course[
                                                              "customer response"],
                                                          style: TextStyle(
                                                              fontSize: 15.0),
                                                        ),
                                                        color: Colors
                                                            .lightBlueAccent,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0),
                                                            side: BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                                width: 2)),
                                                      ),
                                                    ])),
                                              )
                                            ],
                                          ));
                                    }
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
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
                          child: Text("Filter",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
                            child: Card(
                              child: DropdownButton<String>(
                                //create an array of strings
                                items: filters.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0,
                                          bottom: 0.0,
                                          left: 10.0,
                                          right: 0.0),
                                      child: Text(value,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black)),
                                    ),
                                  );
                                }).toList(),
                                value: filter,
                                onChanged: (String value) {
                                  _onDropDownChanged(value);
                                },
                              ),
                            ))
                      ]),
                    ),
                  ),
                  //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                  Expanded(
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

                                    {
                                      return Container(
                                          width: 0.98 *
                                              MediaQuery.of(context)
                                                  .size
                                                  .width
                                                  .roundToDouble(),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //                 <--- border radius here
                                                ),
                                          ),
                                          // child: Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              course["title"] != null
                                                  ? ListTile(
                                                      trailing: Image.network(
                                                        course["photos"][1],
                                                      ),
                                                      leading: Image.network(
                                                        course["photos"][0],
                                                      ),
                                                      title: Text("Title: " +
                                                          course["title"]),
                                                      subtitle: Text(
                                                          "Price (Customer): " +
                                                              course["price_by_customer"]
                                                                  .toString() +
                                                              "\nPrice (SP): " +
                                                              course["price"]
                                                                  .toString() +
                                                              "\nDistance: " +
                                                              course["distance"]
                                                                  .toStringAsFixed(
                                                                      4)
                                                                  .toString() +
                                                              " km"),
                                                    )
                                                  : ListTile(
                                                      title: Text("Order Id: " +
                                                          course["order id"]),
                                                      subtitle: Text(
                                                        "Price: " +
                                                            course["price"]
                                                                .toString() +
                                                            "\nDistance: " +
                                                            course["distance"]
                                                                .toStringAsFixed(
                                                                    4)
                                                                .toString() +
                                                            " km",
                                                      ),
                                                    ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Center(
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                      Text("Customer Reponse: ",
                                                          style: TextStyle(
                                                              fontSize: 14.0)),
                                                      RaisedButton(
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
                                                          course[
                                                              "customer response"],
                                                          style: TextStyle(
                                                              fontSize: 15.0),
                                                        ),
                                                        color: Colors
                                                            .lightBlueAccent,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0),
                                                            side: BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                                width: 2)),
                                                      ),
                                                    ])),
                                              )
                                            ],
                                          ));
                                    }
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
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
                          child: Text("Filter",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
                            child: Card(
                              child: DropdownButton<String>(
                                //create an array of strings
                                items: filters.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0,
                                          bottom: 0.0,
                                          left: 10.0,
                                          right: 0.0),
                                      child: Text(value,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black)),
                                    ),
                                  );
                                }).toList(),
                                value: filter,
                                onChanged: (String value) {
                                  _onDropDownChanged(value);
                                },
                              ),
                            ))
                      ]),
                    ),
                  ),
                  //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                  Expanded(
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

                                    {
                                      return Container(
                                          width: 0.98 *
                                              MediaQuery.of(context)
                                                  .size
                                                  .width
                                                  .roundToDouble(),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //                 <--- border radius here
                                                ),
                                          ),
                                          // child: Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              course["title"] != null
                                                  ? ListTile(
                                                      trailing: Image.network(
                                                        course["photos"][1],
                                                      ),
                                                      leading: Image.network(
                                                        course["photos"][0],
                                                      ),
                                                      title: Text("Title: " +
                                                          course["title"]),
                                                      subtitle: Text(
                                                          "Price (Customer): " +
                                                              course["price_by_customer"]
                                                                  .toString() +
                                                              "\nPrice (SP): " +
                                                              course["price"]
                                                                  .toString() +
                                                              "\nDistance: " +
                                                              course["distance"]
                                                                  .toStringAsFixed(
                                                                      4)
                                                                  .toString() +
                                                              " km"),
                                                    )
                                                  : ListTile(
                                                      title: Text("Order Id: " +
                                                          course["order id"]),
                                                      subtitle: Text(
                                                        "Price: " +
                                                            course["price"]
                                                                .toString() +
                                                            "\nDistance: " +
                                                            course["distance"]
                                                                .toStringAsFixed(
                                                                    4)
                                                                .toString() +
                                                            " km",
                                                      ),
                                                    ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Center(
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                      Text("Customer Reponse: ",
                                                          style: TextStyle(
                                                              fontSize: 14.0)),
                                                      RaisedButton(
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
                                                          course[
                                                              "customer response"],
                                                          style: TextStyle(
                                                              fontSize: 15.0),
                                                        ),
                                                        color: Colors
                                                            .lightBlueAccent,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0),
                                                            side: BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                                width: 2)),
                                                      ),
                                                    ])),
                                              )
                                            ],
                                          ));
                                    }
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
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
                          child: Text("Filter",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
                            child: Card(
                              child: DropdownButton<String>(
                                //create an array of strings
                                items: filters.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0,
                                          bottom: 0.0,
                                          left: 10.0,
                                          right: 0.0),
                                      child: Text(value,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black)),
                                    ),
                                  );
                                }).toList(),
                                value: filter,
                                onChanged: (String value) {
                                  _onDropDownChanged(value);
                                },
                              ),
                            ))
                      ]),
                    ),
                  ),
                  //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                  Expanded(
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

                                    {
                                      return Container(
                                          width: 0.98 *
                                              MediaQuery.of(context)
                                                  .size
                                                  .width
                                                  .roundToDouble(),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //                 <--- border radius here
                                                ),
                                          ),
                                          // child: Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              course["title"] != null
                                                  ? ListTile(
                                                      trailing: Image.network(
                                                        course["photos"][1],
                                                      ),
                                                      leading: Image.network(
                                                        course["photos"][0],
                                                      ),
                                                      title: Text("Title: " +
                                                          course["title"]),
                                                      subtitle: Text(
                                                          "Price (Customer): " +
                                                              course["price_by_customer"]
                                                                  .toString() +
                                                              "\nPrice (SP): " +
                                                              course["price"]
                                                                  .toString() +
                                                              "\nDistance: " +
                                                              course["distance"]
                                                                  .toStringAsFixed(
                                                                      4)
                                                                  .toString() +
                                                              " km"),
                                                    )
                                                  : ListTile(
                                                      title: Text("Order Id: " +
                                                          course["order id"]),
                                                      subtitle: Text(
                                                        "Price: " +
                                                            course["price"]
                                                                .toString() +
                                                            "\nDistance: " +
                                                            course["distance"]
                                                                .toStringAsFixed(
                                                                    4)
                                                                .toString() +
                                                            " km",
                                                      ),
                                                    ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Center(
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                      Text("Customer Reponse: ",
                                                          style: TextStyle(
                                                              fontSize: 14.0)),
                                                      RaisedButton(
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
                                                          course[
                                                              "customer response"],
                                                          style: TextStyle(
                                                              fontSize: 15.0),
                                                        ),
                                                        color: Colors
                                                            .lightBlueAccent,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0),
                                                            side: BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                                width: 2)),
                                                      ),
                                                    ])),
                                              )
                                            ],
                                          ));
                                    }
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
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
                          child: Text("Filter",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
                            child: Card(
                              child: DropdownButton<String>(
                                //create an array of strings
                                items: filters.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0,
                                          bottom: 0.0,
                                          left: 10.0,
                                          right: 0.0),
                                      child: Text(value,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black)),
                                    ),
                                  );
                                }).toList(),
                                value: filter,
                                onChanged: (String value) {
                                  _onDropDownChanged(value);
                                },
                              ),
                            ))
                      ]),
                    ),
                  ),
                  //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
                  Expanded(
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

                                    {
                                      return Container(
                                          width: 0.98 *
                                              MediaQuery.of(context)
                                                  .size
                                                  .width
                                                  .roundToDouble(),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //                 <--- border radius here
                                                ),
                                          ),
                                          // child: Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              course["title"] != null
                                                  ? ListTile(
                                                      trailing: Image.network(
                                                        course["photos"][1],
                                                      ),
                                                      leading: Image.network(
                                                        course["photos"][0],
                                                      ),
                                                      title: Text("Title: " +
                                                          course["title"]),
                                                      subtitle: Text(
                                                          "Price (Customer): " +
                                                              course["price_by_customer"]
                                                                  .toString() +
                                                              "\nPrice (SP): " +
                                                              course["price"]
                                                                  .toString() +
                                                              "\nDistance: " +
                                                              course["distance"]
                                                                  .toStringAsFixed(
                                                                      4)
                                                                  .toString() +
                                                              " km"),
                                                    )
                                                  : ListTile(
                                                      title: Text("Order Id: " +
                                                          course["order id"]),
                                                      subtitle: Text(
                                                        "Price: " +
                                                            course["price"]
                                                                .toString() +
                                                            "\nDistance: " +
                                                            course["distance"]
                                                                .toStringAsFixed(
                                                                    4)
                                                                .toString() +
                                                            " km",
                                                      ),
                                                    ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Center(
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                      Text("Customer Reponse: ",
                                                          style: TextStyle(
                                                              fontSize: 14.0)),
                                                      RaisedButton(
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
                                                          course[
                                                              "customer response"],
                                                          style: TextStyle(
                                                              fontSize: 15.0),
                                                        ),
                                                        color: Colors
                                                            .lightBlueAccent,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0),
                                                            side: BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                                width: 2)),
                                                      ),
                                                    ])),
                                              )
                                            ],
                                          ));
                                    }
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
