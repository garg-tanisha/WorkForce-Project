import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderResponses extends StatefulWidget {
  OrderResponses({this.uid, this.orderId});
  final String uid;
  final String orderId;
  @override
  State<StatefulWidget> createState() => OrderResponsesState(uid, orderId);
}

String noOrderImage = "images/no_orders.jpg";

class OrderResponsesState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String uid;
  String orderId;
  final List<Map<dynamic, dynamic>> lists = [];
  final sentiment = Sentiment();
  double averageWSPRating = 0;
  OrderResponsesState(String uid, String orderId) {
    this.uid = uid;
    this.orderId = orderId;
  }

  _onDropDownChanged(String value) {
    setState(() {
      this.filter = value;
    });
  }

  final filters = [
    'No Filter',
    'Ratings (Low To High)',
    'Ratings (High To Low)',
    'Price (Min To Max)',
    'Price (Max To Min)',
    'Response (Oldest to Latest)',
    'Response (Latest to Oldest)'
  ];

  String filter = 'No Filter';

  double calculateAverageRating() {
    int totalCompletedOrders = 0;

    double totalRating = 0;
    Firestore.instance
        .collection('accepted responses')
        .where("order id", isEqualTo: orderId)
        .where("customer response", isEqualTo: "None")
        .getDocuments()
        .then((doc) {
      print(doc.documents.length);
      totalCompletedOrders = doc.documents.length;

      for (var order in doc.documents) {
        if (order["ratings"] != null) {
          totalRating += int.parse(order["ratings"]);
        }
      }
      Firestore.instance
          .collection('accepted responses')
          .where("order id", isEqualTo: orderId)
          .where("customer response", isEqualTo: "None")
          .where("ratings", isNull: true)
          .getDocuments()
          .then((doc) {
        print(doc.documents.length);
        totalCompletedOrders -= doc.documents.length;
      });

      double averageRating = ((totalRating * 5) / totalCompletedOrders);
      print(averageRating);

      averageWSPRating = averageRating;
      return averageRating;
    });
    return averageWSPRating;
  }

  bool recommendation(DocumentSnapshot course) {
    if (course["ratings"] == null || course["ratings"] < averageWSPRating)
      return false;

    //calculate average rating of all the service providers and use it for comparing
    else if (course["ratings"] >= averageWSPRating) {
      Firestore.instance
          .collection("placed orders")
          .where("wsp id", isEqualTo: course["wsp id"])
          .where("status", isEqualTo: "Completed")
          .getDocuments()
          .then((doc) {
        int positiveFeedback = 0, negativeFeedback = 0;
        for (var order in doc.documents) {
          if (order["feedback"] != null) {
            //use text mining and percentage for the same
            var analysedFeedback =
                sentiment.analysis(order["feedback"], emoji: true);

            if ((analysedFeedback["good words"].length >
                    analysedFeedback["badword"].length) &&
                analysedFeedback["comparitive"] > 0) {
              positiveFeedback++;
            } else
              negativeFeedback++;
          }
        }

        if ((positiveFeedback / (positiveFeedback + negativeFeedback) * 100) <
            75)
          return false;
        else
          return true;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (filter == 'No Filter') {
      return Scaffold(
          appBar: AppBar(
            title: Text("Responses Recieved"),
            // leading: IconButton(
            //     icon: const Icon(
            //       Icons.arrow_left_outlined,
            //       color: Colors.white,
            //       size: 30.0,
            //       semanticLabel: 'Camera',
            //     ),
            //     tooltip: 'Click to go to previous page',
            //     onPressed: () {
            //       Navigator.pop(context);
            //     }),
          ),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("ratings", descending: true)
                  .orderBy("price", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  calculateAverageRating();

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
                                                ListTile(
                                                  leading: Image.asset(
                                                      noOrderImage,
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: recommendation(
                                                          course)
                                                      ? Image.asset(
                                                          "images/recommended.jpg",
                                                          width: 0.2 *
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                                  .roundToDouble(),
                                                          height: 50,
                                                          fit: BoxFit.fill)
                                                      : Container(
                                                          width: 0.0,
                                                          height: 0.0),
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
                                                            text: "\nRatings: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["ratings"] !=
                                                                null
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "ratings"])
                                                            : new TextSpan(
                                                                text: "N/A"),
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
                                                        new TextSpan(
                                                            text:
                                                                "\nDescription: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["description"] !=
                                                                ""
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "description"])
                                                            : new TextSpan(
                                                                text: "N/A"),
                                                      ],
                                                    ),
                                                  ),
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
                                                                top: 0.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            CollectionReference
                                                                ref = Firestore
                                                                    .instance
                                                                    .collection(
                                                                        'accepted responses');

                                                            QuerySnapshot
                                                                eventsQuery =
                                                                await ref
                                                                    .where(
                                                                        'order id',
                                                                        isEqualTo:
                                                                            orderId)
                                                                    .getDocuments();

                                                            eventsQuery
                                                                .documents
                                                                .forEach(
                                                                    (msgDoc) {
                                                              msgDoc.reference
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "accepted responses")
                                                                .document(course
                                                                    .documentID)
                                                                .updateData({
                                                              "customer response":
                                                                  "accepted",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "orders")
                                                                .document(course[
                                                                    "order id"])
                                                                .updateData({
                                                              "status":
                                                                  "In Progress",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "placed orders")
                                                                .add({
                                                              "wsp id": course[
                                                                  "wsp id"],
                                                              "status":
                                                                  "In Progress",
                                                              "order id": course[
                                                                  "order id"],
                                                              "description": course[
                                                                  "description"],
                                                              "user id": uid,
                                                              "price": course[
                                                                  "price"],
                                                              "service type":
                                                                  course[
                                                                      "role"],
                                                              "distance": course[
                                                                  "distance"],
                                                              "title": course[
                                                                  "title"],
                                                              "photos": course[
                                                                  "photos"],
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Accept",
                                                            style: TextStyle(
                                                                fontSize: 15.0),
                                                          ),
                                                          color: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                  width: 2)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 00.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "Reject the response and remove it from the feed");
                                                              Firestore.instance
                                                                  .collection(
                                                                      "accepted responses")
                                                                  .document(course
                                                                      .documentID)
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });

                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                              "Reject",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
                                                            ),
                                                            color: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red
                                                                        .shade600,
                                                                    width: 2))),
                                                      ),
                                                    ],
                                                  ),
                                                )
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
                            child: Text("No responses yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    } else if (filter == 'Ratings (Low To High)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("ratings")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  calculateAverageRating();

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
                                                ListTile(
                                                  leading: Image.asset(
                                                      noOrderImage,
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: recommendation(
                                                          course)
                                                      ? Image.asset(
                                                          "images/recommended.jpg",
                                                          width: 0.2 *
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                                  .roundToDouble(),
                                                          height: 50,
                                                          fit: BoxFit.fill)
                                                      : Container(
                                                          width: 0.0,
                                                          height: 0.0),
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
                                                            text: "\nRatings: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["ratings"] !=
                                                                null
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "ratings"])
                                                            : new TextSpan(
                                                                text: "N/A"),
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
                                                        new TextSpan(
                                                            text:
                                                                "\nDescription: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["description"] !=
                                                                ""
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "description"])
                                                            : new TextSpan(
                                                                text: "N/A"),
                                                      ],
                                                    ),
                                                  ),
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
                                                                top: 0.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            CollectionReference
                                                                ref = Firestore
                                                                    .instance
                                                                    .collection(
                                                                        'accepted responses');

                                                            QuerySnapshot
                                                                eventsQuery =
                                                                await ref
                                                                    .where(
                                                                        'order id',
                                                                        isEqualTo:
                                                                            orderId)
                                                                    .getDocuments();

                                                            eventsQuery
                                                                .documents
                                                                .forEach(
                                                                    (msgDoc) {
                                                              msgDoc.reference
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "accepted responses")
                                                                .document(course
                                                                    .documentID)
                                                                .updateData({
                                                              "customer response":
                                                                  "accepted",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "orders")
                                                                .document(course[
                                                                    "order id"])
                                                                .updateData({
                                                              "status":
                                                                  "In Progress",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "placed orders")
                                                                .add({
                                                              "wsp id": course[
                                                                  "wsp id"],
                                                              "status":
                                                                  "In Progress",
                                                              "order id": course[
                                                                  "order id"],
                                                              "description": course[
                                                                  "description"],
                                                              "user id": uid,
                                                              "price": course[
                                                                  "price"],
                                                              "service type":
                                                                  course[
                                                                      "role"],
                                                              "distance": course[
                                                                  "distance"],
                                                              "title": course[
                                                                  "title"],
                                                              "photos": course[
                                                                  "photos"]
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Accept",
                                                            style: TextStyle(
                                                                fontSize: 15.0),
                                                          ),
                                                          color: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                  width: 2)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 00.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "Reject the response and remove it from the feed");
                                                              Firestore.instance
                                                                  .collection(
                                                                      "accepted responses")
                                                                  .document(course
                                                                      .documentID)
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });

                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                              "Reject",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
                                                            ),
                                                            color: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red
                                                                        .shade600,
                                                                    width: 2))),
                                                      ),
                                                    ],
                                                  ),
                                                )
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
                            child: Text("No responses yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    } else if (filter == 'Ratings (High To Low)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("ratings", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  calculateAverageRating();
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
                                                ListTile(
                                                  leading: Image.asset(
                                                      noOrderImage,
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: recommendation(
                                                          course)
                                                      ? Image.asset(
                                                          "images/recommended.jpg",
                                                          width: 0.2 *
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                                  .roundToDouble(),
                                                          height: 50,
                                                          fit: BoxFit.fill)
                                                      : Container(
                                                          width: 0.0,
                                                          height: 0.0),
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
                                                            text: "\nRatings: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["ratings"] !=
                                                                null
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "ratings"])
                                                            : new TextSpan(
                                                                text: "N/A"),
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
                                                        new TextSpan(
                                                            text:
                                                                "\nDescription: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["description"] !=
                                                                ""
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "description"])
                                                            : new TextSpan(
                                                                text: "N/A"),
                                                      ],
                                                    ),
                                                  ),
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
                                                                top: 0.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            CollectionReference
                                                                ref = Firestore
                                                                    .instance
                                                                    .collection(
                                                                        'accepted responses');

                                                            QuerySnapshot
                                                                eventsQuery =
                                                                await ref
                                                                    .where(
                                                                        'order id',
                                                                        isEqualTo:
                                                                            orderId)
                                                                    .getDocuments();

                                                            eventsQuery
                                                                .documents
                                                                .forEach(
                                                                    (msgDoc) {
                                                              msgDoc.reference
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "accepted responses")
                                                                .document(course
                                                                    .documentID)
                                                                .updateData({
                                                              "customer response":
                                                                  "accepted",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "orders")
                                                                .document(course[
                                                                    "order id"])
                                                                .updateData({
                                                              "status":
                                                                  "In Progress",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "placed orders")
                                                                .add({
                                                              "wsp id": course[
                                                                  "wsp id"],
                                                              "status":
                                                                  "In Progress",
                                                              "order id": course[
                                                                  "order id"],
                                                              "description": course[
                                                                  "description"],
                                                              "user id": uid,
                                                              "price": course[
                                                                  "price"],
                                                              "service type":
                                                                  course[
                                                                      "role"],
                                                              "distance": course[
                                                                  "distance"],
                                                              "title": course[
                                                                  "title"],
                                                              "photos": course[
                                                                  "photos"]
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Accept",
                                                            style: TextStyle(
                                                                fontSize: 15.0),
                                                          ),
                                                          color: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                  width: 2)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 00.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "Reject the response and remove it from the feed");
                                                              Firestore.instance
                                                                  .collection(
                                                                      "accepted responses")
                                                                  .document(course
                                                                      .documentID)
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });

                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                              "Reject",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
                                                            ),
                                                            color: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red
                                                                        .shade600,
                                                                    width: 2))),
                                                      ),
                                                    ],
                                                  ),
                                                )
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
                            child: Text("No responses yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    } else if (filter == 'Price (Min To Max)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("price")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  calculateAverageRating();

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
                                                ListTile(
                                                  leading: Image.asset(
                                                      noOrderImage,
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: recommendation(
                                                          course)
                                                      ? Image.asset(
                                                          "images/recommended.jpg",
                                                          width: 0.2 *
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                                  .roundToDouble(),
                                                          height: 50,
                                                          fit: BoxFit.fill)
                                                      : Container(
                                                          width: 0.0,
                                                          height: 0.0),
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
                                                            text: "\nRatings: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["ratings"] !=
                                                                null
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "ratings"])
                                                            : new TextSpan(
                                                                text: "N/A"),
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
                                                        new TextSpan(
                                                            text:
                                                                "\nDescription: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["description"] !=
                                                                ""
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "description"])
                                                            : new TextSpan(
                                                                text: "N/A"),
                                                      ],
                                                    ),
                                                  ),
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
                                                                top: 0.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            CollectionReference
                                                                ref = Firestore
                                                                    .instance
                                                                    .collection(
                                                                        'accepted responses');

                                                            QuerySnapshot
                                                                eventsQuery =
                                                                await ref
                                                                    .where(
                                                                        'order id',
                                                                        isEqualTo:
                                                                            orderId)
                                                                    .getDocuments();

                                                            eventsQuery
                                                                .documents
                                                                .forEach(
                                                                    (msgDoc) {
                                                              msgDoc.reference
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "accepted responses")
                                                                .document(course
                                                                    .documentID)
                                                                .updateData({
                                                              "customer response":
                                                                  "accepted",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "orders")
                                                                .document(course[
                                                                    "order id"])
                                                                .updateData({
                                                              "status":
                                                                  "In Progress",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "placed orders")
                                                                .add({
                                                              "wsp id": course[
                                                                  "wsp id"],
                                                              "status":
                                                                  "In Progress",
                                                              "order id": course[
                                                                  "order id"],
                                                              "description": course[
                                                                  "description"],
                                                              "user id": uid,
                                                              "price": course[
                                                                  "price"],
                                                              "service type":
                                                                  course[
                                                                      "role"],
                                                              "distance": course[
                                                                  "distance"],
                                                              "title": course[
                                                                  "title"],
                                                              "photos": course[
                                                                  "photos"]
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Accept",
                                                            style: TextStyle(
                                                                fontSize: 15.0),
                                                          ),
                                                          color: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                  width: 2)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 00.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "Reject the response and remove it from the feed");
                                                              Firestore.instance
                                                                  .collection(
                                                                      "accepted responses")
                                                                  .document(course
                                                                      .documentID)
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });

                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                              "Reject",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
                                                            ),
                                                            color: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red
                                                                        .shade600,
                                                                    width: 2))),
                                                      ),
                                                    ],
                                                  ),
                                                )
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
                            child: Text("No responses yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    } else if (filter == 'Price (Max To Min)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("price", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  calculateAverageRating();

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
                                                ListTile(
                                                  leading: Image.asset(
                                                      noOrderImage,
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: recommendation(
                                                          course)
                                                      ? Image.asset(
                                                          "images/recommended.jpg",
                                                          width: 0.2 *
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                                  .roundToDouble(),
                                                          height: 50,
                                                          fit: BoxFit.fill)
                                                      : Container(
                                                          width: 0.0,
                                                          height: 0.0),
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
                                                            text: "\nRatings: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["ratings"] !=
                                                                null
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "ratings"])
                                                            : new TextSpan(
                                                                text: "N/A"),
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
                                                        new TextSpan(
                                                            text:
                                                                "\nDescription: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["description"] !=
                                                                ""
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "description"])
                                                            : new TextSpan(
                                                                text: "N/A"),
                                                      ],
                                                    ),
                                                  ),
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
                                                                top: 0.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            CollectionReference
                                                                ref = Firestore
                                                                    .instance
                                                                    .collection(
                                                                        'accepted responses');

                                                            QuerySnapshot
                                                                eventsQuery =
                                                                await ref
                                                                    .where(
                                                                        'order id',
                                                                        isEqualTo:
                                                                            orderId)
                                                                    .getDocuments();

                                                            eventsQuery
                                                                .documents
                                                                .forEach(
                                                                    (msgDoc) {
                                                              msgDoc.reference
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "accepted responses")
                                                                .document(course
                                                                    .documentID)
                                                                .updateData({
                                                              "customer response":
                                                                  "accepted",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "orders")
                                                                .document(course[
                                                                    "order id"])
                                                                .updateData({
                                                              "status":
                                                                  "In Progress",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "placed orders")
                                                                .add({
                                                              "wsp id": course[
                                                                  "wsp id"],
                                                              "status":
                                                                  "In Progress",
                                                              "order id": course[
                                                                  "order id"],
                                                              "description": course[
                                                                  "description"],
                                                              "user id": uid,
                                                              "price": course[
                                                                  "price"],
                                                              "service type":
                                                                  course[
                                                                      "role"],
                                                              "distance": course[
                                                                  "distance"],
                                                              "title": course[
                                                                  "title"],
                                                              "photos": course[
                                                                  "photos"]
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Accept",
                                                            style: TextStyle(
                                                                fontSize: 15.0),
                                                          ),
                                                          color: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                  width: 2)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 00.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "Reject the response and remove it from the feed");
                                                              Firestore.instance
                                                                  .collection(
                                                                      "accepted responses")
                                                                  .document(course
                                                                      .documentID)
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });

                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                              "Reject",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
                                                            ),
                                                            color: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red
                                                                        .shade600,
                                                                    width: 2))),
                                                      ),
                                                    ],
                                                  ),
                                                )
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
                            child: Text("No responses yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    } else if (filter == 'Response (Oldest to Latest)') {
      return Scaffold(
          appBar: AppBar(title: Text("Responses Recieved")),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("date time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  calculateAverageRating();

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
                                                ListTile(
                                                  leading: Image.asset(
                                                    noOrderImage,
                                                  ),
                                                  trailing: recommendation(
                                                          course)
                                                      ? Image.asset(
                                                          "images/recommended.jpg",
                                                          width: 0.2 *
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                                  .roundToDouble(),
                                                          height: 50,
                                                          fit: BoxFit.fill)
                                                      : Container(
                                                          width: 0.0,
                                                          height: 0.0),
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
                                                            text: "\nRatings: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["ratings"] !=
                                                                null
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "ratings"])
                                                            : new TextSpan(
                                                                text: "N/A"),
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
                                                        new TextSpan(
                                                            text:
                                                                "\nDescription: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["description"] !=
                                                                ""
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "description"])
                                                            : new TextSpan(
                                                                text: "N/A"),
                                                      ],
                                                    ),
                                                  ),
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
                                                                top: 0.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            CollectionReference
                                                                ref = Firestore
                                                                    .instance
                                                                    .collection(
                                                                        'accepted responses');

                                                            QuerySnapshot
                                                                eventsQuery =
                                                                await ref
                                                                    .where(
                                                                        'order id',
                                                                        isEqualTo:
                                                                            orderId)
                                                                    .getDocuments();

                                                            eventsQuery
                                                                .documents
                                                                .forEach(
                                                                    (msgDoc) {
                                                              msgDoc.reference
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "accepted responses")
                                                                .document(course
                                                                    .documentID)
                                                                .updateData({
                                                              "customer response":
                                                                  "accepted",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "orders")
                                                                .document(course[
                                                                    "order id"])
                                                                .updateData({
                                                              "status":
                                                                  "In Progress",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "placed orders")
                                                                .add({
                                                              "wsp id": course[
                                                                  "wsp id"],
                                                              "status":
                                                                  "In Progress",
                                                              "order id": course[
                                                                  "order id"],
                                                              "description": course[
                                                                  "description"],
                                                              "user id": uid,
                                                              "price": course[
                                                                  "price"],
                                                              "service type":
                                                                  course[
                                                                      "role"],
                                                              "distance": course[
                                                                  "distance"],
                                                              "title": course[
                                                                  "title"],
                                                              "photos": course[
                                                                  "photos"]
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Accept",
                                                            style: TextStyle(
                                                                fontSize: 15.0),
                                                          ),
                                                          color: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                  width: 2)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 00.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "Reject the response and remove it from the feed");
                                                              Firestore.instance
                                                                  .collection(
                                                                      "accepted responses")
                                                                  .document(course
                                                                      .documentID)
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });

                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                              "Reject",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
                                                            ),
                                                            color: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red
                                                                        .shade600,
                                                                    width: 2))),
                                                      ),
                                                    ],
                                                  ),
                                                )
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
                            child: Text("No responses yet!",
                                style: TextStyle(fontSize: 15.0)))
                      ]));
                }
              }));
    } else if (filter == 'Response (Latest to Oldest)') {
      return Scaffold(
          appBar: AppBar(
            title: Text("Responses Recieved"),
            leading: IconButton(
                icon: const Icon(
                  Icons.arrow_left_outlined,
                  color: Colors.blue,
                  size: 30.0,
                  semanticLabel: 'Camera',
                ),
                tooltip: 'Click to go to previous page',
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('accepted responses')
                  .where("order id", isEqualTo: orderId)
                  .where("customer response", isEqualTo: "None")
                  .orderBy("date time", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.data == null ||
                    snapshot.data.documents == null)) {
                  calculateAverageRating();

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
                                                ListTile(
                                                  leading: Image.asset(
                                                      noOrderImage,
                                                      width: 0.2 *
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width
                                                              .roundToDouble(),
                                                      height: 100,
                                                      fit: BoxFit.fill),
                                                  trailing: recommendation(
                                                          course)
                                                      ? Image.asset(
                                                          "images/recommended.jpg",
                                                          width: 0.2 *
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width
                                                                  .roundToDouble(),
                                                          height: 50,
                                                          fit: BoxFit.fill)
                                                      : Container(
                                                          width: 0.0,
                                                          height: 0.0),
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
                                                            text: "\nRatings: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["ratings"] !=
                                                                null
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "ratings"])
                                                            : new TextSpan(
                                                                text: "N/A"),
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
                                                        new TextSpan(
                                                            text:
                                                                "\nDescription: ",
                                                            style:
                                                                new TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                        course["description"] !=
                                                                ""
                                                            ? new TextSpan(
                                                                text: course[
                                                                    "description"])
                                                            : new TextSpan(
                                                                text: "N/A"),
                                                      ],
                                                    ),
                                                  ),
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
                                                                top: 0.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                          onPressed: () async {
                                                            CollectionReference
                                                                ref = Firestore
                                                                    .instance
                                                                    .collection(
                                                                        'accepted responses');

                                                            QuerySnapshot
                                                                eventsQuery =
                                                                await ref
                                                                    .where(
                                                                        'order id',
                                                                        isEqualTo:
                                                                            orderId)
                                                                    .getDocuments();

                                                            eventsQuery
                                                                .documents
                                                                .forEach(
                                                                    (msgDoc) {
                                                              msgDoc.reference
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "accepted responses")
                                                                .document(course
                                                                    .documentID)
                                                                .updateData({
                                                              "customer response":
                                                                  "accepted",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "orders")
                                                                .document(course[
                                                                    "order id"])
                                                                .updateData({
                                                              "status":
                                                                  "In Progress",
                                                            });

                                                            Firestore.instance
                                                                .collection(
                                                                    "placed orders")
                                                                .add({
                                                              "wsp id": course[
                                                                  "wsp id"],
                                                              "status":
                                                                  "In Progress",
                                                              "order id": course[
                                                                  "order id"],
                                                              "description": course[
                                                                  "description"],
                                                              "user id": uid,
                                                              "price": course[
                                                                  "price"],
                                                              "service type":
                                                                  course[
                                                                      "role"],
                                                              "distance": course[
                                                                  "distance"],
                                                              "title": course[
                                                                  "title"],
                                                              "photos": course[
                                                                  "photos"]
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Accept",
                                                            style: TextStyle(
                                                                fontSize: 15.0),
                                                          ),
                                                          color: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                  width: 2)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 00.0,
                                                                bottom: 00.0,
                                                                left: 20.0,
                                                                right: 10.0),
                                                        child: RaisedButton(
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "Reject the response and remove it from the feed");
                                                              Firestore.instance
                                                                  .collection(
                                                                      "accepted responses")
                                                                  .document(course
                                                                      .documentID)
                                                                  .updateData({
                                                                "customer response":
                                                                    "rejected",
                                                              });

                                                              setState(() {});
                                                            },
                                                            child: const Text(
                                                              "Reject",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.0),
                                                            ),
                                                            color: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .red
                                                                        .shade600,
                                                                    width: 2))),
                                                      ),
                                                    ],
                                                  ),
                                                )
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
                            child: Text("No responses yet!",
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
