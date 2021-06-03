import 'package:workforce/utils/widgets/preventive_measures_for_covid_19.dart';
import 'package:workforce/utils/widgets/contact_us.dart';
import 'package:workforce/utils/images_and_Labels.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workforce/utils/methods/images.dart';

class WSPCompletedOrderDetails extends StatefulWidget {
  WSPCompletedOrderDetails({this.wspId, this.orderId, this.flag});
  // final String uid;
  final String wspId;
  final bool flag;
  final String orderId;
  @override
  State<StatefulWidget> createState() =>
      WSPCompletedOrderDetailsState(wspId, orderId, flag);
}

class WSPCompletedOrderDetailsState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool flag = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String wspId, orderId;

  WSPCompletedOrderDetailsState(String wspId, String orderId, bool flag) {
    this.wspId = wspId;
    this.flag = flag;
    this.orderId = orderId;
  }
  // int selectedIndex = 6;
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
    int imageCount = (imgList.length / 2).round();
    return Scaffold(
        appBar: AppBar(title: Text("View Order Details")),
        body: ListView(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Order Details",
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
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
                return Container(
                  width:
                      0.98 * MediaQuery.of(context).size.width.roundToDouble(),
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
                        title: RichText(
                            text: new TextSpan(
                                style: new TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
                              new TextSpan(text: 'Title: '),
                              new TextSpan(text: userDocument["title"]),
                            ])),
                        subtitle: RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: 'Order #: ',
                                  style: new TextStyle(
                                    color: Colors.black54,
                                  )),
                              new TextSpan(text: orderId),
                              new TextSpan(
                                  text: "\nService Date and Time: ",
                                  style: new TextStyle(
                                    color: Colors.black54,
                                  )),
                              new TextSpan(
                                  text: DateTime.fromMicrosecondsSinceEpoch(
                                          userDocument["service date and time"]
                                              .microsecondsSinceEpoch)
                                      .toString()),
                              new TextSpan(
                                  text: "\nPrice: ",
                                  style: new TextStyle(
                                    color: Colors.black54,
                                  )),
                              new TextSpan(
                                  text: userDocument["price"].toString()),
                              new TextSpan(
                                  text: "\nUser id: ",
                                  style: new TextStyle(
                                    color: Colors.black54,
                                  )),
                              new TextSpan(text: userDocument["user id"])
                            ],
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      userDocument["photos"] != null
                          ? images(userDocument["photos"])
                          : Container(),
                      Padding(padding: EdgeInsets.all(5.0)),
                    ],
                  ),
                );
              }),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 15.0, bottom: 10.0),
              child: Text("WSP Response Details",
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
          ),
          StreamBuilder(
              stream: Firestore.instance
                  .collection('placed orders')
                  .where("order id", isEqualTo: orderId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  return new ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
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
                                            title: RichText(
                                                text: new TextSpan(
                                                    style: new TextStyle(
                                                      fontSize: 20.0,
                                                      color: Colors.black,
                                                    ),
                                                    children: <TextSpan>[
                                                  new TextSpan(
                                                      text: 'WSP Id: '),
                                                  new TextSpan(
                                                      text: course["wsp id"])
                                                ])),
                                            subtitle: RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(
                                                      text: 'Description: ',
                                                      style: new TextStyle(
                                                        color: Colors.black54,
                                                      )),
                                                  course["description"] != ""
                                                      ? new TextSpan(
                                                          text: course[
                                                              "description"])
                                                      : new TextSpan(
                                                          text: "N/A"),
                                                  new TextSpan(
                                                      text: '\nPrice: ',
                                                      style: new TextStyle(
                                                        color: Colors.black54,
                                                      )),
                                                  new TextSpan(
                                                      text: course["price"]
                                                          .toString()),
                                                  new TextSpan(
                                                      text: "\nDistance: ",
                                                      style: new TextStyle(
                                                        color: Colors.black54,
                                                      )),
                                                  new TextSpan(
                                                      text: course["distance"]
                                                              .toStringAsFixed(
                                                                  4) +
                                                          " km"),
                                                  new TextSpan(
                                                      text:
                                                          "\nProofs Submitted: ",
                                                      style: new TextStyle(
                                                        color: Colors.black54,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(5.0)),
                                          course["proofs"] != null
                                              ? images(course["proofs"])
                                              : Container(),
                                          Padding(padding: EdgeInsets.all(5.0)),
                                        ]));
                              }
                          }
                        }
                      });
                } else {
                  return Text("Invalid order id!");
                }
              }),
          PreventiveMeasuresForCovid19(),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 10.0, right: 15.0, top: 10.0, bottom: 10.0),
              child: Text("Recommended Services",
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
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
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
