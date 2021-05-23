// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatMessageModel {
//   String title;
//   // String id;
//   double price; // UserModel user;
//   var photos;

//   ChatMessageModel({String title, double price, var photos}) {
//     this.title = title;
//     this.price = price;
//     this.photos = photos;
//   }

//   ChatMessageModel.fromSnapshot(DocumentSnapshot snapshot) {
//     // this.id = snapshot.documentID;
//     this.text = snapshot.data[""];
//     this.mediaUrl = snapshot.data["mediaUrl"];
//     this.createdAt = snapshot.data["createdAt"];
//     this.replyId = snapshot.data["replyId"];
//     this.userId = snapshot.data["userId"];
//   }

//   Map toMap() {
//     Map<String, dynamic> map = {
//       "text": this.text,
//       "mediaUrl": this.mediaUrl,
//       "userId": this.userId,
//       "createdAt": this.createdAt
//     };
//     return map;
//   }

//   Future<void> loadUser() async {
//     DocumentSnapshot ds = await Firestore.instance
//         .collection("users")
//         .document(this.userId)
//         .get();

//     Firestore.instance
//         .collection('orders')
//         .document(course["order id"])
//         .get()
//         .then((doc) {
//       if (!doc.exists) {
//         print("doc not found " + course["order id"]);
//       } else {
//         print("found the doc " + course["order id"]);
//       }
//       orderDetails = doc;
//     });
//     // if (ds != null) this.user = UserModel.fromSnapshot(ds);
//   }
// }

// class ChatMessage extends StatefulWidget {
//   // final ChatMessageModel _message;
//   final DocumentSnapshot course, orderDetails;
//   ChatMessage(this.course, this.orderDetails);
//   @override
//   _ChatMessageState createState() => _ChatMessageState(course, orderDetails);
// }

// class _ChatMessageState extends State<ChatMessage> {
//   // final ChatMessageModel _message;
//   final DocumentSnapshot course, orderDetails;

//   _ChatMessageState(this.course, this.orderDetails);

//   Future<ChatMessageModel> _load() async {
//     // await _message.loadUser();
//     // return _message;
//   }

//   void showCustomerResponse(String response) async {
//     return await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Response"),
//             content: Text(response),
//             actions: [
//               FlatButton(
//                 child: Text("Ok"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               )
//             ],
//           );
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//       child: FutureBuilder(
//         future: _load(),
//         builder: (context, AsyncSnapshot<ChatMessageModel> message) {
//           if (!message.hasData) return Container();
//           return Card(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 ListTile(
//                   title: Text("Title: " +
//                       orderDetails["title"] +
//                       " Order Id: " +
//                       course["order id"]),
//                   subtitle: Text("orderDetails: " +
//                       orderDetails["title"] +
//                       "Price: " +
//                       course["price"].toString() +
//                       "\nDistance: " +
//                       course["distance"].toString()),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(bottom: 10.0),
//                   child: Center(
//                     child: RaisedButton(
//                       onPressed: () async {
//                         if (course["customer response"] == "None") {
//                           showCustomerResponse("No response yet.");
//                         } else if (course["customer response"] == "accepted") {
//                           showCustomerResponse(
//                               "Customer accepted your request and the order is in progress now.");
//                         } else if (course["customer response"] == "cancelled") {
//                           showCustomerResponse("Customer cancelled the order.");
//                         } else {
//                           showCustomerResponse(
//                               "Customer rejected your request.");
//                         }
//                       },
//                       child: Text(
//                         course["customer response"],
//                         style: TextStyle(fontSize: 15.0),
//                       ),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0)),
//                       color: Colors.lightBlueAccent,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class OrderConfirmationsSent extends StatefulWidget {
//   OrderConfirmationsSent({this.uid, this.role});
//   final String uid;
//   final String role;
//   @override
//   State<StatefulWidget> createState() => OrderConfirmationsSentState(uid, role);
// }

// class OrderConfirmationsSentState extends State<OrderConfirmationsSent> {
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   String uid;
//   String role;
//   DocumentSnapshot orderDetails;
//   final filters = [
//     'No filter',
//     'Price (Low To High)',
//     'Price (High To Low)',
//     'Reponse (First Come First Serve)',
//     'Response (Last Come First Serve)'
//   ];
//   String filter = 'No filter';
//   OrderConfirmationsSentState(String uid, String role) {
//     this.uid = uid;
//     this.role = role;
//   }

//   _onDropDownChanged(String value) {
//     setState(() {
//       this.filter = value;
//     });
//   }

//   DocumentSnapshot orderDetailsFunction(String orderId) {
//     Firestore.instance.collection('orders').document(orderId).get().then((doc) {
//       if (!doc.exists) {
//         print("doc not found " + orderId);
//       } else {
//         print("found the doc " + orderId);
//       }
//       return doc;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (filter == 'No filter') {
//       return Scaffold(
//           appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
//           body: Column(children: [
//             Container(
//               color: Colors.black,
//               margin: const EdgeInsets.all(20.0),
//               padding:
//                   EdgeInsets.only(top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(children: [
//                   Padding(
//                     padding: EdgeInsets.only(
//                         top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
//                     child: Text("Filter",
//                         style: TextStyle(fontSize: 16.0, color: Colors.white)),
//                   ),
//                   Padding(
//                       padding: EdgeInsets.only(
//                           top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
//                       child: Card(
//                         child: DropdownButton<String>(
//                           //create an array of strings
//                           items: filters.map((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Padding(
//                                 padding: EdgeInsets.only(
//                                     top: 0.0,
//                                     bottom: 0.0,
//                                     left: 10.0,
//                                     right: 0.0),
//                                 child: Text(value,
//                                     style: TextStyle(
//                                         fontSize: 14.0, color: Colors.black)),
//                               ),
//                             );
//                           }).toList(),
//                           value: filter,
//                           onChanged: (String value) {
//                             _onDropDownChanged(value);
//                           },
//                         ),
//                       ))
//                 ]),
//               ),
//             ),
//             StreamBuilder(
//                 stream: Firestore.instance
//                     .collection('accepted responses')
//                     .where("wsp id", isEqualTo: uid)
//                     .where("role", isEqualTo: role)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!(snapshot.data == null ||
//                       snapshot.data.documents == null)) {
//                     return Column(children: [
//                       Expanded(
//                           child: ListView.builder(
//                               itemCount: snapshot.data.documents.length,
//                               itemBuilder: (context, index) {
//                                 if (snapshot.hasError) {
//                                   print(snapshot.error);
//                                   return new Text('Error: ${snapshot.error}');
//                                 } else {
//                                   switch (snapshot.connectionState) {
//                                     case ConnectionState.waiting:
//                                       return new Text('Loading...');
//                                     default:
//                                       {
//                                         if (!snapshot.hasData)
//                                           return Text("Loading orders...");
//                                         DocumentSnapshot course =
//                                             snapshot.data.documents[index];
//                                         ChatMessageModel message =
//                                             ChatMessageModel.fromSnapshot(
//                                                 course);

//                                         return ChatMessage(
//                                             course, orderDetails);
//                                       }
//                                   }
//                                 }
//                               }))
//                     ]);
//                   } else {
//                     return Text("No accepted resposes yet!");
//                   }
//                 }),
//           ]));
//     } else if (filter == 'Price (Low To High)') {
//       return Scaffold(
//         appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
//         body: StreamBuilder(
//             stream: Firestore.instance
//                 .collection('accepted responses')
//                 .where("wsp id", isEqualTo: uid)
//                 .where("role", isEqualTo: role)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!(snapshot.data == null || snapshot.data.documents == null)) {
//                 return Column(children: [
//                   Container(
//                     color: Colors.black,
//                     margin: const EdgeInsets.all(20.0),
//                     padding: EdgeInsets.only(
//                         top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(children: [
//                         Padding(
//                           padding: EdgeInsets.only(
//                               top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
//                           child: Text("Filter",
//                               style: TextStyle(
//                                   fontSize: 16.0, color: Colors.white)),
//                         ),
//                         Padding(
//                             padding: EdgeInsets.only(
//                                 top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
//                             child: Card(
//                               child: DropdownButton<String>(
//                                 //create an array of strings
//                                 items: filters.map((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Padding(
//                                       padding: EdgeInsets.only(
//                                           top: 0.0,
//                                           bottom: 0.0,
//                                           left: 10.0,
//                                           right: 0.0),
//                                       child: Text(value,
//                                           style: TextStyle(
//                                               fontSize: 16.0,
//                                               color: Colors.black)),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 value: filter,
//                                 onChanged: (String value) {
//                                   _onDropDownChanged(value);
//                                 },
//                               ),
//                             ))
//                       ]),
//                     ),
//                   ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
//                   Expanded(
//                       // height: 200.0,
//                       child: ListView.builder(
//                           itemCount: snapshot.data.documents.length,
//                           itemBuilder: (context, index) {
//                             if (snapshot.hasError) {
//                               print(snapshot.error);
//                               return new Text('Error: ${snapshot.error}');
//                             } else {
//                               switch (snapshot.connectionState) {
//                                 case ConnectionState.waiting:
//                                   return new Text('Loading...');
//                                 default:
//                                   {
//                                     if (!snapshot.hasData)
//                                       return Text("Loading orders...");
//                                     DocumentSnapshot course =
//                                         snapshot.data.documents[index];
//                                     return Card(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           ListTile(
//                                             title: Text("Order Id: " +
//                                                 course["order id"]),
//                                             subtitle: Text("Price: " +
//                                                 course["price"].toString()),
//                                             leading: RaisedButton(
//                                               onPressed: () async {
//                                                 if (course[
//                                                         "customer response"] ==
//                                                     "None") {
//                                                   showCustomerResponse(
//                                                       "No response yet.");
//                                                 } else if (course[
//                                                         "customer response"] ==
//                                                     "accepted") {
//                                                   showCustomerResponse(
//                                                       "Customer accepted your request and the order is in progress now.");
//                                                 } else if (course[
//                                                         "customer response"] ==
//                                                     "cancelled") {
//                                                   showCustomerResponse(
//                                                       "Customer cancelled the order.");
//                                                 } else {
//                                                   showCustomerResponse(
//                                                       "Customer rejected your request.");
//                                                 }
//                                               },
//                                               child: Text(
//                                                 course["customer response"],
//                                                 style:
//                                                     TextStyle(fontSize: 15.0),
//                                               ),
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           8.0)),
//                                               color: Colors.lightBlueAccent,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }
//                               }
//                             }
//                           }))
//                 ]);
//               } else {
//                 return Text("No accepted resposes yet!");
//               }
//             }),
//       );
//     } else if (filter == 'Price (High To Low)') {
//       return Scaffold(
//         appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
//         body: StreamBuilder(
//             stream: Firestore.instance
//                 .collection('accepted responses')
//                 .where("wsp id", isEqualTo: uid)
//                 .where("role", isEqualTo: role)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!(snapshot.data == null || snapshot.data.documents == null)) {
//                 return Column(children: [
//                   Container(
//                     color: Colors.black,
//                     margin: const EdgeInsets.all(20.0),
//                     padding: EdgeInsets.only(
//                         top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
//                     // decoration: BoxDecoration(
//                     //   border: Border.all(
//                     //     color: Colors.black,
//                     //   ),
//                     //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                     // ),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(children: [
//                         Padding(
//                           padding: EdgeInsets.only(
//                               top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
//                           child: Text("Filter",
//                               style: TextStyle(
//                                   fontSize: 16.0, color: Colors.white)),
//                         ),
//                         Padding(
//                             padding: EdgeInsets.only(
//                                 top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
//                             child: Card(
//                               child: DropdownButton<String>(
//                                 //create an array of strings
//                                 items: filters.map((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Padding(
//                                       padding: EdgeInsets.only(
//                                           top: 0.0,
//                                           bottom: 0.0,
//                                           left: 10.0,
//                                           right: 0.0),
//                                       child: Text(value,
//                                           style: TextStyle(
//                                               fontSize: 16.0,
//                                               color: Colors.black)),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 value: filter,
//                                 onChanged: (String value) {
//                                   _onDropDownChanged(value);
//                                 },
//                               ),
//                             ))
//                       ]),
//                     ),
//                   ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
//                   Expanded(
//                       // height: 200.0,
//                       child: ListView.builder(
//                           itemCount: snapshot.data.documents.length,
//                           itemBuilder: (context, index) {
//                             if (snapshot.hasError) {
//                               print(snapshot.error);
//                               return new Text('Error: ${snapshot.error}');
//                             } else {
//                               switch (snapshot.connectionState) {
//                                 case ConnectionState.waiting:
//                                   return new Text('Loading...');
//                                 default:
//                                   {
//                                     if (!snapshot.hasData)
//                                       return Text("Loading orders...");
//                                     DocumentSnapshot course =
//                                         snapshot.data.documents[index];
//                                     return Card(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           ListTile(
//                                             title: Text("Order Id: " +
//                                                 course["order id"]),
//                                             subtitle: Text("Price: " +
//                                                 course["price"].toString()),
//                                             leading: RaisedButton(
//                                               onPressed: () async {
//                                                 if (course[
//                                                         "customer response"] ==
//                                                     "None") {
//                                                   showCustomerResponse(
//                                                       "No response yet.");
//                                                 } else if (course[
//                                                         "customer response"] ==
//                                                     "accepted") {
//                                                   showCustomerResponse(
//                                                       "Customer accepted your request and the order is in progress now.");
//                                                 } else if (course[
//                                                         "customer response"] ==
//                                                     "cancelled") {
//                                                   showCustomerResponse(
//                                                       "Customer cancelled the order.");
//                                                 } else {
//                                                   showCustomerResponse(
//                                                       "Customer rejected your request.");
//                                                 }
//                                               },
//                                               child: Text(
//                                                 course["customer response"],
//                                                 style:
//                                                     TextStyle(fontSize: 15.0),
//                                               ),
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           8.0)),
//                                               color: Colors.lightBlueAccent,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }
//                               }
//                             }
//                           }))
//                 ]);
//               } else {
//                 return Text("No accepted resposes yet!");
//               }
//             }),
//       );
//     } else if (filter == 'Reponse (First Come First Serve)') {
//       return Scaffold(
//         appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
//         body: StreamBuilder(
//             stream: Firestore.instance
//                 .collection('accepted responses')
//                 .where("wsp id", isEqualTo: uid)
//                 .where("role", isEqualTo: role)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!(snapshot.data == null || snapshot.data.documents == null)) {
//                 return Column(children: [
//                   Container(
//                     color: Colors.black,
//                     margin: const EdgeInsets.all(20.0),
//                     padding: EdgeInsets.only(
//                         top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
//                     // decoration: BoxDecoration(
//                     //   border: Border.all(
//                     //     color: Colors.black,
//                     //   ),
//                     //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                     // ),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(children: [
//                         Padding(
//                           padding: EdgeInsets.only(
//                               top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
//                           child: Text("Filter",
//                               style: TextStyle(
//                                   fontSize: 16.0, color: Colors.white)),
//                         ),
//                         Padding(
//                             padding: EdgeInsets.only(
//                                 top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
//                             child: Card(
//                               child: DropdownButton<String>(
//                                 //create an array of strings
//                                 items: filters.map((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Padding(
//                                       padding: EdgeInsets.only(
//                                           top: 0.0,
//                                           bottom: 0.0,
//                                           left: 10.0,
//                                           right: 0.0),
//                                       child: Text(value,
//                                           style: TextStyle(
//                                               fontSize: 16.0,
//                                               color: Colors.black)),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 value: filter,
//                                 onChanged: (String value) {
//                                   _onDropDownChanged(value);
//                                 },
//                               ),
//                             ))
//                       ]),
//                     ),
//                   ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
//                   Expanded(
//                       // height: 200.0,
//                       child: ListView.builder(
//                           itemCount: snapshot.data.documents.length,
//                           itemBuilder: (context, index) {
//                             if (snapshot.hasError) {
//                               print(snapshot.error);
//                               return new Text('Error: ${snapshot.error}');
//                             } else {
//                               switch (snapshot.connectionState) {
//                                 case ConnectionState.waiting:
//                                   return new Text('Loading...');
//                                 default:
//                                   {
//                                     if (!snapshot.hasData)
//                                       return Text("Loading orders...");
//                                     DocumentSnapshot course =
//                                         snapshot.data.documents[index];
//                                     return Card(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           ListTile(
//                                             title: Text("Order Id: " +
//                                                 course["order id"]),
//                                             subtitle: Text("Price: " +
//                                                 course["price"].toString()),
//                                             leading: RaisedButton(
//                                               onPressed: () async {
//                                                 if (course[
//                                                         "customer response"] ==
//                                                     "None") {
//                                                   showCustomerResponse(
//                                                       "No response yet.");
//                                                 } else if (course[
//                                                         "customer response"] ==
//                                                     "accepted") {
//                                                   showCustomerResponse(
//                                                       "Customer accepted your request and the order is in progress now.");
//                                                 } else if (course[
//                                                         "customer response"] ==
//                                                     "cancelled") {
//                                                   showCustomerResponse(
//                                                       "Customer cancelled the order.");
//                                                 } else {
//                                                   showCustomerResponse(
//                                                       "Customer rejected your request.");
//                                                 }
//                                               },
//                                               child: Text(
//                                                 course["customer response"],
//                                                 style:
//                                                     TextStyle(fontSize: 15.0),
//                                               ),
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           8.0)),
//                                               color: Colors.lightBlueAccent,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }
//                               }
//                             }
//                           }))
//                 ]);
//               } else {
//                 return Text("No accepted resposes yet!");
//               }
//             }),
//       );
//     } else if (filter == 'Response (Last Come First Serve)') {
//       return Scaffold(
//         appBar: AppBar(title: Text("Accepted Responses ( " + role + " )")),
//         body: StreamBuilder(
//             stream: Firestore.instance
//                 .collection('accepted responses')
//                 .where("wsp id", isEqualTo: uid)
//                 .where("role", isEqualTo: role)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!(snapshot.data == null || snapshot.data.documents == null)) {
//                 return Column(children: [
//                   Container(
//                     color: Colors.black,
//                     margin: const EdgeInsets.all(20.0),
//                     padding: EdgeInsets.only(
//                         top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
//                     // decoration: BoxDecoration(
//                     //   border: Border.all(
//                     //     color: Colors.black,
//                     //   ),
//                     //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                     // ),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(children: [
//                         Padding(
//                           padding: EdgeInsets.only(
//                               top: 0.0, bottom: 0.0, left: 10.0, right: 0.0),
//                           child: Text("Filter",
//                               style: TextStyle(
//                                   fontSize: 16.0, color: Colors.white)),
//                         ),
//                         Padding(
//                             padding: EdgeInsets.only(
//                                 top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
//                             child: Card(
//                               child: DropdownButton<String>(
//                                 //create an array of strings
//                                 items: filters.map((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Padding(
//                                       padding: EdgeInsets.only(
//                                           top: 0.0,
//                                           bottom: 0.0,
//                                           left: 10.0,
//                                           right: 0.0),
//                                       child: Text(value,
//                                           style: TextStyle(
//                                               fontSize: 16.0,
//                                               color: Colors.black)),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 value: filter,
//                                 onChanged: (String value) {
//                                   _onDropDownChanged(value);
//                                 },
//                               ),
//                             ))
//                       ]),
//                     ),
//                   ), //clicking shows alert which gives option to choose filter or shows dropdown to choose filter
//                   Expanded(
//                       // height: 200.0,
//                       child: ListView.builder(
//                           itemCount: snapshot.data.documents.length,
//                           itemBuilder: (context, index) {
//                             if (snapshot.hasError) {
//                               print(snapshot.error);
//                               return new Text('Error: ${snapshot.error}');
//                             } else {
//                               switch (snapshot.connectionState) {
//                                 case ConnectionState.waiting:
//                                   return new Text('Loading...');
//                                 default:
//                                   {
//                                     if (!snapshot.hasData)
//                                       return Text("Loading orders...");
//                                     DocumentSnapshot course =
//                                         snapshot.data.documents[index];
//                                     return Card(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           ListTile(
//                                             title: Text("Order Id: " +
//                                                 course["order id"]),
//                                             subtitle: Text("Price: " +
//                                                 course["price"].toString()),
//                                             leading: RaisedButton(
//                                               onPressed: () async {
//                                                 if (course[
//                                                         "customer response"] ==
//                                                     "None") {
//                                                   showCustomerResponse(
//                                                       "No response yet.");
//                                                 } else if (course[
//                                                         "customer response"] ==
//                                                     "accepted") {
//                                                   showCustomerResponse(
//                                                       "Customer accepted your request and the order is in progress now.");
//                                                 } else if (course[
//                                                         "customer response"] ==
//                                                     "cancelled") {
//                                                   showCustomerResponse(
//                                                       "Customer cancelled the order.");
//                                                 } else {
//                                                   showCustomerResponse(
//                                                       "Customer rejected your request.");
//                                                 }
//                                               },
//                                               child: Text(
//                                                 course["customer response"],
//                                                 style:
//                                                     TextStyle(fontSize: 15.0),
//                                               ),
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           8.0)),
//                                               color: Colors.lightBlueAccent,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }
//                               }
//                             }
//                           }))
//                 ]);
//               } else {
//                 return Text("No accepted resposes yet!");
//               }
//             }),
//       );
//     }
//   }

//   void showCustomerResponse(String response) async {
//     return await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Response"),
//             content: Text(response),
//             actions: [
//               FlatButton(
//                 child: Text("Ok"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               )
//             ],
//           );
//         });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
