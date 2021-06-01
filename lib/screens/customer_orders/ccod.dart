import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  TextEditingController descriptionController = TextEditingController();
  String uid, wspId, orderId;

  CustomerCompletedOrderDetailsState(String uid, String wspId, String orderId) {
    this.uid = uid;
    this.wspId = wspId;
    this.orderId = orderId;
  }

  Widget images(var _images) {
    List<Widget> list = new List<Widget>();
    _images.forEach((image) async {
      list.add(Expanded(
          child: Image.network(
        image,
        width: 100,
        height: 100,
      )));
    });

    return new Row(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Order ( " + orderId + " )")),
        body: SingleChildScrollView(
            child: Column(children: [
          SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(20.0), child: Text("Order Details")),
          ),
          SingleChildScrollView(
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection('orders')
                    .document(orderId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return new Text("Loading");
                  }
                  var userDocument = snapshot.data;
                  return Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(5.0)),
                        Text("Title: " + userDocument["title"]),
                        Text(
                            "Distance: " + userDocument["distance"].toString()),
                        Text("Service date and time: " +
                            DateTime.fromMicrosecondsSinceEpoch(
                                    userDocument["service date and time"]
                                        .microsecondsSinceEpoch)
                                .toString()),
                        Text("Time window: " +
                            DateTime.fromMicrosecondsSinceEpoch(
                                    userDocument["time window"]
                                        .microsecondsSinceEpoch)
                                .toString()),
                        Text("Service type: " + userDocument["service type"]),
                        userDocument["photos"] != null
                            ? images(userDocument["photos"])
                            : Container(),
                        Padding(padding: EdgeInsets.all(5.0)),
                      ],
                    ),
                  );
                }),
          ),
          SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(20.0), child: Text("WSP Details")),
          ),
          SingleChildScrollView(
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('placed orders')
                      .where("order id", isEqualTo: orderId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!(snapshot.data == null ||
                        snapshot.data.documents == null)) {
                      return SizedBox(
                          height: 400.0,
                          child: new ListView.builder(
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
                                        return Card(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Wsp Id: " +
                                                    course["wsp id"]),
                                                Text("Description: " +
                                                    course["description"]),
                                                Text("Price: " +
                                                    course["price"].toString()),
                                                Text("Distance: " +
                                                    course["distance"]
                                                        .toString()), // print(DateTime.now().difference(course["order completion time"]).inMinutes);
                                                DateTime.now()
                                                            .difference(DateTime
                                                                .fromMicrosecondsSinceEpoch(
                                                                    course["order completion time"]
                                                                        .microsecondsSinceEpoch))
                                                            .inMinutes <=
                                                        24 * 60
                                                    ? RaisedButton(
                                                        onPressed: () {
                                                          Firestore.instance
                                                              .collection(
                                                                  "orders")
                                                              .document(orderId)
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
                                                            "rating": FieldValue
                                                                .delete()
                                                          });

                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                          "Reopen Order (In 24 hours)",
                                                          style: TextStyle(
                                                              fontSize: 15.0),
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                        color: Colors
                                                            .lightBlueAccent,
                                                      )
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                                course["feedback"] == null
                                                    ? Column(children: [
                                                        Text("Submit Feedback"),
                                                        Form(
                                                            key: _formKey,
                                                            child:
                                                                SingleChildScrollView(
                                                                    child: Column(
                                                                        children: <
                                                                            Widget>[
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            20.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          feedbackController,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            "Please provide your valuable feedback (if any)",
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                        ),
                                                                      ),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .text,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                      "Ratings*"),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            20.0),
                                                                    child: DropdownButton<
                                                                        String>(
                                                                      //create an array of strings
                                                                      items: ratings.map(
                                                                          (String
                                                                              value) {
                                                                        return DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              value,
                                                                          child:
                                                                              Text(value),
                                                                        );
                                                                      }).toList(),
                                                                      //value property
                                                                      value:
                                                                          rating,
                                                                      //without it nothing will be updated
                                                                      onChanged:
                                                                          (String
                                                                              value) {
                                                                        _onDropDownChanged(
                                                                            value);
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            20.0),
                                                                    child: isLoading
                                                                        ? CircularProgressIndicator()
                                                                        : RaisedButton(
                                                                            color:
                                                                                Colors.lightBlueAccent,
                                                                            onPressed:
                                                                                () {
                                                                              if (_formKey.currentState.validate()) {
                                                                                setState(() {
                                                                                  isLoading = true;
                                                                                });
                                                                                submitFeedback(orderId, course.documentID, course["wsp id"], course["service type"]);
                                                                              }
                                                                            },
                                                                            child:
                                                                                Text('Submit'),
                                                                          ),
                                                                  )
                                                                ])))
                                                      ])
                                                    : Container(),
                                              ]),
                                        );
                                      }
                                  }
                                }
                              }));
                    } else {
                      return Text("Invalid order id!");
                    }
                  })),
        ])));
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
    descriptionController.dispose();
  }
}
