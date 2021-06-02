import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

class CustomerCompletedOrderDetails extends StatefulWidget {
  CustomerCompletedOrderDetails({this.uid, this.wspId, this.orderId});
  final String uid;
  final String wspId;
  final String orderId;
  @override
  State<StatefulWidget> createState() =>
      CustomerCompletedOrderDetailsState(uid, wspId, orderId);
}

class CustomerCompletedOrderDetailsState extends State {
  final _formKey = GlobalKey<FormState>();
  final ratings = ['1', '2', '3', '4', '5'];
  String rating = '1';
  bool isLoading = false;
  bool disabledFeedbackButton = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController feedbackController = TextEditingController();
  // TextEditingController descriptionController = TextEditingController();
  String uid, wspId, orderId;

  CustomerCompletedOrderDetailsState(String uid, String wspId, String orderId) {
    this.uid = uid;
    this.wspId = wspId;
    this.orderId = orderId;
  }

  Widget images(var _images) {
    List<Widget> list = new List<Widget>();

    for (var i = 0; i < _images.length; i += 2) {
      if (i + 1 >= _images.length) {
        list.add(Row(children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Image.network(_images[i],
                      width: 100, height: 100, fit: BoxFit.fill)))
        ]));
      } else {
        list.add(Row(children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Image.network(_images[i],
                      width: 100, height: 100, fit: BoxFit.fill))),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Image.network(_images[i + 1],
                      width: 100, height: 100, fit: BoxFit.fill)))
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
                                  text: '\nDate Of Ordering: ',
                                  style: new TextStyle(
                                    color: Colors.black54,
                                  )),
                              new TextSpan(
                                  text: DateTime.fromMicrosecondsSinceEpoch(
                                          userDocument["date time"]
                                              .microsecondsSinceEpoch)
                                      .toString()),
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
                                  text: userDocument["price"].toString())
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
                                return ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      Container(
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
                                        child: ListTile(
                                          title: RichText(
                                              text: new TextSpan(
                                                  style: new TextStyle(
                                                    fontSize: 20.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                new TextSpan(text: 'WSP Id: '),
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
                                                    : new TextSpan(text: "N/A"),
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
                                                        " km")
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DateTime.now()
                                                  .difference(DateTime
                                                      .fromMicrosecondsSinceEpoch(
                                                          course["order completion time"]
                                                              .microsecondsSinceEpoch))
                                                  .inMinutes <=
                                              24 * 60
                                          ? Column(children: [
                                              Padding(
                                                  padding:
                                                      EdgeInsets.all(10.0)),
                                              Container(
                                                  width: 0.98 *
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width
                                                          .roundToDouble(),
                                                  margin: const EdgeInsets
                                                          .symmetric(
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
                                                  child: Row(children: [
                                                    Expanded(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0,
                                                                  right: 10.0,
                                                                  top: 5.0,
                                                                  bottom: 5.0),
                                                          child: Text(
                                                              "Want to reopen order? ( in 24 hours)",
                                                              style: TextStyle(
                                                                fontSize: 14.0,
                                                                // fontWeight:
                                                                //     FontWeight
                                                                //         .bold
                                                              )),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                        child: RaisedButton(
                                                            onPressed: () {
                                                              Firestore.instance
                                                                  .collection(
                                                                      "orders")
                                                                  .document(
                                                                      orderId)
                                                                  .updateData({
                                                                "status":
                                                                    "In Progress"
                                                              });

                                                              Firestore.instance
                                                                  .collection(
                                                                      "placed orders")
                                                                  .document(course
                                                                      .documentID)
                                                                  .updateData({
                                                                "status":
                                                                    "In Progress",
                                                                "feedback":
                                                                    FieldValue
                                                                        .delete(),
                                                                "rating":
                                                                    FieldValue
                                                                        .delete()
                                                              });

                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              "Reopen Order",
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
                                                                    width: 2))),
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10.0))
                                                  ]))
                                            ])
                                          : Container(width: 0.0, height: 0.0),
                                      Column(children: [
                                        Padding(padding: EdgeInsets.all(10.0)),
                                        Container(
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
                                            child: Row(children: [
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        right: 10.0,
                                                        top: 5.0,
                                                        bottom: 5.0),
                                                    child: Text(
                                                        "Want to place similar order?",
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                          // fontWeight:
                                                          //     FontWeight
                                                          //         .bold
                                                        )),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  child: RaisedButton(
                                                      onPressed: () {},
                                                      child: const Text(
                                                        "Order Again",
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
                                                  padding: EdgeInsets.only(
                                                      right: 10.0))
                                            ]))
                                      ]),
                                      course["feedback"] == null
                                          ? Column(children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10.0,
                                                      right: 10.0,
                                                      top: 15.0,
                                                      bottom: 10.0),
                                                  child: Text("Submit Feedback",
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ),
                                              Container(
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
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0),
                                                  child: Form(
                                                      key: _formKey,
                                                      child:
                                                          SingleChildScrollView(
                                                              child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 0.0,
                                                                      bottom:
                                                                          10.0,
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          20.0),
                                                              child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .feedback_outlined,
                                                                      color: Colors
                                                                          .blue,
                                                                      size:
                                                                          30.0,
                                                                      semanticLabel:
                                                                          'Feedback',
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsets.only(
                                                                            top:
                                                                                5.0,
                                                                            bottom:
                                                                                5.0,
                                                                            left:
                                                                                20.0,
                                                                            right:
                                                                                20.0),
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              feedbackController,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            labelText:
                                                                                "Feedback",
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(10.0),
                                                                            ),
                                                                          ),
                                                                          keyboardType:
                                                                              TextInputType.text,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ]),
                                                            ),
                                                            Center(
                                                              child:
                                                                  SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                    children: [
                                                                      Text(
                                                                          "Ratings",
                                                                          style:
                                                                              TextStyle(fontSize: 16.0)),
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                15.0,
                                                                            top:
                                                                                5.0,
                                                                            bottom:
                                                                                5.0),
                                                                        child: DropdownButton<
                                                                            String>(
                                                                          //create an array of strings
                                                                          items:
                                                                              ratings.map((String value) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: value,
                                                                              child: Text(value),
                                                                            );
                                                                          }).toList(),
                                                                          //value property
                                                                          value:
                                                                              rating,
                                                                          //without it nothing will be updated
                                                                          onChanged:
                                                                              (String value) {
                                                                            _onDropDownChanged(value);
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5.0),
                                                              child: isLoading
                                                                  ? CircularProgressIndicator()
                                                                  : RaisedButton(
                                                                      color: Colors
                                                                          .lightBlueAccent,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              30.0),
                                                                          side: BorderSide(
                                                                              color: Colors.blue,
                                                                              width: 2)),
                                                                      onPressed:
                                                                          () {
                                                                        if (_formKey
                                                                            .currentState
                                                                            .validate()) {
                                                                          setState(
                                                                              () {
                                                                            isLoading =
                                                                                true;
                                                                          });
                                                                          submitFeedback(
                                                                              orderId,
                                                                              course.documentID,
                                                                              course["wsp id"],
                                                                              course["service type"]);
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                          'Submit'),
                                                                    ),
                                                            )
                                                          ]))))
                                            ])
                                          : Column(children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10.0,
                                                      right: 10.0,
                                                      top: 15.0,
                                                      bottom: 10.0),
                                                  child: Text(
                                                      "Recommended Services",
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ),
                                              Container(
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
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0),
                                                  child: CarouselSlider.builder(
                                                    options: CarouselOptions(
                                                      aspectRatio: 2.0,
                                                      enlargeCenterPage: false,
                                                      viewportFraction: 1,
                                                    ),
                                                    itemCount: imageCount,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final int first =
                                                          index * 2;
                                                      final int second =
                                                          index < imageCount - 1
                                                              ? first + 1
                                                              : null;

                                                      return Row(
                                                        children: [
                                                          first,
                                                          second
                                                        ].map((idx) {
                                                          return idx != null
                                                              ? Expanded(
                                                                  flex: 1,
                                                                  child: Container(
                                                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                                                      child: Stack(children: <Widget>[
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                          child: Image.asset(
                                                                              imgList[idx],
                                                                              width: 500.0,
                                                                              height: 0.5 * MediaQuery.of(context).size.height.roundToDouble(),
                                                                              fit: BoxFit.cover),
                                                                        ),
                                                                        Positioned(
                                                                          bottom:
                                                                              0.0,
                                                                          left:
                                                                              0.0,
                                                                          right:
                                                                              0.0,
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                60.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.black,
                                                                              border: Border.all(
                                                                                color: Colors.black,
                                                                              ),
                                                                              borderRadius: BorderRadius.only(
                                                                                  bottomLeft: Radius.circular(10.0) //                 <--- border radius here
                                                                                  ,
                                                                                  bottomRight: Radius.circular(10.0) //                 <--- border radius here
                                                                                  ),
                                                                            ),
                                                                            padding:
                                                                                EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                                                            child:
                                                                                Text(
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
                                                  )),
                                            ])
                                    ]);
                              }
                          }
                        }
                      });
                } else {
                  return Text("Invalid order id!");
                }
              }),
        ]));
  }

  void submitFeedback(
      String orderId, String placedOrderId, String wspId, String role) {
    debugPrint("Success");
    Firestore.instance
        .collection("placed orders")
        .document(placedOrderId)
        .updateData({
      "feedback": feedbackController.text,
      "rating": int.parse(rating),
    }).then((res) {
      isLoading = false;

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Sent Feedback"),
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
      disabledFeedbackButton = true;

      //update ratings
      int totalCompletedOrders;
      double totalRating = 0;

      Firestore.instance
          .collection("placed orders")
          .where("wsp id", isEqualTo: wspId)
          .where("status", isEqualTo: "Completed")
          .getDocuments()
          .then((doc) {
        print(doc.documents.length);
        totalCompletedOrders = doc.documents.length;

        for (var order in doc.documents) {
          if (order["feedback"] != null) {
            totalRating += int.parse(order["rating"]);
          }
        }
        Firestore.instance
            .collection("placed orders")
            .where("wsp id", isEqualTo: wspId)
            .where("status", isEqualTo: "Completed")
            .where("feedback", isNull: true)
            .getDocuments()
            .then((doc) {
          print(doc.documents.length);
          totalCompletedOrders -= doc.documents.length;
        });

        totalRating /= totalCompletedOrders;
        print(totalRating);

        if (totalCompletedOrders != null && totalCompletedOrders >= 5) {
          //extract rating
          Firestore.instance
              .collection("users")
              .document(wspId)
              .get()
              .then((result) {
            Map roleChoices = result["roles"];
            print(roleChoices);
            roleChoices[role] = totalRating.toString();
            print(roleChoices);

            //update rating
            Firestore.instance
                .collection("users")
                .document(wspId)
                .updateData({"roles": roleChoices});
          });
        }
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
  }

  _onDropDownChanged(String value) {
    setState(() {
      this.rating = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    feedbackController.dispose();
  }
}
