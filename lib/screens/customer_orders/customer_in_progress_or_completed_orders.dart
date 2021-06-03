import 'package:workforce/utils/images_and_Labels.dart';
import 'package:workforce/main.dart';
import 'package:workforce/screens/chat/chat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'customer_completed_order_details.dart';
import 'customer_in_progress_order_details.dart';

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

  _makingPhoneCall(String phoneNo) async {
    String url = 'tel:' + phoneNo;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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

  @override
  Widget build(BuildContext context) {
    if (filter == 'No Filter') {
      return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              appBar: AppBar(
                title: Text("Orders (" + status + " )"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      FirebaseAuth auth = FirebaseAuth.instance;
                      auth.signOut().then((res) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      });
                    },
                  )
                ],
              ),
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
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 20.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                text: 'Title: ',
                                                              ),
                                                              new TextSpan(
                                                                  text: course[
                                                                      "title"]),
                                                            ],
                                                          ),
                                                        ),
                                                        subtitle: RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 18.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                  text:
                                                                      'Price: ',
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  )),
                                                              new TextSpan(
                                                                  text: course[
                                                                          "price"]
                                                                      .toString()),
                                                              // new TextSpan(
                                                              //     text:
                                                              //         "\nService Date and Time: ",
                                                              //     style:
                                                              //         new TextStyle(
                                                              //       color: Colors
                                                              //           .black54,
                                                              //     )),
                                                              // new TextSpan(
                                                              //     text: DateTime.fromMicrosecondsSinceEpoch(
                                                              //             course["service date and time"]
                                                              //                 .microsecondsSinceEpoch)
                                                              //         .toString()),
                                                              new TextSpan(
                                                                  text:
                                                                      "\nDistance: ",
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  )),
                                                              new TextSpan(
                                                                  text: course[
                                                                              "distance"]
                                                                          .toStringAsFixed(
                                                                              4) +
                                                                      " km"),
                                                            ],
                                                          ),
                                                        ),
                                                        leading: Image.network(
                                                            course["photos"][0],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                        trailing: Image.network(
                                                            course["photos"][1],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                      )
                                                    : ListTile(
                                                        title: RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 20.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                text:
                                                                    'Order Id: ',
                                                              ),
                                                              new TextSpan(
                                                                  text: course[
                                                                      "order id"]),
                                                            ],
                                                          ),
                                                        ),
                                                        subtitle: RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 18.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                  text:
                                                                      'Price: ',
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  )),
                                                              new TextSpan(
                                                                  text: course[
                                                                          "price"]
                                                                      .toString()),
                                                            ],
                                                          ),
                                                        ),
                                                        leading: Image.asset(
                                                            imgList[0],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                        trailing: Image.asset(
                                                            imgList[0],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                      ),
                                                status == "In Progress"
                                                    ? SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            00.0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            10.0),
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    print(
                                                                        "Call");
                                                                    print(Firestore
                                                                        .instance
                                                                        .collection(
                                                                            'users')
                                                                        .document(course[
                                                                            "user id"])
                                                                        .get()
                                                                        .then((value) =>
                                                                            _makingPhoneCall(value["phone no"].toString())));
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Call",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                  color: Colors
                                                                      .lightBlueAccent,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                      side: BorderSide(
                                                                          color: Colors
                                                                              .blue,
                                                                          width:
                                                                              2)),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            00.0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            10.0),
                                                                child:
                                                                    RaisedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          print(
                                                                              "Gives a platform to chat with customer");
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => ChatPage(placedOrderId: course.documentID, userId: uid)),
                                                                          );
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          "Chat",
                                                                          style:
                                                                              TextStyle(fontSize: 15.0),
                                                                        ),
                                                                        color: Colors
                                                                            .lightBlueAccent,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(30.0),
                                                                            side: BorderSide(color: Colors.blue, width: 2))),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            00.0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            10.0),
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.push(
                                                                        context,
                                                                        //builder of MaterialPageRoute will call TodoDetail class
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              CustomerInProgressOrderDetails(
                                                                            uid:
                                                                                uid,
                                                                            wspId:
                                                                                course["wsp id"],
                                                                            orderId:
                                                                                course["order id"],
                                                                          ),
                                                                        ));
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Order Details",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                  color: Colors
                                                                      .lightBlueAccent,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                      side: BorderSide(
                                                                          color: Colors
                                                                              .blue,
                                                                          width:
                                                                              2)),
                                                                ),
                                                              ),
                                                            ]),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            CustomerCompletedOrderDetails(
                                                                              uid: uid,
                                                                              wspId: course["wsp id"],
                                                                              orderId: course["order id"],
                                                                            )));
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
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 2)),
                                                        ),
                                                      )
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
                                child: Text("No orders in progress yet!",
                                    style: TextStyle(fontSize: 15.0)))
                          ]));
                    }
                  })));
    } else if (filter == 'Price (Min To Max)') {
      return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              appBar: AppBar(
                title: Text("Orders (" + status + " )"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      FirebaseAuth auth = FirebaseAuth.instance;
                      auth.signOut().then((res) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      });
                    },
                  )
                ],
              ),
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
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 20.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                text: 'Title: ',
                                                              ),
                                                              new TextSpan(
                                                                  text: course[
                                                                      "title"]),
                                                            ],
                                                          ),
                                                        ),
                                                        subtitle: RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 18.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                  text:
                                                                      'Price: ',
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  )),
                                                              new TextSpan(
                                                                  text: course[
                                                                          "price"]
                                                                      .toString()),
                                                              // new TextSpan(
                                                              //     text:
                                                              //         "\nService Date and Time: ",
                                                              //     style:
                                                              //         new TextStyle(
                                                              //       color: Colors
                                                              //           .black54,
                                                              //     )),
                                                              // new TextSpan(
                                                              //     text: DateTime.fromMicrosecondsSinceEpoch(
                                                              //             course["service date and time"]
                                                              //                 .microsecondsSinceEpoch)
                                                              //         .toString()),
                                                              new TextSpan(
                                                                  text:
                                                                      "\nDistance: ",
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  )),
                                                              new TextSpan(
                                                                  text: course[
                                                                              "distance"]
                                                                          .toStringAsFixed(
                                                                              4) +
                                                                      " km"),
                                                            ],
                                                          ),
                                                        ),
                                                        leading: Image.network(
                                                            course["photos"][0],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                        trailing: Image.network(
                                                            course["photos"][1],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                      )
                                                    : ListTile(
                                                        title: RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 20.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                text:
                                                                    'Order Id: ',
                                                              ),
                                                              new TextSpan(
                                                                  text: course[
                                                                      "order id"]),
                                                            ],
                                                          ),
                                                        ),
                                                        subtitle: RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 18.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                  text:
                                                                      'Price: ',
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  )),
                                                              new TextSpan(
                                                                  text: course[
                                                                          "price"]
                                                                      .toString()),
                                                            ],
                                                          ),
                                                        ),
                                                        leading: Image.asset(
                                                            imgList[0],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                        trailing: Image.asset(
                                                            imgList[0],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                      ),
                                                status == "In Progress"
                                                    ? SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            00.0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            10.0),
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    print(
                                                                        "Call");
                                                                    print(Firestore
                                                                        .instance
                                                                        .collection(
                                                                            'users')
                                                                        .document(course[
                                                                            "user id"])
                                                                        .get()
                                                                        .then((value) =>
                                                                            _makingPhoneCall(value["phone no"].toString())));
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Call",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                  color: Colors
                                                                      .lightBlueAccent,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                      side: BorderSide(
                                                                          color: Colors
                                                                              .blue,
                                                                          width:
                                                                              2)),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            00.0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            10.0),
                                                                child:
                                                                    RaisedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          print(
                                                                              "Gives a platform to chat with customer");
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => ChatPage(placedOrderId: course.documentID, userId: uid)),
                                                                          );
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          "Chat",
                                                                          style:
                                                                              TextStyle(fontSize: 15.0),
                                                                        ),
                                                                        color: Colors
                                                                            .lightBlueAccent,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(30.0),
                                                                            side: BorderSide(color: Colors.blue, width: 2))),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            00.0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            10.0),
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.push(
                                                                        context,
                                                                        //builder of MaterialPageRoute will call TodoDetail class
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              CustomerInProgressOrderDetails(
                                                                            uid:
                                                                                uid,
                                                                            wspId:
                                                                                course["wsp id"],
                                                                            orderId:
                                                                                course["order id"],
                                                                          ),
                                                                        ));
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Order Details",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                  color: Colors
                                                                      .lightBlueAccent,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                      side: BorderSide(
                                                                          color: Colors
                                                                              .blue,
                                                                          width:
                                                                              2)),
                                                                ),
                                                              ),
                                                            ]),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            CustomerCompletedOrderDetails(
                                                                              uid: uid,
                                                                              wspId: course["wsp id"],
                                                                              orderId: course["order id"],
                                                                            )));
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
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 2)),
                                                        ),
                                                      )
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
                                child: Text("No orders in progress yet!",
                                    style: TextStyle(fontSize: 15.0)))
                          ]));
                    }
                  })));
    } else if (filter == 'Price (Max To Min)') {
      return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              appBar: AppBar(
                title: Text("Orders (" + status + " )"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      FirebaseAuth auth = FirebaseAuth.instance;
                      auth.signOut().then((res) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      });
                    },
                  )
                ],
              ),
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
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 20.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                text: 'Title: ',
                                                              ),
                                                              new TextSpan(
                                                                  text: course[
                                                                      "title"]),
                                                            ],
                                                          ),
                                                        ),
                                                        subtitle: RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 18.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                  text:
                                                                      'Price: ',
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  )),
                                                              new TextSpan(
                                                                  text: course[
                                                                          "price"]
                                                                      .toString()),
                                                              new TextSpan(
                                                                  text:
                                                                      "\nService Date and Time: ",
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  )),
                                                              // new TextSpan(
                                                              //     text: DateTime.fromMicrosecondsSinceEpoch(
                                                              //             course["service date and time"]
                                                              //                 .microsecondsSinceEpoch)
                                                              //         .toString()),
                                                              // new TextSpan(
                                                              //     text:
                                                              //         "\nDistance: ",
                                                              //     style:
                                                              //         new TextStyle(
                                                              //       color: Colors
                                                              //           .black54,
                                                              //     )),
                                                              new TextSpan(
                                                                  text: course[
                                                                              "distance"]
                                                                          .toStringAsFixed(
                                                                              4) +
                                                                      " km"),
                                                            ],
                                                          ),
                                                        ),
                                                        leading: Image.network(
                                                            course["photos"][0],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                        trailing: Image.network(
                                                            course["photos"][1],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                      )
                                                    : ListTile(
                                                        title: RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 20.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                text:
                                                                    'Order Id: ',
                                                              ),
                                                              new TextSpan(
                                                                  text: course[
                                                                      "order id"]),
                                                            ],
                                                          ),
                                                        ),
                                                        subtitle: RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 18.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                  text:
                                                                      'Price: ',
                                                                  style:
                                                                      new TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                  )),
                                                              new TextSpan(
                                                                  text: course[
                                                                          "price"]
                                                                      .toString()),
                                                            ],
                                                          ),
                                                        ),
                                                        leading: Image.asset(
                                                            imgList[0],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                        trailing: Image.asset(
                                                            imgList[0],
                                                            width: 0.2 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width
                                                                    .roundToDouble(),
                                                            height: 100,
                                                            fit: BoxFit.fill),
                                                      ),
                                                status == "In Progress"
                                                    ? SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            00.0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            10.0),
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    print(
                                                                        "Call");
                                                                    print(Firestore
                                                                        .instance
                                                                        .collection(
                                                                            'users')
                                                                        .document(course[
                                                                            "user id"])
                                                                        .get()
                                                                        .then((value) =>
                                                                            _makingPhoneCall(value["phone no"].toString())));
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Call",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                  color: Colors
                                                                      .lightBlueAccent,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                      side: BorderSide(
                                                                          color: Colors
                                                                              .blue,
                                                                          width:
                                                                              2)),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            00.0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            10.0),
                                                                child:
                                                                    RaisedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          print(
                                                                              "Gives a platform to chat with customer");
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => ChatPage(placedOrderId: course.documentID, userId: uid)),
                                                                          );
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          "Chat",
                                                                          style:
                                                                              TextStyle(fontSize: 15.0),
                                                                        ),
                                                                        color: Colors
                                                                            .lightBlueAccent,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(30.0),
                                                                            side: BorderSide(color: Colors.blue, width: 2))),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            00.0,
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            10.0),
                                                                child:
                                                                    RaisedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.push(
                                                                        context,
                                                                        //builder of MaterialPageRoute will call TodoDetail class
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              CustomerInProgressOrderDetails(
                                                                            uid:
                                                                                uid,
                                                                            wspId:
                                                                                course["wsp id"],
                                                                            orderId:
                                                                                course["order id"],
                                                                          ),
                                                                        ));
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Order Details",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                  color: Colors
                                                                      .lightBlueAccent,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                      side: BorderSide(
                                                                          color: Colors
                                                                              .blue,
                                                                          width:
                                                                              2)),
                                                                ),
                                                              ),
                                                            ]),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            CustomerCompletedOrderDetails(
                                                                              uid: uid,
                                                                              wspId: course["wsp id"],
                                                                              orderId: course["order id"],
                                                                            )));
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
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 2)),
                                                        ),
                                                      )
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
                                child: Text("No orders in progress yet!",
                                    style: TextStyle(fontSize: 15.0)))
                          ]));
                    }
                  })));
    } else if (status != "In Progress") {
      if (filter == "Order Completion Time (Asc)") {
        return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                appBar: AppBar(
                  title: Text("Orders (" + status + " )"),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        FirebaseAuth auth = FirebaseAuth.instance;
                        auth.signOut().then((res) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()),
                          );
                        });
                      },
                    )
                  ],
                ),
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
                          Container(
                            width: 0.98 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            color: Colors.black,
                            margin: const EdgeInsets.all(20.0),
                            padding: EdgeInsets.only(
                                top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: [
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
                          Expanded(
                              // height: 200.0,
                              child: ListView.builder(
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, index) {
                                    if (snapshot.hasError) {
                                      print(snapshot.error);
                                      return new Text(
                                          'Error: ${snapshot.error}');
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

                                            // return Card(
                                            //   child: Column(
                                            //     crossAxisAlignment:
                                            //         CrossAxisAlignment.start,
                                            //     children: <Widget>[
                                            //       Text("Order id: " +
                                            //           course["order id"]),
                                            //       Text("Price: " +
                                            //           course["price"].toString()),
                                            //       Text("WSP id: " + course["wsp id"]),
                                            //       Text("Distance: " +
                                            //           course["distance"]
                                            //               .toString()), // orderDoc != null ? Text("Hi") : Container(),
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
                                                              style:
                                                                  new TextStyle(
                                                                fontSize: 20.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                  text:
                                                                      'Title: ',
                                                                ),
                                                                new TextSpan(
                                                                    text: course[
                                                                        "title"]),
                                                              ],
                                                            ),
                                                          ),
                                                          subtitle: RichText(
                                                            text: new TextSpan(
                                                              style:
                                                                  new TextStyle(
                                                                fontSize: 18.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                    text:
                                                                        'Price: ',
                                                                    style:
                                                                        new TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                    )),
                                                                new TextSpan(
                                                                    text: course[
                                                                            "price"]
                                                                        .toString()),
                                                                new TextSpan(
                                                                    text:
                                                                        "\nService Date and Time: ",
                                                                    style:
                                                                        new TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                    )),
                                                                // new TextSpan(
                                                                //     text: DateTime.fromMicrosecondsSinceEpoch(
                                                                //             course["service date and time"]
                                                                //                 .microsecondsSinceEpoch)
                                                                //         .toString()),
                                                                // new TextSpan(
                                                                //     text:
                                                                //         "\nDistance: ",
                                                                //     style:
                                                                //         new TextStyle(
                                                                //       color: Colors
                                                                //           .black54,
                                                                //     )),
                                                                new TextSpan(
                                                                    text: course["distance"]
                                                                            .toStringAsFixed(4) +
                                                                        " km"),
                                                              ],
                                                            ),
                                                          ),
                                                          leading: Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                          trailing: Image.network(
                                                              course["photos"]
                                                                  [1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                        )
                                                      : ListTile(
                                                          title: RichText(
                                                            text: new TextSpan(
                                                              style:
                                                                  new TextStyle(
                                                                fontSize: 20.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                  text:
                                                                      'Order Id: ',
                                                                ),
                                                                new TextSpan(
                                                                    text: course[
                                                                        "order id"]),
                                                              ],
                                                            ),
                                                          ),
                                                          subtitle: RichText(
                                                            text: new TextSpan(
                                                              style:
                                                                  new TextStyle(
                                                                fontSize: 18.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                    text:
                                                                        'Price: ',
                                                                    style:
                                                                        new TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                    )),
                                                                new TextSpan(
                                                                    text: course[
                                                                            "price"]
                                                                        .toString()),
                                                              ],
                                                            ),
                                                          ),
                                                          leading: Image.asset(
                                                              imgList[0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                          trailing: Image.asset(
                                                              imgList[0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                        ),
                                                  status == "In Progress"
                                                      ? SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets.only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          00.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                                  child:
                                                                      RaisedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      print(
                                                                          "Call");
                                                                      print(Firestore
                                                                          .instance
                                                                          .collection(
                                                                              'users')
                                                                          .document(course[
                                                                              "user id"])
                                                                          .get()
                                                                          .then((value) =>
                                                                              _makingPhoneCall(value["phone no"].toString())));
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "Call",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0),
                                                                    ),
                                                                    color: Colors
                                                                        .lightBlueAccent,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
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
                                                                      bottom:
                                                                          00.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                                  child:
                                                                      RaisedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            print("Gives a platform to chat with customer");
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => ChatPage(placedOrderId: course.documentID, userId: uid)),
                                                                            );
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            "Chat",
                                                                            style:
                                                                                TextStyle(fontSize: 15.0),
                                                                          ),
                                                                          color: Colors
                                                                              .lightBlueAccent,
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(30.0),
                                                                              side: BorderSide(color: Colors.blue, width: 2))),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          00.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                                  child:
                                                                      RaisedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.push(
                                                                          context,
                                                                          //builder of MaterialPageRoute will call TodoDetail class
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                CustomerInProgressOrderDetails(
                                                                              uid: uid,
                                                                              wspId: course["wsp id"],
                                                                              orderId: course["order id"],
                                                                            ),
                                                                          ));
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "Order Details",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0),
                                                                    ),
                                                                    color: Colors
                                                                        .lightBlueAccent,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                30.0),
                                                                        side: BorderSide(
                                                                            color:
                                                                                Colors.blue,
                                                                            width: 2)),
                                                                  ),
                                                                ),
                                                              ]),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          CustomerCompletedOrderDetails(
                                                                            uid:
                                                                                uid,
                                                                            wspId:
                                                                                course["wsp id"],
                                                                            orderId:
                                                                                course["order id"],
                                                                          )));
                                                            },
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
                                                        )
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
                              Image.asset(imgList[0],
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
                                  child: Text("No orders in progress yet!",
                                      style: TextStyle(fontSize: 15.0)))
                            ]));
                      }
                    })));
      } else if (filter == "Order Completion Time(Dsc)") {
        return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                appBar: AppBar(
                  title: Text("Orders (" + status + " )"),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        FirebaseAuth auth = FirebaseAuth.instance;
                        auth.signOut().then((res) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()),
                          );
                        });
                      },
                    )
                  ],
                ),
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
                          Container(
                            width: 0.98 *
                                MediaQuery.of(context)
                                    .size
                                    .width
                                    .roundToDouble(),
                            color: Colors.black,
                            margin: const EdgeInsets.all(20.0),
                            padding: EdgeInsets.only(
                                top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: [
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
                          Expanded(
                              // height: 200.0,
                              child: ListView.builder(
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, index) {
                                    if (snapshot.hasError) {
                                      print(snapshot.error);
                                      return new Text(
                                          'Error: ${snapshot.error}');
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

                                            // return Card(
                                            //   child: Column(
                                            //     crossAxisAlignment:
                                            //         CrossAxisAlignment.start,
                                            //     children: <Widget>[
                                            //       Text("Order id: " +
                                            //           course["order id"]),
                                            //       Text("Price: " +
                                            //           course["price"].toString()),
                                            //       Text("WSP id: " + course["wsp id"]),
                                            //       Text("Distance: " +
                                            //           course["distance"]
                                            //               .toString()), // orderDoc != null ? Text("Hi") : Container(),
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
                                                              style:
                                                                  new TextStyle(
                                                                fontSize: 20.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                  text:
                                                                      'Title: ',
                                                                ),
                                                                new TextSpan(
                                                                    text: course[
                                                                        "title"]),
                                                              ],
                                                            ),
                                                          ),
                                                          subtitle: RichText(
                                                            text: new TextSpan(
                                                              style:
                                                                  new TextStyle(
                                                                fontSize: 18.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                    text:
                                                                        'Price: ',
                                                                    style:
                                                                        new TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                    )),
                                                                new TextSpan(
                                                                    text: course[
                                                                            "price"]
                                                                        .toString()),
                                                                new TextSpan(
                                                                    text:
                                                                        "\nService Date and Time: ",
                                                                    style:
                                                                        new TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                    )),
                                                                // new TextSpan(
                                                                //     text: DateTime.fromMicrosecondsSinceEpoch(
                                                                //             course["service date and time"]
                                                                //                 .microsecondsSinceEpoch)
                                                                //         .toString()),
                                                                // new TextSpan(
                                                                //     text:
                                                                //         "\nDistance: ",
                                                                //     style:
                                                                //         new TextStyle(
                                                                //       color: Colors
                                                                //           .black54,
                                                                //     )),
                                                                new TextSpan(
                                                                    text: course["distance"]
                                                                            .toStringAsFixed(4) +
                                                                        " km"),
                                                              ],
                                                            ),
                                                          ),
                                                          leading: Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                          trailing: Image.network(
                                                              course["photos"]
                                                                  [1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                        )
                                                      : ListTile(
                                                          title: RichText(
                                                            text: new TextSpan(
                                                              style:
                                                                  new TextStyle(
                                                                fontSize: 20.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                  text:
                                                                      'Order Id: ',
                                                                ),
                                                                new TextSpan(
                                                                    text: course[
                                                                        "order id"]),
                                                              ],
                                                            ),
                                                          ),
                                                          subtitle: RichText(
                                                            text: new TextSpan(
                                                              style:
                                                                  new TextStyle(
                                                                fontSize: 18.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                    text:
                                                                        'Price: ',
                                                                    style:
                                                                        new TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                    )),
                                                                new TextSpan(
                                                                    text: course[
                                                                            "price"]
                                                                        .toString()),
                                                              ],
                                                            ),
                                                          ),
                                                          leading: Image.asset(
                                                              imgList[0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                          trailing: Image.asset(
                                                              imgList[0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                        ),
                                                  status == "In Progress"
                                                      ? SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets.only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          00.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                                  child:
                                                                      RaisedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      print(
                                                                          "Call");
                                                                      print(Firestore
                                                                          .instance
                                                                          .collection(
                                                                              'users')
                                                                          .document(course[
                                                                              "user id"])
                                                                          .get()
                                                                          .then((value) =>
                                                                              _makingPhoneCall(value["phone no"].toString())));
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "Call",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0),
                                                                    ),
                                                                    color: Colors
                                                                        .lightBlueAccent,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
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
                                                                      bottom:
                                                                          00.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                                  child:
                                                                      RaisedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            print("Gives a platform to chat with customer");
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => ChatPage(placedOrderId: course.documentID, userId: uid)),
                                                                            );
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            "Chat",
                                                                            style:
                                                                                TextStyle(fontSize: 15.0),
                                                                          ),
                                                                          color: Colors
                                                                              .lightBlueAccent,
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(30.0),
                                                                              side: BorderSide(color: Colors.blue, width: 2))),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          00.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                                  child:
                                                                      RaisedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.push(
                                                                          context,
                                                                          //builder of MaterialPageRoute will call TodoDetail class
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                CustomerInProgressOrderDetails(
                                                                              uid: uid,
                                                                              wspId: course["wsp id"],
                                                                              orderId: course["order id"],
                                                                            ),
                                                                          ));
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "Order Details",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15.0),
                                                                    ),
                                                                    color: Colors
                                                                        .lightBlueAccent,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                30.0),
                                                                        side: BorderSide(
                                                                            color:
                                                                                Colors.blue,
                                                                            width: 2)),
                                                                  ),
                                                                ),
                                                              ]),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  bottom: 00.0,
                                                                  left: 20.0,
                                                                  right: 10.0),
                                                          child: RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          CustomerCompletedOrderDetails(
                                                                            uid:
                                                                                uid,
                                                                            wspId:
                                                                                course["wsp id"],
                                                                            orderId:
                                                                                course["order id"],
                                                                          )));
                                                            },
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
                                                        )
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
                              Image.asset(imgList[0],
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
                                  child: Text("No orders in progress yet!",
                                      style: TextStyle(fontSize: 15.0)))
                            ]));
                      }
                    })));
      }
    } else {
      return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              appBar: AppBar(
                title: Text("Orders (" + status + " )"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      FirebaseAuth auth = FirebaseAuth.instance;
                      auth.signOut().then((res) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      });
                    },
                  )
                ],
              ),
              // body: Center(
              //     child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //       Padding(
              //         padding: EdgeInsets.only(
              //             top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
              //         child: Text("Filter",
              //             style: TextStyle(fontSize: 16.0, color: Colors.white)),
              //       ),
              body: Column(children: [
                Container(
                  width:
                      0.98 * MediaQuery.of(context).size.width.roundToDouble(),
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
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white)),
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
                          )),
                    ]),
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: Column(children: [
                      Image.asset(noOrderImage,
                          width: 0.8 *
                              MediaQuery.of(context).size.width.roundToDouble(),
                          height: 0.3 *
                              MediaQuery.of(context)
                                  .size
                                  .height
                                  .roundToDouble(),
                          fit: BoxFit.cover),
                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Orders are in progress yet!",
                              style: TextStyle(fontSize: 14.0)))
                    ]))
              ])));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
