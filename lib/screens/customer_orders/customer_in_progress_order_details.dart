import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workforce/screens/chat/chat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

final List<String> imgList = [
  "images/customer_home/carpenter.jpg",
  "images/customer_home/electrician.jpg",
  "images/customer_home/mechanic.jpg",
  "images/customer_home/plumber.jpg",
  "images/customer_home/sofa_cleaning.jpg",
  "images/customer_home/women_hair_cut_and_styling.jpg",
];

List<String> listPathsLabels = [
  "Carpenter",
  "Electrician",
  "Mechanic",
  "Plumber",
  "Sofa Cleaning",
  "Women's Hair Cut and Spa"
];

class CustomerInProgressOrderDetails extends StatefulWidget {
  CustomerInProgressOrderDetails({this.uid, this.wspId, this.orderId});
  final String uid;
  final String wspId;
  final String orderId;
  @override
  State<StatefulWidget> createState() =>
      CustomerInProgressOrderDetailsState(uid, wspId, orderId);
}

class CustomerInProgressOrderDetailsState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String uid, wspId, orderId;
  CustomerInProgressOrderDetailsState(
      String uid, String wspId, String orderId) {
    this.uid = uid;
    this.wspId = wspId;
    this.orderId = orderId;
  }
  _makingPhoneCall(String phoneNo) async {
    String url = 'tel:' + phoneNo;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget images(var _images) {
    List<Widget> list = new List<Widget>();

    for (var i = 0; i < _images.length; i += 2) {
      if (i + 1 >= _images.length) {
        list.add(Row(children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Image.network(
                    _images[i],
                    width: 100,
                    height: 100,
                  )))
        ]));
      } else {
        list.add(Row(children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Image.network(
                    _images[i],
                    width: 100,
                    height: 100,
                  ))),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Image.network(
                    _images[i + 1],
                    width: 100,
                    height: 100,
                  )))
        ]));
      }
    }
    ;

    return new Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    int imageCount = (imgList.length / 2).round();
    return Scaffold(
      appBar: AppBar(title: Text("View Order Details")),
      body: ListView(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Order Details",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          ),
        ),
        StreamBuilder(
            stream: Firestore.instance
                .collection('orders')
                .document(orderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return new Text("Loading");
              }
              var userDocument = snapshot.data;
              // return Text("Title: " + userDocument["title"]);
              return Container(
                width: 0.98 * MediaQuery.of(context).size.width.roundToDouble(),
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(
                          5.0) //                 <--- border radius here
                      ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ListTile(
                      subtitle: RichText(
                        text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                                text: 'Title: ',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(text: userDocument["title"]),
                            new TextSpan(
                                text: '\nOrder #: ',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(text: orderId),
                            new TextSpan(
                                text: '\nDate Of Ordering: ',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(
                                text: DateTime.fromMicrosecondsSinceEpoch(
                                        userDocument["date time"]
                                            .microsecondsSinceEpoch)
                                    .toString()),
                            new TextSpan(
                                text: "\nService Date and Time: ",
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(
                                text: DateTime.fromMicrosecondsSinceEpoch(
                                        userDocument["service date and time"]
                                            .microsecondsSinceEpoch)
                                    .toString()),
                            new TextSpan(
                                text: "\nPrice: ",
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(text: userDocument["price"].toString())
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(5.0)),
                    userDocument["photos"] != null
                        ? images(userDocument["photos"])
                        : Container(),
                  ],
                ),
              );
            }),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
                left: 10.0, right: 10.0, top: 15.0, bottom: 10.0),
            child: Text("WSP Details",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          ),
        ),
        StreamBuilder(
            stream: Firestore.instance
                .collection('placed orders')
                .where("order id", isEqualTo: orderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!(snapshot.data == null || snapshot.data.documents == null)) {
                return new ListView.builder(
                    shrinkWrap: true,
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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
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
                                          subtitle: RichText(
                                            text: new TextSpan(
                                              style: new TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text: 'WSP Id: ',
                                                    style: new TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                new TextSpan(
                                                    text: course["wsp id"]),
                                                new TextSpan(
                                                    text: '\nDescription: ',
                                                    style: new TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                course["description"] != ""
                                                    ? new TextSpan(
                                                        text: course[
                                                            "description"])
                                                    : new TextSpan(text: "N/A"),
                                                new TextSpan(
                                                    text: '\nPrice: ',
                                                    style: new TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                new TextSpan(
                                                    text: course["price"]
                                                        .toString()),
                                                new TextSpan(
                                                    text: "\nDistance: ",
                                                    style: new TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                new TextSpan(
                                                    text: course["distance"]
                                                            .toStringAsFixed(
                                                                4) +
                                                        " km")
                                              ],
                                            ),
                                          ),
                                        ),
                                        Center(
                                            child: SingleChildScrollView(
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
                                                      print(Firestore.instance
                                                          .collection('users')
                                                          .document(
                                                              course["user id"])
                                                          .get()
                                                          .then((value) =>
                                                              _makingPhoneCall(value[
                                                                      "phone no"]
                                                                  .toString())));
                                                    },
                                                    child: const Text(
                                                      "Call",
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                    color:
                                                        Colors.lightBlueAccent,
                                                    shape:
                                                        RoundedRectangleBorder(
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
                                                              builder: (context) =>
                                                                  ChatPage(
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
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 2))),
                                                ),
                                              ]),
                                        ))
                                      ]));
                            }
                        }
                      }
                    });
              } else {
                return Text("Invalid order id!");
              }
            }),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
                left: 10.0, right: 10.0, top: 0.0, bottom: 10.0),
            child: Text("Recommended Services",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          ),
        ),
        Container(
            width: 0.98 * MediaQuery.of(context).size.width.roundToDouble(),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black12,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(
                      5.0) //                 <--- border radius here
                  ),
            ),
            padding: EdgeInsets.symmetric(vertical: 5.0),
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CarouselSlider.builder(
              options: CarouselOptions(
                aspectRatio: 2.0,
                enlargeCenterPage: false,
                viewportFraction: 1,
              ),
              itemCount: imageCount,
              itemBuilder: (context, index) {
                final int first = index * 2;
                final int second = index < imageCount - 1 ? first + 1 : null;

                return Row(
                  children: [first, second].map((idx) {
                    return idx != null
                        ? Expanded(
                            flex: 1,
                            child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Stack(children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.asset(imgList[idx],
                                        width: 500.0,
                                        height: 0.5 *
                                            MediaQuery.of(context)
                                                .size
                                                .height
                                                .roundToDouble(),
                                        fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(
                                                10.0) //                 <--- border radius here
                                            ,
                                            bottomRight: Radius.circular(
                                                10.0) //                 <--- border radius here
                                            ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Text(
                                        listPathsLabels[idx],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ])))
                        : Container();
                  }).toList(),
                );
              },
            ))
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
