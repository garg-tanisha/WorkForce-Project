import 'package:workforce/screens/location_tracking/home_screen.dart';
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
import 'is_email_verified.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/cupertino.dart';

class EmailSignUp extends StatefulWidget {
  @override
  _EmailSignUpState createState() => _EmailSignUpState();

  static _EmailSignUpState of(BuildContext context) =>
      context.findAncestorStateOfType<_EmailSignUpState>();
}

class _EmailSignUpState extends State<EmailSignUp> {
  String location = "Not set yet";

  set string(String value) => setState(() {
        location = value;
      });

  bool isLoading = false;
  final _roles = ['Customer', 'Service Provider', 'Both'];
  // String location;
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
  // TextEditingController addressController = TextEditingController();
  StreamSubscription _locationSubscription;

  LocationData newLocalData;
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  @override
  void initState() {
    super.initState();
    // addressController.text = "Current Location is chosen!";
  }

  @override
  Widget build(BuildContext context) {
    // final applicationBloc = Provider.of<ApplicationBloc>(context);

    return ChangeNotifierProvider(
        create: (context) => ApplicationBloc(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Scaffold(
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
                                      FormBuilderFieldOption(
                                          value: "Electrician"),
                                      FormBuilderFieldOption(
                                          value: "Carpenter"),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Address(Current Location or Search Location)"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            height: 400,
                            child: HomeScreen(
                              tableName: 'users',
                              callback: (val) => setState(() => location = val),
                            )),
                      ),
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
                    ]))))));
  }

  void registerToFb() {
    firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) {
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
          "date time": DateTime.now(),
          "phone no": int.parse(phoneNoController.text),
          "latitude": double.parse(location.split('(')[1].split(',')[0]),
          "longitude": double.parse(location.split(' ')[1].split(')')[0])
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
              // "address": addressController.text,
              "date time": DateTime.now(),
              "phone no": int.parse(phoneNoController.text),
              "latitude": double.parse(location.split('(')[1].split(',')[0]),
              "longitude": double.parse(location.split(' ')[1].split(')')[0])
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
    // addressController.dispose();
    phoneNoController.dispose();
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }
}
