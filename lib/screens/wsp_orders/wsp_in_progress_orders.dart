import 'package:workforce/screens/chat/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/wsp_orders/wsp_in_progress_order_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:url_launcher/url_launcher.dart';

final List<String> imgList = [
  "images/customer_home/carpenter.jpg",
  "images/customer_home/electrician.jpg",
  "images/customer_home/mechanic.jpg",
  "images/customer_home/plumber.jpg",
  "images/customer_home/sofa_cleaning.jpg",
  "images/customer_home/women_hair_cut_and_styling.jpg",
];

class WSPInProgressOrders extends StatefulWidget {
  WSPInProgressOrders({this.uid, this.role});
  final String uid;
  final String role;
  @override
  State<StatefulWidget> createState() => WSPInProgressOrdersState(uid, role);
}

class WSPInProgressOrdersState extends State {
  // bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String uid;
  String role;
  final filters = [
    'No Filter',
    'Price (Low To High)',
    'Price (High To Low)',
  ];
  String filter = 'No Filter';
  final List<Map<dynamic, dynamic>> lists = [];

  WSPInProgressOrdersState(String uid, String role) {
    this.uid = uid;
    this.role = role;
  }

  _makingPhoneCall(String phoneNo) async {
    String url = 'tel:' + phoneNo;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (filter == 'No Filter') {
      return Scaffold(
          appBar:
              AppBar(title: Text("Orders In Progress" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("wsp id", isEqualTo: uid)
                  .where("status", isEqualTo: "In Progress")
                  .where("service type", isEqualTo: role)
                  .snapshots(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.active) {
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
                        child: Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 0.0,
                                      bottom: 0.0,
                                      left: 10.0,
                                      right: 0.0),
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
                                    return CircularProgressIndicator();
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
                                        // height: double.infinity,
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
                                                                      4)),
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
                                                      imgList[0],
                                                    ),
                                                    trailing: Image.asset(
                                                      imgList[0],
                                                    ),
                                                  ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 00.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                        onPressed: () async {
                                                          print("Call");
                                                          print(Firestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .document(course[
                                                                  "user id"])
                                                              .get()
                                                              .then((value) =>
                                                                  _makingPhoneCall(
                                                                      value["phone no"]
                                                                          .toString())));
                                                        },
                                                        child: const Text(
                                                          "Call",
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
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 00.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                          onPressed: () async {
                                                            print(
                                                                "Gives a platform to chat with customer");
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ChatPage(
                                                                      placedOrderId:
                                                                          course
                                                                              .documentID,
                                                                      userId:
                                                                          uid)),
                                                            );
                                                          },
                                                          child: const Text(
                                                            "Chat",
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
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 2))),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 00.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                        onPressed: () async {
                                                          Navigator.push(
                                                              context,
                                                              //builder of MaterialPageRoute will call TodoDetail class
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    WSPInProgressOrderDetails(
                                                                        wspId:
                                                                            uid,
                                                                        orderId:
                                                                            course["order id"]),
                                                              ));
                                                        },
                                                        child: const Text(
                                                          "Order Details",
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
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 0.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                        onPressed: () async {
                                                          print(
                                                              "Submitting the proofs and signatures of customer. Order gets completed and db changes");
                                                          await _asyncSimpleDialog(
                                                              context,
                                                              course[
                                                                  "order id"],
                                                              course
                                                                  .documentID);
                                                        },
                                                        child: const Text(
                                                          "Submit Proofs",
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
                                                    )
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            })),
                  ]);
                } else {
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Image.asset(
                          imgList[0],
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
                            child: Text("No orders in progress yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    } else if (filter == 'Price (Low To High)') {
      return Scaffold(
          appBar:
              AppBar(title: Text("Orders In Progress" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("wsp id", isEqualTo: uid)
                  .where("status", isEqualTo: "In Progress")
                  .where("service type", isEqualTo: role)
                  .orderBy("price")
                  .snapshots(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.active) {
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
                        child: Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 0.0,
                                      bottom: 0.0,
                                      left: 10.0,
                                      right: 0.0),
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
                                    return CircularProgressIndicator();
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
                                        // height: double.infinity,
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
                                                                      4)),
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
                                                      imgList[0],
                                                    ),
                                                    trailing: Image.asset(
                                                      imgList[0],
                                                    ),
                                                  ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 00.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                        onPressed: () async {
                                                          print("Call");
                                                          print(Firestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .document(course[
                                                                  "user id"])
                                                              .get()
                                                              .then((value) =>
                                                                  _makingPhoneCall(
                                                                      value["phone no"]
                                                                          .toString())));
                                                        },
                                                        child: const Text(
                                                          "Call",
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
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 00.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                          onPressed: () async {
                                                            print(
                                                                "Gives a platform to chat with customer");
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ChatPage(
                                                                      placedOrderId:
                                                                          course
                                                                              .documentID,
                                                                      userId:
                                                                          uid)),
                                                            );
                                                          },
                                                          child: const Text(
                                                            "Chat",
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
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 2))),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 00.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                        onPressed: () async {
                                                          Navigator.push(
                                                              context,
                                                              //builder of MaterialPageRoute will call TodoDetail class
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    WSPInProgressOrderDetails(
                                                                        wspId:
                                                                            uid,
                                                                        orderId:
                                                                            course["order id"]),
                                                              ));
                                                        },
                                                        child: const Text(
                                                          "Order Details",
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
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 10.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                        onPressed: () async {
                                                          print(
                                                              "Submitting the proofs and signatures of customer. Order gets completed and db changes");
                                                          await _asyncSimpleDialog(
                                                              context,
                                                              course[
                                                                  "order id"],
                                                              course
                                                                  .documentID);
                                                        },
                                                        child: const Text(
                                                          "Submit Proofs",
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
                                                    )
                                                  ]),
                                            ),
                                            // Padding(
                                            //   padding: EdgeInsets.all(0.0),
                                            //   child: Row(
                                            //     mainAxisAlignment:
                                            //         MainAxisAlignment.center,
                                            //     children: [
                                            //       Icon(
                                            //         Icons.arrow_left_outlined,
                                            //         color: Colors.blue,
                                            //         size: 30.0,
                                            //       ),
                                            //       Icon(
                                            //         Icons.arrow_right_outlined,
                                            //         color: Colors.blue,
                                            //         size: 30.0,
                                            //       ),
                                            //     ],
                                            //   ),
                                            // )
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            })),
                  ]);
                } else {
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Image.asset(
                          imgList[0],
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
                            child: Text("No orders in progress yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    } else if (filter == 'Price (High To Low)') {
      return Scaffold(
          appBar:
              AppBar(title: Text("Orders In Progress" + " ( " + role + " )")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("wsp id", isEqualTo: uid)
                  .where("status", isEqualTo: "In Progress")
                  .where("service type", isEqualTo: role)
                  .orderBy("price", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.active) {
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
                        child: Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 0.0,
                                      bottom: 0.0,
                                      left: 10.0,
                                      right: 0.0),
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
                                    return CircularProgressIndicator();
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
                                        // height: double.infinity,
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
                                                      imgList[0],
                                                    ),
                                                    trailing: Image.asset(
                                                      imgList[0],
                                                    ),
                                                  ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 00.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                        onPressed: () async {
                                                          print("Call");
                                                          print(Firestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .document(course[
                                                                  "user id"])
                                                              .get()
                                                              .then((value) =>
                                                                  _makingPhoneCall(
                                                                      value["phone no"]
                                                                          .toString())));
                                                        },
                                                        child: const Text(
                                                          "Call",
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
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 00.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                          onPressed: () async {
                                                            print(
                                                                "Gives a platform to chat with customer");
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ChatPage(
                                                                      placedOrderId:
                                                                          course
                                                                              .documentID,
                                                                      userId:
                                                                          uid)),
                                                            );
                                                          },
                                                          child: const Text(
                                                            "Chat",
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
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 2))),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 00.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                        onPressed: () async {
                                                          Navigator.push(
                                                              context,
                                                              //builder of MaterialPageRoute will call TodoDetail class
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    WSPInProgressOrderDetails(
                                                                        wspId:
                                                                            uid,
                                                                        orderId:
                                                                            course["order id"]),
                                                              ));
                                                        },
                                                        child: const Text(
                                                          "Order Details",
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
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 10.0,
                                                          left: 20.0,
                                                          right: 10.0),
                                                      child: RaisedButton(
                                                        onPressed: () async {
                                                          print(
                                                              "Submitting the proofs and signatures of customer. Order gets completed and db changes");
                                                          await _asyncSimpleDialog(
                                                              context,
                                                              course[
                                                                  "order id"],
                                                              course
                                                                  .documentID);
                                                        },
                                                        child: const Text(
                                                          "Submit Proofs",
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
                                                    )
                                                  ]),
                                            ),
                                            // Padding(
                                            //   padding: EdgeInsets.all(0.0),
                                            //   child: Row(
                                            //     mainAxisAlignment:
                                            //         MainAxisAlignment.center,
                                            //     children: [
                                            //       Icon(
                                            //         Icons.arrow_left_outlined,
                                            //         color: Colors.blue,
                                            //         size: 30.0,
                                            //       ),
                                            //       Icon(
                                            //         Icons.arrow_right_outlined,
                                            //         color: Colors.blue,
                                            //         size: 30.0,
                                            //       ),
                                            //     ],
                                            //   ),
                                            // )
                                          ],
                                        ),
                                      );
                                    }
                                }
                              }
                            })),
                  ]);
                } else {
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Image.asset(
                          imgList[0],
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
                            child: Text("No orders in progress yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    }
  }

  _onDropDownChanged(String value) {
    setState(() {
      this.filter = value;
    });
  }

  Future _asyncSimpleDialog(
      BuildContext context, String orderId, String placedOrderId) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Submit Proofs'),
            children: <Widget>[
              SimpleDialogOption(
                child: new ProofsAndSignatures(
                    orderId: orderId, placedOrderId: placedOrderId),
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ProofsAndSignatures extends StatefulWidget {
  ProofsAndSignatures({this.orderId, this.placedOrderId});
  final String orderId;
  final String placedOrderId;
  @override
  State<StatefulWidget> createState() =>
      ProofsAndSignaturesState(orderId, placedOrderId);
}

class ProofsAndSignaturesState extends State {
  List<File> _proofImages = [];
  List<File> _signaturesImages = [];
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String orderId;
  String placedOrderId;
  bool signaturesError, proofsError = false;
  final List<Map<dynamic, dynamic>> lists = [];

  void submitProofs(
      String orderId, String placeOrderId, BuildContext contextt) {
    Firestore.instance
        .collection("orders")
        .document(orderId)
        .updateData({"status": "Completed"});

    Firestore.instance
        .collection("placed orders")
        .document(placeOrderId)
        .updateData({
      "status": "Completed",
    }).then((res) {
      uploadFilesToFirestore(placeOrderId, _proofImages, "proofs")
          .whenComplete(() {
        uploadFilesToFirestore(placeOrderId, _signaturesImages, "signatures")
            .whenComplete(() {
          isLoading = false;
          Navigator.pop(contextt);
          Firestore.instance
              .collection("placed orders")
              .document(placeOrderId)
              .updateData({"order completion time": DateTime.now()});
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text("Submitted Proofs"),
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
      });
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

    setState(() {});
  }

  ProofsAndSignaturesState(String orderId, String placedOrderId) {
    this.orderId = orderId;
    this.placedOrderId = placedOrderId;
  }

  void _showPicker(context, List<File> _images) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        getImage(true, _images);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImage(false, _images);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future getImage(bool gallery, List<File> _images) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if (gallery) {
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile = await picker.getImage(
        source: ImageSource.camera,
      );
    }

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
        setState(() {});
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> uploadFile(File _image, String orderId, String type) async {
    StorageReference storageReference;
    if (type == "proofs") {
      storageReference = FirebaseStorage.instance.ref().child(
          'placed orders/${orderId}/${type}/${Path.basename(_image.path)}');
    } else {
      storageReference = FirebaseStorage.instance.ref().child(
          'placed orders/${orderId}/${type}/${Path.basename(_image.path)}');
    }
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    String returnURL;
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL = fileURL;
    });
    return returnURL;
  }

  Future<void> saveImages(
      List<File> _images, DocumentReference ref, String type) async {
    _images.forEach((image) async {
      if (type == "proofs") {
        String imageURL = await uploadFile(image, ref.documentID, type);
        ref.updateData({
          "proofs": FieldValue.arrayUnion([imageURL])
        });
      } else if (type == "signatures") {
        String imageURL = await uploadFile(image, ref.documentID, type);
        ref.updateData({
          "signatures": FieldValue.arrayUnion([imageURL])
        });
      }
    });
  }

  Future uploadFilesToFirestore(
      String docId, List<File> _images, String type) async {
    DocumentReference sightingRef =
        Firestore.instance.collection("placed orders").document(docId);
    await saveImages(_images, sightingRef, type);
  }

  Widget images(List<File> _images) {
    List<Widget> list = new List<Widget>();

    for (var i = 0; i < _images.length; i += 2) {
      if (i + 1 >= _images.length) {
        list.add(Row(children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: 5.0, left: 5.0, right: 5.0, top: 5.0),
                  child: ClipRRect(
                      child: Image.file(
                    _images[i],
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  ))))
        ]));
      } else {
        list.add(Row(children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: 5.0, left: 5.0, right: 5.0, top: 5.0),
                  child: ClipRRect(
                      child: Image.file(
                    _images[i],
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  )))),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: 5.0, left: 5.0, right: 5.0, top: 5.0),
                  child: ClipRRect(
                      child: Image.file(
                    _images[i + 1],
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  ))))
        ]));
      }
    }
    ;

    return new Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 0.98 * MediaQuery.of(context).size.width.roundToDouble(),
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black12,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.all(
              Radius.circular(5.0) //                 <--- border radius here
              ),
        ),
        child: Center(
            child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                proofsError == true
                    ? Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 10.0, bottom: 0.0),
                        child: Text("Please submit atleast 2 proof pictures.",
                            style: TextStyle(
                              color: Colors.red,
                            )))
                    : Container(),
                Row(children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
                      child:
                          Text("Work Proofs", style: TextStyle(fontSize: 15.0)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                        size: 35.0,
                        semanticLabel: 'Camera',
                      ),
                      tooltip: 'Click to add images',
                      onPressed: () {
                        _showPicker(context, _proofImages);
                      },
                    ),
                  )
                ]),
                Padding(
                    padding: EdgeInsets.only(
                        top: 0.0, bottom: 10.0, left: 20.0, right: 20.0),
                    child: Column(children: [
                      _proofImages.length != 0
                          ? Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                  "Choosen images (" +
                                      _proofImages.length.toString() +
                                      ")",
                                  style: TextStyle(fontSize: 15.0)))
                          : Container(),
                      _proofImages.length != 0
                          ? images(_proofImages)
                          : Container(),
                    ])),
                signaturesError == true
                    ? Padding(
                        padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                        child: Text(
                            "Please submit atleast 1 signature picture.",
                            style: TextStyle(color: Colors.red)))
                    : Container(),
                Row(children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(
                        top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
                    child: Text("Customer Signatures",
                        style: TextStyle(fontSize: 15.0)),
                  )),
                  Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                        size: 35.0,
                        semanticLabel: 'Camera',
                      ),
                      tooltip: 'Click to add images',
                      onPressed: () {
                        _showPicker(context, _signaturesImages);
                      },
                    ),
                  )
                ]),
                Padding(
                    padding: EdgeInsets.only(
                        top: 0.0, bottom: 10.0, left: 20.0, right: 20.0),
                    child: Column(children: [
                      _signaturesImages.length != 0
                          ? Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                  "Choosen images (" +
                                      _signaturesImages.length.toString() +
                                      ")",
                                  style: TextStyle(fontSize: 15.0)))
                          : Container(),
                      _signaturesImages.length != 0
                          ? images(_signaturesImages)
                          : Container(),
                    ])),
                Padding(
                  padding: EdgeInsets.only(
                      top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
                  child: isLoading
                      ? CircularProgressIndicator()
                      : RaisedButton(
                          color: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(color: Colors.blue, width: 2)),
                          onPressed: () {
                            if (_signaturesImages.length == 0) {
                              setState(() {
                                signaturesError = true;
                              });
                            } else {
                              setState(() {
                                signaturesError = false;
                              });
                            }
                            if (_proofImages.length < 2) {
                              setState(() {
                                proofsError = true;
                              });
                            } else {
                              setState(() {
                                proofsError = false;
                              });
                            }
                            if (_formKey.currentState.validate() &&
                                _proofImages.length >= 2 &&
                                _signaturesImages.length >= 1) {
                              setState(() {
                                isLoading = true;
                              });
                              submitProofs(orderId, placedOrderId, context);
                            }
                          },
                          child: Text('Submit'),
                        ),
                )
              ])),
        )));
  }
}
