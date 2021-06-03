import 'package:workforce/screens/wsp_orders/wsp_order_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:workforce/utils/widgets/preventive_measures_for_covid_19.dart';
import 'package:workforce/utils/widgets/contact_us.dart';
import 'package:workforce/utils/widgets/services.dart';
import 'package:workforce/utils/widgets/wsp_drawer.dart';

class ServiceProviderHome extends StatefulWidget {
  ServiceProviderHome({this.uid});
  final String uid;
  @override
  State<StatefulWidget> createState() => ServiceProviderHomeState(uid);
}

class ServiceProviderHomeState extends State {
  String uid;
  final String title = "WSP HomePage";
  List<dynamic> roles = [], rating = [];
  ServiceProviderHomeState(String uid) {
    this.uid = uid;
  }
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onPressed: () {
                  FirebaseAuth auth = FirebaseAuth.instance;
                  auth.signOut().then((res) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  });
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 15.0, bottom: 10.0, left: 10.0, right: 10.0),
                    child: Text("Services",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0)),
                  ),
                ),
                StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document(uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      roles.clear();
                      if (!snapshot.hasData) {
                        return new Text("Loading");
                      }

                      var roles_check = snapshot.data;
                      var userDocument = snapshot.data["roles"];

                      if (roles_check == null ||
                          snapshot.data["role"] == "Customer")
                        return Center(child: Text("No specific roles!"));

                      for (var key in userDocument.keys) {
                        roles.add(key);
                      }

                      for (var value in userDocument.values) {
                        rating.add(value);
                      }

                      return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: roles.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              width: 0.98 *
                                  MediaQuery.of(context)
                                      .size
                                      .width
                                      .roundToDouble(),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black12,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(
                                        5.0) //                 <--- border radius here
                                    ),
                              ),
                              child: ListTile(
                                // leading: Icon(
                                //   Icons.add_location_alt_sharp,
                                //   color: Colors.blue,
                                //   size: 30.0,
                                //   semanticLabel: 'Customer Role',
                                // ),
                                trailing: Icon(
                                  Icons.arrow_right_outlined,
                                  color: Colors.blue,
                                  size: 40.0,
                                  semanticLabel: 'Right Arrow',
                                ),
                                title: Text(roles[index]),
                                subtitle: rating[index] != "null"
                                    ? Text(
                                        "(Rating: " +
                                            rating[index].toString() +
                                            " )",
                                      )
                                    : Text("(Rating: No rating yet)"),
                                onTap: () {
                                  print(roles[index]);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderHistory(
                                            uid: uid, role: roles[index]),
                                      ));
                                },
                              ),
                            );
                          });
                    }),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    width: 0.98 *
                        MediaQuery.of(context).size.width.roundToDouble(),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black12,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(
                              5.0) //                 <--- border radius here
                          ),
                    ),
                    child: ListTile(
                      // leading: Icon(
                      //   Icons.add_location_alt_sharp,
                      //   color: Colors.blue,
                      //   size: 30.0,
                      //   semanticLabel: 'Customer Role',
                      // ),
                      trailing: Icon(
                        Icons.arrow_right_outlined,
                        color: Colors.blue,
                        size: 40.0,
                        semanticLabel: 'Right Arrow',
                      ),
                      title: Text("Other"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderHistory(uid: uid, role: "Other"),
                            ));
                      },
                    )),
                Container(
                  width: MediaQuery.of(context).size.width.roundToDouble(),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(
                            5.0) //                 <--- border radius here
                        ),
                  ),
                  child: Column(children: [
                    PreventiveMeasuresForCovid19(),
                    ContactUs(),
                    InDemandServices()
                  ]),
                ),
              ],
            ),
          ),
          drawer: NavigateDrawer(uid: this.uid),
        ));
  }
}
