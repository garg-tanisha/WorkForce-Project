import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workforce/utils/images_and_Labels.dart';
import 'package:workforce/utils/methods/images.dart';

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
                                                ListTile(
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
                                                                "\nOrder Date and Time: ",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: DateTime.fromMicrosecondsSinceEpoch(
                                                                    course["date time"]
                                                                        .microsecondsSinceEpoch)
                                                                .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: Image.network(
                                                      course["photos"][0],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: Image.network(
                                                      course["photos"][1],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {},
                                                            child: const Text(
                                                              "Order Details",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
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
                                                                    width: 2)),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //   padding:
                                                        //       EdgeInsets.only(
                                                        //           top: 10.0,
                                                        //           bottom: 00.0,
                                                        //           left: 20.0,
                                                        //           right: 10.0),
                                                        //   child: RaisedButton(
                                                        //     onPressed:
                                                        //         () async {},
                                                        //     child: const Text(
                                                        //       "Reopen Order",
                                                        //       style: TextStyle(
                                                        //           fontSize:
                                                        //               15.0),
                                                        //     ),
                                                        //     color: Colors
                                                        //         .lightBlueAccent,
                                                        //     shape: RoundedRectangleBorder(
                                                        //         borderRadius:
                                                        //             BorderRadius
                                                        //                 .circular(
                                                        //                     30.0),
                                                        //         side: BorderSide(
                                                        //             color: Colors
                                                        //                 .blue,
                                                        //             width: 2)),
                                                        //   ),
                                                        // ),
                                                      ]),
                                                ),
                                              ]));
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
                        Image.asset(noOrderImage,
                            width: 0.8 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            height: 0.3 *
                                MediaQuery.of(context)
                                    .size
                                    .height
                                    .roundToDouble(),
                            fit: BoxFit.cover),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                                                ListTile(
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
                                                                "\nOrder Date and Time: ",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: DateTime.fromMicrosecondsSinceEpoch(
                                                                    course["date time"]
                                                                        .microsecondsSinceEpoch)
                                                                .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: Image.network(
                                                      course["photos"][0],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: Image.network(
                                                      course["photos"][1],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {},
                                                            child: const Text(
                                                              "Order Details",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
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
                                                                    width: 2)),
                                                          ),
                                                        ),
                                                        //   Padding(
                                                        //     padding:
                                                        //         EdgeInsets.only(
                                                        //             top: 10.0,
                                                        //             bottom: 00.0,
                                                        //             left: 20.0,
                                                        //             right: 10.0),
                                                        //     child: RaisedButton(
                                                        //       onPressed:
                                                        //           () async {},
                                                        //       child: const Text(
                                                        //         "Reopen Order",
                                                        //         style: TextStyle(
                                                        //             fontSize:
                                                        //                 15.0),
                                                        //       ),
                                                        //       color: Colors
                                                        //           .lightBlueAccent,
                                                        //       shape: RoundedRectangleBorder(
                                                        //           borderRadius:
                                                        //               BorderRadius
                                                        //                   .circular(
                                                        //                       30.0),
                                                        //           side: BorderSide(
                                                        //               color: Colors
                                                        //                   .blue,
                                                        //               width: 2)),
                                                        //     ),
                                                        //   ),
                                                      ]),
                                                ),
                                              ]));
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
                        Image.asset(noOrderImage,
                            width: 0.8 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            height: 0.3 *
                                MediaQuery.of(context)
                                    .size
                                    .height
                                    .roundToDouble(),
                            fit: BoxFit.cover),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                                                ListTile(
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
                                                                "\nOrder Date and Time: ",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: DateTime.fromMicrosecondsSinceEpoch(
                                                                    course["date time"]
                                                                        .microsecondsSinceEpoch)
                                                                .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: Image.network(
                                                      course["photos"][0],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: Image.network(
                                                      course["photos"][1],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {},
                                                            child: const Text(
                                                              "Order Details",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
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
                                                                    width: 2)),
                                                          ),
                                                        ),
                                                        //         Padding(
                                                        //           padding:
                                                        //               EdgeInsets.only(
                                                        //                   top: 10.0,
                                                        //                   bottom: 00.0,
                                                        //                   left: 20.0,
                                                        //                   right: 10.0),
                                                        //           child: RaisedButton(
                                                        //             onPressed:
                                                        //                 () async {},
                                                        //             child: const Text(
                                                        //               "Reopen Order",
                                                        //               style: TextStyle(
                                                        //                   fontSize:
                                                        //                       15.0),
                                                        //             ),
                                                        //             color: Colors
                                                        //                 .lightBlueAccent,
                                                        //             shape: RoundedRectangleBorder(
                                                        //                 borderRadius:
                                                        //                     BorderRadius
                                                        //                         .circular(
                                                        //                             30.0),
                                                        //                 side: BorderSide(
                                                        //                     color: Colors
                                                        //                         .blue,
                                                        //                     width: 2)),
                                                        //           ),
                                                        //         ),
                                                      ]),
                                                ),
                                              ]));
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
                        Image.asset(noOrderImage,
                            width: 0.8 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            height: 0.3 *
                                MediaQuery.of(context)
                                    .size
                                    .height
                                    .roundToDouble(),
                            fit: BoxFit.cover),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                                                ListTile(
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
                                                                "\nOrder Date and Time: ",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: DateTime.fromMicrosecondsSinceEpoch(
                                                                    course["date time"]
                                                                        .microsecondsSinceEpoch)
                                                                .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: Image.network(
                                                      course["photos"][0],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: Image.network(
                                                      course["photos"][1],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {},
                                                            child: const Text(
                                                              "Order Details",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
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
                                                                    width: 2)),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //   padding:
                                                        //       EdgeInsets.only(
                                                        //           top: 10.0,
                                                        //           bottom: 00.0,
                                                        //           left: 20.0,
                                                        //           right: 10.0),
                                                        //   child: RaisedButton(
                                                        //     onPressed:
                                                        //         () async {},
                                                        //     child: const Text(
                                                        //       "Reopen Order",
                                                        //       style: TextStyle(
                                                        //           fontSize:
                                                        //               15.0),
                                                        //     ),
                                                        //     color: Colors
                                                        //         .lightBlueAccent,
                                                        //     shape: RoundedRectangleBorder(
                                                        //         borderRadius:
                                                        //             BorderRadius
                                                        //                 .circular(
                                                        //                     30.0),
                                                        //         side: BorderSide(
                                                        //             color: Colors
                                                        //                 .blue,
                                                        //             width: 2)),
                                                        //   ),
                                                        // ),
                                                      ]),
                                                ),
                                              ]));
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
                        Image.asset(noOrderImage,
                            width: 0.8 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            height: 0.3 *
                                MediaQuery.of(context)
                                    .size
                                    .height
                                    .roundToDouble(),
                            fit: BoxFit.cover),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                                                ListTile(
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
                                                                "\nOrder Date and Time: ",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: DateTime.fromMicrosecondsSinceEpoch(
                                                                    course["date time"]
                                                                        .microsecondsSinceEpoch)
                                                                .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: Image.network(
                                                      course["photos"][0],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: Image.network(
                                                      course["photos"][1],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {},
                                                            child: const Text(
                                                              "Order Details",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
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
                                                                    width: 2)),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //   padding:
                                                        //       EdgeInsets.only(
                                                        //           top: 10.0,
                                                        //           bottom: 00.0,
                                                        //           left: 20.0,
                                                        //           right: 10.0),
                                                        //   child: RaisedButton(
                                                        //     onPressed:
                                                        //         () async {},
                                                        //     child: const Text(
                                                        //       "Reopen Order",
                                                        //       style: TextStyle(
                                                        //           fontSize:
                                                        //               15.0),
                                                        //     ),
                                                        //     color: Colors
                                                        //         .lightBlueAccent,
                                                        //     shape: RoundedRectangleBorder(
                                                        //         borderRadius:
                                                        //             BorderRadius
                                                        //                 .circular(
                                                        //                     30.0),
                                                        //         side: BorderSide(
                                                        //             color: Colors
                                                        //                 .blue,
                                                        //             width: 2)),
                                                        //   ),
                                                        // ),
                                                      ]),
                                                ),
                                              ]));
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
                        Image.asset(noOrderImage,
                            width: 0.8 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            height: 0.3 *
                                MediaQuery.of(context)
                                    .size
                                    .height
                                    .roundToDouble(),
                            fit: BoxFit.cover),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                                                ListTile(
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
                                                                "\nOrder Date and Time: ",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: DateTime.fromMicrosecondsSinceEpoch(
                                                                    course["date time"]
                                                                        .microsecondsSinceEpoch)
                                                                .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: Image.network(
                                                      course["photos"][0],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: Image.network(
                                                      course["photos"][1],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {},
                                                            child: const Text(
                                                              "Order Details",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
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
                                                                    width: 2)),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //   padding:
                                                        //       EdgeInsets.only(
                                                        //           top: 10.0,
                                                        //           bottom: 00.0,
                                                        //           left: 20.0,
                                                        //           right: 10.0),
                                                        //   child: RaisedButton(
                                                        //     onPressed:
                                                        //         () async {},
                                                        //     child: const Text(
                                                        //       "Reopen Order",
                                                        //       style: TextStyle(
                                                        //           fontSize:
                                                        //               15.0),
                                                        //     ),
                                                        //     color: Colors
                                                        //         .lightBlueAccent,
                                                        //     shape: RoundedRectangleBorder(
                                                        //         borderRadius:
                                                        //             BorderRadius
                                                        //                 .circular(
                                                        //                     30.0),
                                                        //         side: BorderSide(
                                                        //             color: Colors
                                                        //                 .blue,
                                                        //             width: 2)),
                                                        //   ),
                                                        // ),
                                                      ]),
                                                ),
                                              ]));
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
                        Image.asset(noOrderImage,
                            width: 0.8 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            height: 0.3 *
                                MediaQuery.of(context)
                                    .size
                                    .height
                                    .roundToDouble(),
                            fit: BoxFit.cover),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                                                ListTile(
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
                                                                "\nOrder Date and Time: ",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: DateTime.fromMicrosecondsSinceEpoch(
                                                                    course["date time"]
                                                                        .microsecondsSinceEpoch)
                                                                .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: Image.network(
                                                      course["photos"][0],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: Image.network(
                                                      course["photos"][1],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {},
                                                            child: const Text(
                                                              "Order Details",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
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
                                                                    width: 2)),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //   padding:
                                                        //       EdgeInsets.only(
                                                        //           top: 10.0,
                                                        //           bottom: 00.0,
                                                        //           left: 20.0,
                                                        //           right: 10.0),
                                                        //   child: RaisedButton(
                                                        //     onPressed:
                                                        //         () async {},
                                                        //     child: const Text(
                                                        //       "Reopen Order",
                                                        //       style: TextStyle(
                                                        //           fontSize:
                                                        //               15.0),
                                                        //     ),
                                                        //     color: Colors
                                                        //         .lightBlueAccent,
                                                        //     shape: RoundedRectangleBorder(
                                                        //         borderRadius:
                                                        //             BorderRadius
                                                        //                 .circular(
                                                        //                     30.0),
                                                        //         side: BorderSide(
                                                        //             color: Colors
                                                        //                 .blue,
                                                        //             width: 2)),
                                                        //   ),
                                                        // ),
                                                      ]),
                                                ),
                                              ]));
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
                        Image.asset(noOrderImage,
                            width: 0.8 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            height: 0.3 *
                                MediaQuery.of(context)
                                    .size
                                    .height
                                    .roundToDouble(),
                            fit: BoxFit.cover),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                                                ListTile(
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
                                                                "\nOrder Date and Time: ",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: DateTime.fromMicrosecondsSinceEpoch(
                                                                    course["date time"]
                                                                        .microsecondsSinceEpoch)
                                                                .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: Image.network(
                                                      course["photos"][0],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: Image.network(
                                                      course["photos"][1],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {},
                                                            child: const Text(
                                                              "Order Details",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
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
                                                                    width: 2)),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //   padding:
                                                        //       EdgeInsets.only(
                                                        //           top: 10.0,
                                                        //           bottom: 00.0,
                                                        //           left: 20.0,
                                                        //           right: 10.0),
                                                        //   child: RaisedButton(
                                                        //     onPressed:
                                                        //         () async {},
                                                        //     child: const Text(
                                                        //       "Reopen Order",
                                                        //       style: TextStyle(
                                                        //           fontSize:
                                                        //               15.0),
                                                        //     ),
                                                        //     color: Colors
                                                        //         .lightBlueAccent,
                                                        //     shape: RoundedRectangleBorder(
                                                        //         borderRadius:
                                                        //             BorderRadius
                                                        //                 .circular(
                                                        //                     30.0),
                                                        //         side: BorderSide(
                                                        //             color: Colors
                                                        //                 .blue,
                                                        //             width: 2)),
                                                        //   ),
                                                        // ),
                                                      ]),
                                                ),
                                              ]));
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
                        Image.asset(noOrderImage,
                            width: 0.8 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            height: 0.3 *
                                MediaQuery.of(context)
                                    .size
                                    .height
                                    .roundToDouble(),
                            fit: BoxFit.cover),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
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
                                                ListTile(
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
                                                                "\nOrder Date and Time: ",
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        new TextSpan(
                                                            text: DateTime.fromMicrosecondsSinceEpoch(
                                                                    course["date time"]
                                                                        .microsecondsSinceEpoch)
                                                                .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                  leading: Image.network(
                                                      course["photos"][0],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: Image.network(
                                                      course["photos"][1],
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                ),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {},
                                                            child: const Text(
                                                              "Order Details",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
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
                                                                    width: 2)),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //   padding:
                                                        //       EdgeInsets.only(
                                                        //           top: 10.0,
                                                        //           bottom: 00.0,
                                                        //           left: 20.0,
                                                        //           right: 10.0),
                                                        //   child: RaisedButton(
                                                        //     onPressed:
                                                        //         () async {},
                                                        //     child: const Text(
                                                        //       "Reopen Order",
                                                        //       style: TextStyle(
                                                        //           fontSize:
                                                        //               15.0),
                                                        //     ),
                                                        //     color: Colors
                                                        //         .lightBlueAccent,
                                                        //     shape: RoundedRectangleBorder(
                                                        //         borderRadius:
                                                        //             BorderRadius
                                                        //                 .circular(
                                                        //                     30.0),
                                                        //         side: BorderSide(
                                                        //             color: Colors
                                                        //                 .blue,
                                                        //             width: 2)),
                                                        //   ),
                                                        // ),
                                                      ]),
                                                ),
                                              ]));
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
                        Image.asset(noOrderImage,
                            width: 0.8 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            height: 0.3 *
                                MediaQuery.of(context)
                                    .size
                                    .height
                                    .roundToDouble(),
                            fit: BoxFit.cover),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text("No orders yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
