import 'package:workforce/screens/location_tracking/application_bloc.dart';
import 'package:workforce/screens/location_tracking/maps_screen.dart';
import 'package:flutter_recaptcha_v2/flutter_recaptcha_v2.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'email_verification.dart';
import 'dart:async';

class EmailSignUp extends StatefulWidget {
  @override
  _EmailSignUpState createState() => _EmailSignUpState();

  static _EmailSignUpState of(BuildContext context) =>
      context.findAncestorStateOfType<_EmailSignUpState>();
}

class _EmailSignUpState extends State<EmailSignUp> {
  String location = "Not set yet";
  bool isLoading = false;
  final _roles = ['Customer', 'Service Provider', 'Both'];
  String _role = 'Customer';
  List<String> options = [];
  Map roleChoices = new Map();
  final _formKey = GlobalKey<FormState>();
  String verifyResult = "";
  bool recaptchaCheck = false;
  RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  StreamSubscription _locationSubscription;

  LocationData newLocalData;
  DateTime selectedDateOfBirth = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateOfBirth,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDateOfBirth)
      setState(() {
        selectedDateOfBirth = picked;
        dobController.text = "${selectedDateOfBirth.toLocal()}".split(' ')[0];
      });
  }

  set string(String value) => setState(() {
        location = value;
      });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Shader linearGradient = LinearGradient(
      colors: <Color>[Color(0xFF64B5F6), Color(0xFF1976D2)],
    ).createShader(new Rect.fromLTWH(0.0, 0.0, 70.0, 200.0));
    return ChangeNotifierProvider(
        create: (context) => ApplicationBloc(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Scaffold(
                appBar: AppBar(title: Text("Sign Up")),
                body: Stack(children: <Widget>[
                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Center(
                            child: Column(children: <Widget>[
                      // Padding(
                      //   padding: EdgeInsets.all(10.0),
                      // child:
                      Image.asset('images/workforce.png',
                          height: 220.0, width: 220.0, fit: BoxFit.scaleDown),
                      // ),
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  30.0) //                 <--- border radius here
                              ),
                        ),
                        child: Text(
                          "Get everything at single place!",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              foreground: new Paint()..shader = linearGradient),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 20.0, right: 20.0),
                        child: Row(children: [
                          Icon(
                            Icons.account_circle_outlined,
                            color: Colors.blue,
                            size: 30.0,
                            semanticLabel: 'First Name',
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  left: 20.0,
                                  right: 20.0),
                              child: TextFormField(
                                controller: firstNameController,
                                decoration: InputDecoration(
                                  labelText: "First Name",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter First Name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
                        child: Row(children: [
                          Icon(
                            Icons.account_circle_outlined,
                            color: Colors.blue,
                            size: 30.0,
                            semanticLabel: 'Last Name',
                          ),
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.only(
                                top: 10.0,
                                bottom: 0.0,
                                left: 20.0,
                                right: 20.0),
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: "Last Name",
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
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 0.0, left: 20.0, right: 20.0),
                        child: Row(children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.blue,
                            size: 30.0,
                            semanticLabel: 'Email',
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 10.0,
                                  left: 20.0,
                                  right: 20.0),
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
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
                          )
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
                        child: Row(children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: 30.0,
                            semanticLabel: 'Date of Birth',
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 10.0,
                                  left: 20.0,
                                  right: 20.0),
                              child: TextFormField(
                                // enabled: false,
                                controller: dobController,
                                decoration: InputDecoration(
                                  labelText: "Date Of Birth (Optional)",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onTap: () => _selectDate(context),
                                // keyboardType: TextInputType.number,
                              ),
                            ),
                          )
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
                        child: Row(children: [
                          Icon(
                            Icons.contact_phone_outlined,
                            color: Colors.blue,
                            size: 30.0,
                            semanticLabel: 'Phone Number',
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 10.0,
                                  left: 20.0,
                                  right: 20.0),
                              child: TextFormField(
                                controller: phoneNoController,
                                decoration: InputDecoration(
                                  labelText: "Phone Number",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
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
                          )
                        ]),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
                          child: Row(children: [
                            Icon(
                              Icons.lock_outlined,
                              color: Colors.blue,
                              size: 30.0,
                              semanticLabel: 'Password',
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 20.0,
                                    bottom: 10.0,
                                    left: 20.0,
                                    right: 20.0),
                                child: TextFormField(
                                  obscureText: true,
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
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
                            )
                          ])),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
                          child: Row(children: [
                            Icon(
                              Icons.lock_outlined,
                              color: Colors.blue,
                              size: 30.0,
                              semanticLabel: 'Confirm Password',
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 20.0,
                                    bottom: 10.0,
                                    left: 20.0,
                                    right: 20.0),
                                child: TextFormField(
                                  obscureText: true,
                                  controller: confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: "Confirm Password",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please Confirm Password';
                                    } else if (value !=
                                        passwordController.text) {
                                      return 'Passwords donot match!';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            )
                          ])),
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        padding: EdgeInsets.only(
                            top: 5.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 20.0,
                                  right: 20.0),
                              child: Text("Choose Role:",
                                  style: TextStyle(fontSize: 16.0)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 20.0,
                                  right: 20.0),
                              child: DropdownButton<String>(
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
                            ),
                          ]),
                        ),
                      ),
                      _role != "Customer"
                          ? Padding(
                              padding: EdgeInsets.only(
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 20.0,
                                  right: 20.0),
                              child: Row(children: [
                                Icon(
                                  Icons.category_outlined,
                                  color: Colors.blue,
                                  size: 30.0,
                                  semanticLabel: 'Service Roles',
                                ),
                                Expanded(
                                    child: Container(
                                        margin: const EdgeInsets.all(10.0),
                                        padding: EdgeInsets.only(
                                            top: 5.0,
                                            bottom: 5.0,
                                            left: 0.0,
                                            right: 0.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                        ),
                                        child: ExpansionTile(
                                          title: Text('Choose Service Roles'),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                  FormBuilderFieldOption(
                                                      value: "Doctor"),
                                                  FormBuilderFieldOption(
                                                      value: "Plumber"),
                                                  FormBuilderFieldOption(
                                                      value: "Mechanic"),
                                                ],
                                                onChanged: (values) {
                                                  roleChoices.clear();
                                                  values.forEach((e) =>
                                                      roleChoices[e] = "null");
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                          ],
                                        )))
                              ]))
                          : Container(),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 20.0, right: 20.0),
                          child: Row(children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.blue,
                              size: 30.0,
                              semanticLabel: 'Address',
                            ),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  left: 20.0,
                                  right: 20.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    "Address(Current Location or Search Location)",
                                    style: TextStyle(fontSize: 16.0)),
                              ),
                            ))
                          ])),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 400,
                              child: MapsScreen(
                                tableName: 'users',
                                callback: (val) =>
                                    setState(() => location = val),
                              )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : RaisedButton(
                                color: Colors.lightBlueAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    side: BorderSide(
                                        color: Colors.blue, width: 2)),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    if (verifyResult ==
                                        "You've been verified successfully.") {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      registerToFb();
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Text(
                                                  "Kindly verify if you are robot"),
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
                                    }
                                  }
                                  // // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => IsEmailVerified(
                                  //           email: emailController.text,
                                  //           password: passwordController.text,
                                  //           role: _role)),
                                  // );
                                },
                                child: Text('Sign Up'),
                              ),
                      ),
                    ]))),
                  ),
                  !recaptchaCheck
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.all(40.0),
                                child: RaisedButton(
                                  color: Colors.lightBlueAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      side: BorderSide(
                                          color: Colors.blue, width: 2)),
                                  child: Text("Verify if you are robot"),
                                  onPressed: () {
                                    recaptchaV2Controller.show();
                                  },
                                ))
                          ],
                        ))
                      : Container(width: 0.0, height: 0.0),
                  RecaptchaV2(
                    apiKey: "6LcDZNYaAAAAAJr47OaUnu6IBqJinP9lg6u68LnP",
                    apiSecret: "6LcDZNYaAAAAANufZSbn6pTHKh64kjODmUnyt-Kh",
                    controller: recaptchaV2Controller,
                    onVerifiedError: (err) {
                      print(err);
                    },
                    onVerifiedSuccessfully: (success) {
                      setState(() {
                        if (success) {
                          verifyResult = "You've been verified successfully.";
                          recaptchaCheck = true;
                          print(verifyResult);
                          recaptchaV2Controller.hide();
                        } else {
                          verifyResult = "Failed to verify.";
                          recaptchaCheck = false;
                          print(verifyResult);
                        }
                      });
                    },
                  ),
                  !recaptchaCheck
                      ? Container(width: 0.0, height: 0.0)
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(verifyResult))),
                ]))));
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
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
          "dob": int.parse(dobController.text),
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
              "dob": int.parse(dobController.text),
              "first name": firstNameController.text,
              "last name": lastNameController.text,
              "role": _role,
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
    dobController.dispose();
    phoneNoController.dispose();
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }
}
