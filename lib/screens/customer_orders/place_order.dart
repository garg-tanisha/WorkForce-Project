import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/location_tracking/application_bloc.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:path/path.dart' as Path;

class PlaceOrder extends StatefulWidget {
  PlaceOrder({this.uid});
  final String uid;
  @override
  State<StatefulWidget> createState() => PlaceOrderState(uid);
}

class PlaceOrderState extends State {
  List<File> _images = [];
  String messageTitle = "Empty";
  String notificationAlert = "alert";

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");
  final distanceUnits = ["km", "m", "cm", "inch", "foot", "mm", "miles"];
  String distanceUnit = "km";
  final ratings = ['>=0', '>=1', '>=2', '>=3', '>=4'];
  final _serviceTypes = [
    'Electrician',
    'Mechanic',
    'Carpenter',
    'Plumber',
    'Doctor',
    'Other'
  ];
  final timeFormat = DateFormat("HH:mm");
  final _formKey = GlobalKey<FormState>();
  String _serviceType = 'Electrician';
  List<String> options = [];
  String rating = '>=0';
  String ratingValue = '0';
  DateTime serviceDateTime = DateTime.now();
  DateTime timeWindow = DateTime.now();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController timeWindowController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String uid;
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  LocationData newLocalData;

  GoogleMapController _controller;
  PlaceOrderState(String uid) {
    this.uid = uid;
  }

  @override
  void initState() {
    super.initState();
    addressController.text = "Click blue button to get your current address";
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("images/car.jpg");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    print(latlng);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((localData) {
        newLocalData = localData;
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
          addressController.text =
              LatLng(newLocalData.latitude, newLocalData.longitude).toString();
          setState(() {});
        }
      });
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION DENIED") {
        debugPrint("Permission Denied");
        print("Permission Denied");
      }
    }
  }

  void _showPicker(context) {
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
                        getImage(true);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImage(false);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future getImage(bool gallery) async {
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
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> uploadFile(File _image, String orderId) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('orders/${orderId}/${Path.basename(_image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    String returnURL;
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL = fileURL;
    });
    return returnURL;
  }

  Future<void> saveImages(List<File> _images, DocumentReference ref) async {
    _images.forEach((image) async {
      String imageURL = await uploadFile(image, ref.documentID);
      ref.updateData({
        "photos": FieldValue.arrayUnion([imageURL])
      });
    });
  }

  Future uploadFilesToFirestore(String docId) async {
    DocumentReference sightingRef =
        Firestore.instance.collection("orders").document(docId);
    await saveImages(_images, sightingRef);
  }

  Widget images() {
    List<Widget> list = new List<Widget>();
    _images.forEach((image) async {
      list.add(ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.file(
          image,
          width: 100,
          height: 100,
          fit: BoxFit.fitHeight,
        ),
      ));
    });

    return new Column(children: list);
    // : Container();
  }

  DateTime selectedDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(3101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ApplicationBloc(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Scaffold(
                appBar: AppBar(title: Text("Place Order")),
                body: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                      // Text(
                      //   notificationAlert,
                      // ),
                      // Text(
                      //   messageTitle,
                      //   style: Theme.of(context).textTheme.headline4,
                      // ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: "Enter Title*",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter Title';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        // margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  15.0) //                 <--- border radius here
                              ),
                        ),
                        child: Column(children: [
                          Text("Type of Service Required"),
                          DropdownButton<String>(
                            items: _serviceTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: _serviceType,
                            onChanged: (String value) {
                              _onDropDownChanged(value);
                            },
                          ),
                        ]),
                      ),
                      Container(
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(
                                    15.0) //                 <--- border radius here
                                ),
                          ),
                          child: Column(children: [
                            Text(
                                "Upload at least 2 pictures of the device etc.*"),
                            Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Column(children: [
                                  RawMaterialButton(
                                    fillColor: Theme.of(context).accentColor,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                    elevation: 8,
                                    onPressed: () {
                                      _showPicker(context);
                                    },
                                    padding: EdgeInsets.all(15),
                                    shape: CircleBorder(),
                                  ),
                                  _images.length != 0
                                      ? Text("Choosen images (" +
                                          _images.length.toString() +
                                          ")")
                                      : Container(),
                                  _images.length != 0 ? images() : Container(),
                                ])),
                          ])),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: "Price (In Rupees) *",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value.isEmpty && _images.length < 2) {
                              return 'Please select at least 2 images \nEnter a Price you are willing to pay';
                            } else if (value.contains('-') &&
                                _images.length < 2) {
                              return 'Please select at least 2 images \nPlease enter a valid price';
                            } else if (value.isEmpty) {
                              return 'Enter a Price you are willing to pay';
                            } else if (value.contains('-')) {
                              return 'Please enter a valid price';
                            } else if (_images.length < 2) {
                              return 'Please select at least 2 images';
                            }

                            return null;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  15.0) //                 <--- border radius here
                              ),
                        ),
                        child: Row(children: [
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("Ratings*"),
                          )),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: DropdownButton<String>(
                                //create an array of strings
                                items: ratings.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                //value property
                                value: rating,
                                //without it nothing will be updated
                                onChanged: (String value) {
                                  _onRatingDropDownChanged(value);
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  15.0) //                 <--- border radius here
                              ),
                        ),
                        child: Row(children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: TextFormField(
                                controller: distanceController,
                                decoration: InputDecoration(
                                  labelText: "Distance (in km) *",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please select a distance range.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          readOnly: true,
                          style: TextStyle(color: Colors.grey),
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: "Current Address*",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.multiline, minLines: 1,
                          maxLines: 5,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value ==
                                "Click blue button to get your current address") {
                              return 'Select address by click blue icon on below google maps';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Card(
                      //     color: Colors.white,
                      //     elevation: 2.0,
                      //     child: ListTile(
                      //       title:
                      //           Text("Click blue button to get your current address"),
                      //     )),
                      Container(
                        height: 300,
                        child: Scaffold(
                          body: GoogleMap(
                            mapType: MapType.hybrid,
                            initialCameraPosition: initialLocation,
                            markers: Set.of((marker != null) ? [marker] : []),
                            circles: Set.of((circle != null) ? [circle] : []),
                            onMapCreated: (GoogleMapController controller) {
                              _controller = controller;
                            },
                          ),
                          floatingActionButton: FloatingActionButton(
                            child: Icon(Icons.location_searching),
                            onPressed: () {
                              getCurrentLocation();
                            },
                          ),
                          floatingActionButtonLocation:
                              FloatingActionButtonLocation.centerFloat,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  15.0) //                 <--- border radius here
                              ),
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(children: <Widget>[
                              Text(
                                  'Service date and time (${dateTimeFormat.pattern})'),
                              DateTimeField(
                                initialValue: DateTime.now(),
                                format: dateTimeFormat,
                                onShowPicker: (context, currentValue) async {
                                  final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1900),
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime(2100));
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          currentValue ?? DateTime.now()),
                                    );
                                    serviceDateTime =
                                        DateTimeField.combine(date, time);
                                    setState(() {});
                                    return DateTimeField.combine(date, time);
                                  } else {
                                    return currentValue;
                                  }
                                },
                                validator: (val) {
                                  if (val
                                          .difference(DateTime.now())
                                          .inMinutes <=
                                      0) {
                                    return 'Service Date Time Field should be after current date time.';
                                  } else if (val != null) {
                                    return null;
                                  } else {
                                    return 'Date Field is Empty';
                                  }
                                },
                              ),
                            ])),
                      ),
                      Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  15.0) //                 <--- border radius here
                              ),
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(children: <Widget>[
                              Text('Time Window (${dateTimeFormat.pattern})'),
                              DateTimeField(
                                initialValue: DateTime.now(),
                                format: dateTimeFormat,
                                onShowPicker: (context, currentValue) async {
                                  final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1900),
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime(2100));
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          currentValue ?? DateTime.now()),
                                    );
                                    timeWindow =
                                        DateTimeField.combine(date, time);
                                    setState(() {});
                                    return DateTimeField.combine(date, time);
                                  } else {
                                    return currentValue;
                                  }
                                },
                                validator: (val) {
                                  if (val
                                              .difference(DateTime.now())
                                              .inMinutes <=
                                          0 ||
                                      serviceDateTime
                                              .difference(val)
                                              .inMinutes <=
                                          0) {
                                    return 'Time Window should be earlier than service date and time, and current time';
                                  } else if (val != null) {
                                    return null;
                                  } else {
                                    return 'Time Window Field is Empty';
                                  }
                                },
                              ),
                            ])),
                      ),
                      // Container(
                      //   margin: const EdgeInsets.all(15.0),
                      //   padding: const EdgeInsets.all(2.0),
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //       color: Colors.black,
                      //     ),
                      //     borderRadius: BorderRadius.all(Radius.circular(
                      //             15.0) //                 <--- border radius here
                      //         ),
                      //   ),
                      //   child: Padding(
                      //       padding: EdgeInsets.all(20.0),
                      //       child: Column(children: <Widget>[
                      //         Text('Time window (${timeFormat.pattern})'),
                      //         DateTimeField(
                      //           initialValue: DateTime.now(),
                      //           format: timeFormat,
                      //           onShowPicker: (context, currentValue) async {
                      //             final time = await showTimePicker(
                      //               context: context,
                      //               initialTime: TimeOfDay.fromDateTime(
                      //                   currentValue ?? DateTime.now()),
                      //             );
                      //             timeWindow = DateFormat.Hms()
                      //                 .format(DateTimeField.convert(time));
                      //             setState(() {});
                      //             return DateTimeField.convert(time);
                      //           },
                      //         ),
                      //       ])),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : RaisedButton(
                                color: Colors.lightBlueAccent,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    placeOrder(uid);
                                  }
                                },
                                child: Text('Place Order'),
                              ),
                      ),
                    ]))))));
  }

  void placeOrder(String uid) {
    //cloud firestore
    Firestore.instance.collection("orders").add({
      "user id": uid,
      "title": titleController.text,
      "service type": _serviceType,
      "price": double.parse(priceController.text),
      "ratings": double.parse(ratingValue),
      "distance":
          int.parse(distanceController.text), // + " " + distanceUnit, [in km]
      "service date and time": serviceDateTime,
      "time window": timeWindow,
      "date time": DateTime.now(),
      "status": "New",
      "latitude": newLocalData.latitude,
      "longitude": newLocalData.longitude
    }).then((res) {
      print(res.documentID);
      uploadFilesToFirestore(res.documentID).whenComplete(() {
        isLoading = false;
        Navigator.pop(context, true);
      });
    });
  }

  _onDropDownChanged(String value) {
    setState(() {
      this._serviceType = value;
    });
  }

  _onRatingDropDownChanged(String value) {
    setState(() {
      this.rating = value;
      if (value == ">=0")
        this.ratingValue = "0";
      else if (value == ">=1")
        this.ratingValue = "1";
      else if (value == ">=2")
        this.ratingValue = "2";
      else if (value == ">=3")
        this.ratingValue = "3";
      else if (value == ">=4") this.ratingValue = "4";
    });
  }

  _onDistanceUnitDropDownChanged(String value) {
    setState(() {
      this.distanceUnit = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    priceController.dispose();
    distanceController.dispose();
    timeWindowController.dispose();
  }
}
