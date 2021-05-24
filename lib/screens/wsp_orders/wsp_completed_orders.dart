import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/wsp_orders/wsp_completed_order_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final String noOrderImage = "images/customer_home/carpenter.jpg";

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
                    Container(
                      width: 0.98 *
                          MediaQuery.of(context).size.width.roundToDouble(),
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
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 10.0,
                                  right: 10.0),
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
                              )),
                        ]),
                      ),
                    ),
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
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            course["title"] != null
                                                ? ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Title: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "title"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nService Date and Time: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: DateTime.fromMicrosecondsSinceEpoch(
                                                                      course["service date and time"]
                                                                          .microsecondsSinceEpoch)
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nDistance: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "distance"]
                                                                  .toStringAsFixed(
                                                                      4))
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.network(
                                                      course["photos"][0],
                                                    ),
                                                    trailing: Image.network(
                                                      course["photos"][1],
                                                    ),
                                                  )
                                                : ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text:
                                                                  'Order Id: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "order id"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                    trailing: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                  ),
                                            RaisedButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          WSPCompletedOrderDetails(
                                                              wspId: uid,
                                                              orderId: course[
                                                                  "order id"]),
                                                    ));
                                              },
                                              child: const Text(
                                                "Order Details",
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              color: Colors.lightBlueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                  side: BorderSide(
                                                      color: Colors.blue,
                                                      width: 2)),
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
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Image.asset(
                          noOrderImage,
                          width: 0.8 *
                              MediaQuery.of(context).size.width.roundToDouble(),
                          height: 0.3 *
                              MediaQuery.of(context)
                                  .size
                                  .height
                                  .roundToDouble(),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders completed yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                    Container(
                      width: 0.98 *
                          MediaQuery.of(context).size.width.roundToDouble(),
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
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 10.0,
                                  right: 10.0),
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
                              )),
                        ]),
                      ),
                    ),
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
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            course["title"] != null
                                                ? ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Title: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "title"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nService Date and Time: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: DateTime.fromMicrosecondsSinceEpoch(
                                                                      course["service date and time"]
                                                                          .microsecondsSinceEpoch)
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nDistance: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "distance"]
                                                                  .toStringAsFixed(
                                                                      4))
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.network(
                                                      course["photos"][0],
                                                    ),
                                                    trailing: Image.network(
                                                      course["photos"][1],
                                                    ),
                                                  )
                                                : ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text:
                                                                  'Order Id: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "order id"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                    trailing: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                  ),
                                            RaisedButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          WSPCompletedOrderDetails(
                                                              wspId: uid,
                                                              orderId: course[
                                                                  "order id"]),
                                                    ));
                                              },
                                              child: const Text(
                                                "Order Details",
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              color: Colors.lightBlueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                  side: BorderSide(
                                                      color: Colors.blue,
                                                      width: 2)),
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
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Image.asset(
                          noOrderImage,
                          width: 0.8 *
                              MediaQuery.of(context).size.width.roundToDouble(),
                          height: 0.3 *
                              MediaQuery.of(context)
                                  .size
                                  .height
                                  .roundToDouble(),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders completed yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                    Container(
                      width: 0.98 *
                          MediaQuery.of(context).size.width.roundToDouble(),
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
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 10.0,
                                  right: 10.0),
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
                              )),
                        ]),
                      ),
                    ),
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
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            course["title"] != null
                                                ? ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Title: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "title"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nService Date and Time: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: DateTime.fromMicrosecondsSinceEpoch(
                                                                      course["service date and time"]
                                                                          .microsecondsSinceEpoch)
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nDistance: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "distance"]
                                                                  .toStringAsFixed(
                                                                      4))
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.network(
                                                      course["photos"][0],
                                                    ),
                                                    trailing: Image.network(
                                                      course["photos"][1],
                                                    ),
                                                  )
                                                : ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text:
                                                                  'Order Id: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "order id"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                    trailing: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                  ),
                                            RaisedButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          WSPCompletedOrderDetails(
                                                              wspId: uid,
                                                              orderId: course[
                                                                  "order id"]),
                                                    ));
                                              },
                                              child: const Text(
                                                "Order Details",
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              color: Colors.lightBlueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                  side: BorderSide(
                                                      color: Colors.blue,
                                                      width: 2)),
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
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Image.asset(
                          noOrderImage,
                          width: 0.8 *
                              MediaQuery.of(context).size.width.roundToDouble(),
                          height: 0.3 *
                              MediaQuery.of(context)
                                  .size
                                  .height
                                  .roundToDouble(),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders completed yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                    Container(
                      width: 0.98 *
                          MediaQuery.of(context).size.width.roundToDouble(),
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
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 10.0,
                                  right: 10.0),
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
                              )),
                        ]),
                      ),
                    ),
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
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            course["title"] != null
                                                ? ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Title: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "title"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nService Date and Time: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: DateTime.fromMicrosecondsSinceEpoch(
                                                                      course["service date and time"]
                                                                          .microsecondsSinceEpoch)
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nDistance: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "distance"]
                                                                  .toStringAsFixed(
                                                                      4))
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.network(
                                                      course["photos"][0],
                                                    ),
                                                    trailing: Image.network(
                                                      course["photos"][1],
                                                    ),
                                                  )
                                                : ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text:
                                                                  'Order Id: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "order id"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                    trailing: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                  ),
                                            RaisedButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          WSPCompletedOrderDetails(
                                                              wspId: uid,
                                                              orderId: course[
                                                                  "order id"]),
                                                    ));
                                              },
                                              child: const Text(
                                                "Order Details",
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              color: Colors.lightBlueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                  side: BorderSide(
                                                      color: Colors.blue,
                                                      width: 2)),
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
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Image.asset(
                          noOrderImage,
                          width: 0.8 *
                              MediaQuery.of(context).size.width.roundToDouble(),
                          height: 0.3 *
                              MediaQuery.of(context)
                                  .size
                                  .height
                                  .roundToDouble(),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders completed yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                    Container(
                      width: 0.98 *
                          MediaQuery.of(context).size.width.roundToDouble(),
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
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 10.0,
                                  right: 10.0),
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
                              )),
                        ]),
                      ),
                    ),
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
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            course["title"] != null
                                                ? ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Title: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "title"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nService Date and Time: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: DateTime.fromMicrosecondsSinceEpoch(
                                                                      course["service date and time"]
                                                                          .microsecondsSinceEpoch)
                                                                  .toString()),
                                                          new TextSpan(
                                                              text:
                                                                  "\nDistance: ",
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "distance"]
                                                                  .toStringAsFixed(
                                                                      4))
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.network(
                                                      course["photos"][0],
                                                    ),
                                                    trailing: Image.network(
                                                      course["photos"][1],
                                                    ),
                                                  )
                                                : ListTile(
                                                    title: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text:
                                                                  'Order Id: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                  "order id"]),
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 20.0,
                                                          color: Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Price: ',
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          new TextSpan(
                                                              text: course[
                                                                      "price"]
                                                                  .toString()),
                                                        ],
                                                      ),
                                                    ),
                                                    leading: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                    trailing: Image.asset(
                                                      noOrderImage,
                                                    ),
                                                  ),
                                            RaisedButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          WSPCompletedOrderDetails(
                                                              wspId: uid,
                                                              orderId: course[
                                                                  "order id"]),
                                                    ));
                                              },
                                              child: const Text(
                                                "Order Details",
                                                style:
                                                    TextStyle(fontSize: 15.0),
                                              ),
                                              color: Colors.lightBlueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                  side: BorderSide(
                                                      color: Colors.blue,
                                                      width: 2)),
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
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Image.asset(
                          noOrderImage,
                          width: 0.8 *
                              MediaQuery.of(context).size.width.roundToDouble(),
                          height: 0.3 *
                              MediaQuery.of(context)
                                  .size
                                  .height
                                  .roundToDouble(),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders completed yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
