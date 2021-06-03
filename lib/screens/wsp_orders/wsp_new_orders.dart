import 'package:workforce/utils/images_and_Labels.dart';
import 'package:workforce/main.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' show cos, sqrt, asin;


class Orders extends StatefulWidget {
  Orders({this.uid, this.role, this.flag});
  final String uid;
  final bool flag;
  final String role;
  @override
  State<StatefulWidget> createState() => OrdersState(uid, role, flag);
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
    'Time Window (Max to Min)'
  ];
  bool flag = false;
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
  OrdersState(String uid, String role, bool flag) {
    this.uid = uid;
    this.flag = flag;
    this.role = role;
  }
  int selectedIndex = 2;
  bool checkDistance(
      double orderlatitude, double orderLongitude, var orderDistance) {
    print(calculateDistance(
        orderlatitude, orderLongitude, wsp_latitude, wsp_longitude));

    print(orderDistance);

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

    for (var i = 0; i < _images.length; i += 2) {
      if (i + 1 >= _images.length) {
        list.add(Row(children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.5,
                          color: Colors.black12,
                        ),
                      ),
                      child: Image.network(_images[i],
                          width: 100, height: 100, fit: BoxFit.fill))))
        ]));
      } else {
        list.add(Row(children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.5,
                          color: Colors.black12,
                        ),
                      ),
                      child: Image.network(_images[i],
                          width: 100, height: 100, fit: BoxFit.fill)))),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.5,
                          color: Colors.black12,
                        ),
                      ),
                      child: Image.network(_images[i + 1],
                          width: 100, height: 100, fit: BoxFit.fill))))
        ]));
      }
    }
    ;

    return new Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    if (filter == 'No filter') {
      return WillPopScope(
        onWillPop: () async => false,
        child:Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
                      child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
                ]);
              } else {
                return Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
              // }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    } else if (filter == 'Oldest Orders To Latest Orders') {
      return WillPopScope(
        onWillPop: () async => false,
        child:Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
                ]);
              } else {
                return Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    } else if (filter == 'Latest Orders To Oldest Orders') {
      return WillPopScope(
        onWillPop: () async => false,
        child:Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
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
                            MediaQuery.of(context).size.height.roundToDouble(),
                        fit: BoxFit.cover,
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    } else if (filter == 'Price (Low To High)') {
      return WillPopScope(
        onWillPop: () async => false,
        child:Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
                ]);
              } else {
                return Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Image.asset(
                       noOrderImage,
                        fit: BoxFit.cover,
                        width: 0.8 *
                            MediaQuery.of(context).size.width.roundToDouble(),
                        height: 0.3 *
                            MediaQuery.of(context).size.height.roundToDouble(),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    } else if (filter == 'Price (High To Low)') {
      return WillPopScope(
        onWillPop: () async => false,
        child:Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
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
                            MediaQuery.of(context).size.height.roundToDouble(),
                        fit: BoxFit.cover,
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    } else if (filter == 'Distance (Close To Far)') {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
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
                            MediaQuery.of(context).size.height.roundToDouble(),
                        fit: BoxFit.cover,
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    } else if (filter == 'Service Date And Time (Asc)') {
      return WillPopScope(
        onWillPop: () async => false,
        child:Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
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
                            MediaQuery.of(context).size.height.roundToDouble(),
                        fit: BoxFit.cover,
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    } else if (filter == 'Service Date And Time (Dsc)') {
      return WillPopScope(
        onWillPop: () async => false,
        child:Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
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
                            MediaQuery.of(context).size.height.roundToDouble(),
                        fit: BoxFit.cover,
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    } else if (filter == 'Time Window (Min to Max)') {
      return WillPopScope(
        onWillPop: () async => false,
        child:Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
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
                            MediaQuery.of(context).size.height.roundToDouble(),
                        fit: BoxFit.cover,
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    } else if (filter == 'Time Window (Max to Min)') {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
        appBar: AppBar(title: Text("Order Requests" + " ( " + role + " )"),
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
            ],),
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
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return Column(children: [
                  Container(
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    color: Colors.black,
                    margin: const EdgeInsets.all(20.0),
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                    child: Center(
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
                                  return new CircularProgressIndicator();
                                default:
                                  {
                                    if (!snapshot.hasData)
                                      return Text("Loading orders...");
                                    else if (snapshot.data.documents[index]
                                            ["user id"] ==
                                        uid)
                                      return Container(width: 0.0, height: 0.0);
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              // style: new TextStyle(
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold)
                                                            ),
                                                            new TextSpan(
                                                                text: course[
                                                                    "title"]),
                                                          ],
                                                        ),
                                                      ),
                                                      subtitle: RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Price: ',
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
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["service date and time"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                            new TextSpan(
                                                                text:
                                                                    "\nTime Window: ",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                )),
                                                            new TextSpan(
                                                                text: DateTime.fromMicrosecondsSinceEpoch(
                                                                        course["time window"]
                                                                            .microsecondsSinceEpoch)
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                      leading: course["photos"] !=
                                                              null
                                                          ? Image.network(
                                                              course["photos"]
                                                                  [0],
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                      trailing: course["photos"] !=
                                                                  null &&
                                                              course["photos"]
                                                                      .length >
                                                                  1
                                                          ? Image.network(
                                                              course[
                                                                  "photos"][1],
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill)
                                                          : Image.asset(
                                                              "images/no_orders.jpg",
                                                              width: 0.2 *
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width
                                                                      .roundToDouble(),
                                                              height: 100,
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Center(
                                                      child:
                                                          SingleChildScrollView(
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
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "REMOVE from feed and move to confirmations sent page/tab.");
                                                                  await _asyncSimpleDialog(
                                                                      context,
                                                                      course
                                                                          .documentID,
                                                                      calculateDistance(
                                                                          course[
                                                                              "latitude"],
                                                                          course[
                                                                              "longitude"],
                                                                          wsp_latitude,
                                                                          wsp_longitude),
                                                                      course);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Accept",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color: Colors
                                                                    .green,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          0.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          10.0),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Remove from feed!");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "orders")
                                                                      .document(
                                                                          course
                                                                              .documentID)
                                                                      .collection(
                                                                          "responses")
                                                                      .document(
                                                                          uid)
                                                                      .setData({
                                                                    "wsp response":
                                                                        "rejected",
                                                                  });

                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "rejected responses")
                                                                      .add({
                                                                    "wsp id":
                                                                        uid,
                                                                    "order id":
                                                                        course
                                                                            .documentID,
                                                                    "date time":
                                                                        DateTime
                                                                            .now()
                                                                  }).then(
                                                                          (res) {
                                                                    isLoading =
                                                                        false;
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            content:
                                                                                Text("Rejected Order"),
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

                                                                    setState(
                                                                        () {});
                                                                  }).catchError(
                                                                          (err) {
                                                                    print(err
                                                                        .message);
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text("Error"),
                                                                            content:
                                                                                Text(err.message),
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
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Reject",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                                color:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .red
                                                                            .shade600,
                                                                        width:
                                                                            2)),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ]));
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
                          })),
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
                            MediaQuery.of(context).size.height.roundToDouble(),
                        fit: BoxFit.cover,
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("No orders yet!",
                              style: TextStyle(fontSize: 15.0)))
                    ]));
              }
            }),
        bottomNavigationBar: Visibility(
            visible: flag == true,
            child: FFNavigationBar(
              theme: FFNavigationBarTheme(
                barBackgroundColor: Colors.blue,
                unselectedItemLabelColor: Colors.white,
                unselectedItemIconColor: Colors.white,
                selectedItemBorderColor: Colors.blue,
                selectedItemBackgroundColor: Colors.white,
                selectedItemIconColor: Colors.blue,
                selectedItemLabelColor: Colors.white,
                showSelectedItemShadow: false,
                barHeight: 60,
              ),
              selectedIndex: selectedIndex,
              onSelectTab: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                FFNavigationBarItem(
                  iconData: Icons.home_outlined,
                  label: 'Home',
                ),
                FFNavigationBarItem(
                  iconData: Icons.timer,
                  label: 'Status',
                ),
                FFNavigationBarItem(
                  iconData: Icons.shopping_cart_outlined,
                  label: 'New ',
                ),
                FFNavigationBarItem(
                  iconData: Icons.hourglass_top_outlined,
                  label: 'Progress',
                ),
                FFNavigationBarItem(
                  iconData: Icons.check_circle_outline,
                  label: 'Done',
                ),
              ],
            )),)
      );
    }
  }

  Future _asyncSimpleDialog(BuildContext context, String orderId,
      double distance, DocumentSnapshot course) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Send Acceptance '),
            children: <Widget>[
              SimpleDialogOption(
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                      Row(children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Price',
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 10.0,
                                bottom: 10.0,
                                left: 20.0,
                                right: 20.0),
                            child: TextFormField(
                              controller: priceController,
                              decoration: InputDecoration(
                                labelText: "Price",
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
                        ),
                      ]),
                      Row(children: [
                        Icon(
                          Icons.description_outlined,
                          color: Colors.blue,
                          size: 30.0,
                          semanticLabel: 'Description',
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 10.0,
                                bottom: 10.0,
                                left: 20.0,
                                right: 20.0),
                            child: TextFormField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                labelText: "Description (Optional)",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                      ]),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : RaisedButton(
                                color: Colors.lightBlueAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    side: BorderSide(
                                        color: Colors.blue, width: 2)),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    sendMessage(orderId, distance, course);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('Reply'),
                              ),
                      )
                    ]))),
              ),
            ],
          );
        });
  }

  void sendMessage(String orderId, double distance, DocumentSnapshot course) {
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
      "distance": distance,
      "title": course["title"],
      "photos": course["photos"],
      "price_by_customer": course["price"]
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
