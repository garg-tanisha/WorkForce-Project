import 'package:workforce/utils/widgets/preventive_measures_for_covid_19.dart';
import 'package:workforce/utils/images_and_Labels.dart';
import 'package:workforce/screens/chat/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:url_launcher/url_launcher.dart';
import 'package:workforce/utils/methods/images.dart';

class WSPInProgressOrderDetails extends StatefulWidget {
  WSPInProgressOrderDetails({this.wspId, this.orderId, this.flag});
  final String wspId;
  final String orderId;
  final bool flag;
  @override
  State<StatefulWidget> createState() =>
      WSPInProgressOrderDetailsState(wspId, orderId, flag);
}

class WSPInProgressOrderDetailsState extends State {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool flag;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String wspId, orderId;
  List<File> _proofImages = [];
  List<File> _signaturesImages = [];
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

  WSPInProgressOrderDetailsState(String wspId, String orderId, bool flag) {
    this.wspId = wspId;
    this.orderId = orderId;
    this.flag = flag;
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
    if (gallery) {
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
    } else {
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
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
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
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          child: ListView(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              // physics:
                                              //     NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              children: [
                                                ListTile(
                                                  subtitle: RichText(
                                                    text: new TextSpan(
                                                      style: new TextStyle(
                                                        fontSize: 18.0,
                                                        color: Colors.black,
                                                      ),
                                                      children: <TextSpan>[
                                                        new TextSpan(
                                                            text:
                                                                'Description: ',
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
                                                        new TextSpan(
                                                            text: '\nPrice: ',
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
                                                                " km")
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: SingleChildScrollView(
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
                                                                    bottom:
                                                                        00.0,
                                                                    left: 20.0,
                                                                    right:
                                                                        10.0),
                                                            child: RaisedButton(
                                                              onPressed:
                                                                  () async {
                                                                print("Call");
                                                                print(Firestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .document(
                                                                        course[
                                                                            "user id"])
                                                                    .get()
                                                                    .then((value) =>
                                                                        _makingPhoneCall(
                                                                            value["phone no"].toString())));
                                                              },
                                                              child: const Text(
                                                                "Call",
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
                                                                      width:
                                                                          2)),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.0,
                                                                    bottom:
                                                                        00.0,
                                                                    left: 20.0,
                                                                    right:
                                                                        10.0),
                                                            child: RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "Gives a platform to chat with customer");
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => ChatPage(
                                                                            placedOrderId:
                                                                                course.documentID,
                                                                            userId: wspId)),
                                                                  );
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Chat",
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
                                                                            2))),
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ])),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 15.0,
                                              bottom: 10.0,
                                              left: 10.0,
                                              right: 10.0),
                                          child: Text("Submit Proofs",
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
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
                                          child: Center(
                                              child: Form(
                                            key: _formKey,
                                            child: SingleChildScrollView(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                  proofsError == true
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10.0,
                                                                  left: 5.0),
                                                          child: Text(
                                                              "Please submit atleast 2 proof pictures.",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              )))
                                                      : Container(),
                                                  Row(children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10.0,
                                                                bottom: 0.0,
                                                                left: 20.0,
                                                                right: 20.0),
                                                        child: Text(
                                                            "Work Proofs",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    14.0)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 20.0),
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.camera_outlined,
                                                          color: Colors.blue,
                                                          size: 35.0,
                                                          semanticLabel:
                                                              'Camera',
                                                        ),
                                                        tooltip:
                                                            'Click to add images',
                                                        onPressed: () {
                                                          _showPicker(context,
                                                              _proofImages);
                                                        },
                                                      ),
                                                    )
                                                  ]),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 0.0,
                                                          bottom: 10.0,
                                                          left: 20.0,
                                                          right: 20.0),
                                                      child: Column(children: [
                                                        _proofImages.length != 0
                                                            ? Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            5.0),
                                                                child: Text(
                                                                    "Choosen images (" +
                                                                        _proofImages
                                                                            .length
                                                                            .toString() +
                                                                        ")",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0)))
                                                            : Container(),
                                                        _proofImages.length != 0
                                                            ? images__(
                                                                _proofImages)
                                                            : Container(),
                                                      ])),
                                                  signaturesError == true
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0,
                                                                  bottom: 5.0),
                                                          child: Text(
                                                              "Please submit atleast 1 signature picture.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)))
                                                      : Container(),
                                                  Row(children: [
                                                    Expanded(
                                                        child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 0.0,
                                                          bottom: 0.0,
                                                          left: 20.0,
                                                          right: 20.0),
                                                      child: Text(
                                                          "Customer Signatures",
                                                          style: TextStyle(
                                                              fontSize: 14.0)),
                                                    )),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 20.0),
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.camera_outlined,
                                                          color: Colors.blue,
                                                          size: 35.0,
                                                          semanticLabel:
                                                              'Camera',
                                                        ),
                                                        tooltip:
                                                            'Click to add images',
                                                        onPressed: () {
                                                          _showPicker(context,
                                                              _signaturesImages);
                                                        },
                                                      ),
                                                    )
                                                  ]),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 0.0,
                                                          bottom: 10.0,
                                                          left: 20.0,
                                                          right: 20.0),
                                                      child: Column(children: [
                                                        _signaturesImages
                                                                    .length !=
                                                                0
                                                            ? Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            5.0),
                                                                child: Text(
                                                                    "Choosen images (" +
                                                                        _signaturesImages
                                                                            .length
                                                                            .toString() +
                                                                        ")",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0)))
                                                            : Container(),
                                                        _signaturesImages
                                                                    .length !=
                                                                0
                                                            ? images__(
                                                                _signaturesImages)
                                                            : Container(),
                                                      ])),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 0.0,
                                                        bottom: 0.0,
                                                        left: 20.0,
                                                        right: 20.0),
                                                    child: isLoading
                                                        ? CircularProgressIndicator()
                                                        : RaisedButton(
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
                                                            onPressed: () {
                                                              if (_signaturesImages
                                                                      .length ==
                                                                  0) {
                                                                setState(() {
                                                                  signaturesError =
                                                                      true;
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  signaturesError =
                                                                      false;
                                                                });
                                                              }
                                                              if (_proofImages
                                                                      .length <
                                                                  2) {
                                                                setState(() {
                                                                  proofsError =
                                                                      true;
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  proofsError =
                                                                      false;
                                                                });
                                                              }
                                                              if (_formKey
                                                                      .currentState
                                                                      .validate() &&
                                                                  _proofImages
                                                                          .length >=
                                                                      2 &&
                                                                  _signaturesImages
                                                                          .length >=
                                                                      1) {
                                                                setState(() {
                                                                  isLoading =
                                                                      true;
                                                                });
                                                                submitProofs(
                                                                    orderId,
                                                                    course
                                                                        .documentID,
                                                                    context);
                                                              }
                                                            },
                                                            child:
                                                                Text('Submit'),
                                                          ),
                                                  )
                                                ])),
                                          ))),
                                    ]);
                              }
                          }
                        }
                      });
                } else {
                  return Text("Invalid order id!");
                }
              }),
          PreventiveMeasuresForCovid19(),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
