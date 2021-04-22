import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'is_email_verified.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class EmailSignUp extends StatefulWidget {
  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  bool isLoading = false;
  final _roles = ['Customer', 'Service Provider', 'Both'];
  String _role = 'Customer';
  List<String> options = [];
  Map roleChoices = new Map();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  LocationData newLocalData;

  GoogleMapController _controller;
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Sign Up")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
              Row(children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: "Enter First Name*",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.name,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter First Name*';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: "Enter Last Name*",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Last Name';
                      }
                      return null;
                    },
                  ),
                )),
              ]),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Enter Email*",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter an Email Address';
                    } else if (!value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: "Enter Age",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  // The validator receives the text that the user has entered.
                  // validator: (value) {
                  //   if (value.isEmpty) {
                  //     return 'Enter Age';
                  //   }
                  //   return null;
                  // },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: phoneNoController,
                  decoration: InputDecoration(
                    labelText: "Enter Phone No.*",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty ||
                        value.length != 10 ||
                        !isNumeric(value)) {
                      return 'Enter Valid Phone No!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Enter Password*",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter Password';
                    } else if (value.length < 6) {
                      return 'Password must be atleast 6 characters!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  obscureText: true,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: "Confirm Password*",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Confirm Password';
                    } else if (value != passwordController.text) {
                      return 'Passwords donot match!';
                    }
                    return null;
                  },
                ),
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
                  maxLines:
                      5, // The validator receives the text that the user has entered.
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
              Text("Choose Role*"),
              DropdownButton<String>(
                //create an array of strings
                items: _roles.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: _role,
                onChanged: (String value) {
                  _onDropDownChanged(value);
                },
              ),
              _role != "Customer"
                  ? ExpansionTile(
                      title: Text('Service Roles'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderCheckboxList(
                            decoration: InputDecoration(
                                labelText:
                                    "Services that you are willing to provide"),
                            attribute: "service roles",
                            initialValue: options,
                            options: [
                              FormBuilderFieldOption(value: "Electrician"),
                              FormBuilderFieldOption(value: "Carpenter"),
                              FormBuilderFieldOption(value: "Doctor"),
                              FormBuilderFieldOption(value: "Plumber"),
                              FormBuilderFieldOption(value: "Mechanic"),
                            ],
                            onChanged: (values) {
                              roleChoices.clear();
                              values.forEach((e) => roleChoices[e] =
                                  "null"); //options.add(e as String));
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(),
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
                            registerToFb();
                          }
                        },
                        child: Text('Submit'),
                      ),
              ),
            ]))));
  }

  void registerToFb() {
    firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) {
      //cloud firestore
      if ("role" != "Customer") {
        Firestore.instance
            .collection("users")
            .document(result.user.uid)
            .setData({
          "email": emailController.text,
          "age": int.parse(ageController.text),
          "first name": firstNameController.text,
          "last name": lastNameController.text,
          "role": _role,
          "roles": roleChoices,
          // "address": addressController.text,
          "date time": DateTime.now(),
          "phone no": int.parse(phoneNoController.text),
          "latitude": newLocalData.latitude,
          "longitude": newLocalData.longitude
        }).then((res) {
          isLoading = false;
          setState(() {});

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => IsEmailVerified(
                    email: emailController.text,
                    password: passwordController.text,
                    role: _role)),
          );
        }).catchError((err) {
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
                        isLoading = false;
                        setState(() {});
                      },
                    )
                  ],
                );
              });
        });
      } else {
        Firestore.instance
            .collection("users")
            .document(result.user.uid)
            .setData({
              "email": emailController.text,
              "age": int.parse(ageController.text),
              "first name": firstNameController.text,
              "last name": lastNameController.text,
              "role": _role,
              "address": addressController.text,
              "date time": DateTime.now(),
              "phone no": int.parse(phoneNoController.text),
              "latitude": newLocalData.latitude,
              "longitude": newLocalData.longitude
            })
            .then((res) {})
            .then((res) {
              isLoading = false;
              setState(() {});

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => IsEmailVerified(
                        email: emailController.text,
                        password: passwordController.text,
                        role: _role)),
              );
            })
            .catchError((err) {
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
                            isLoading = false;
                            setState(() {});
                          },
                        )
                      ],
                    );
                  });
            });
      }
    });
  }

  _onDropDownChanged(String value) {
    setState(() {
      this._role = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    ageController.dispose();
    addressController.dispose();
    phoneNoController.dispose();
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }
}
