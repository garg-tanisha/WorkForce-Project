import 'package:workforce/utils/images_and_Labels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/customer_orders/customer_order_status.dart';

class PreventiveMeasuresForCovid19 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width.roundToDouble(),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.all(
            Radius.circular(5.0) //                 <--- border radius here
            ),
      ),
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Preventive Measures To Fight Covid",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          ),
        ),
        Container(
            width: 0.98 * MediaQuery.of(context).size.width.roundToDouble(),
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black12,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                    child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                      title: Text(
                          "Wash your hands timely for atleast 20 seconds.",
                          style: TextStyle(fontSize: 13.0)),
                      leading: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                          ),
                        ),
                        child: Image.asset(preventCorona[0],
                            width: 40.0, height: 40.0, fit: BoxFit.cover),
                      )),
                )),
                Expanded(
                    child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                      title: Text("Use soaps or alcohol based sanitizers.",
                          style: TextStyle(fontSize: 13.0)),
                      leading: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                          ),
                        ),
                        child: Image.asset(preventCorona[1],
                            width: 40.0, height: 40.0, fit: BoxFit.cover),
                      )),
                ))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                    child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                      title: Text(
                          "Do social distancing. Avoid any close contact with sick people.",
                          style: TextStyle(fontSize: 13.0)),
                      leading: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                          ),
                        ),
                        child: Image.asset(preventCorona[2],
                            width: 40.0, height: 40.0, fit: BoxFit.cover),
                      )),
                )),
                Expanded(
                    child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                      title: Text(
                          "Avoid touching your nose, eyes or face with unclean hands.",
                          style: TextStyle(fontSize: 13.0)),
                      leading: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                          ),
                        ),
                        child: Image.asset(preventCorona[3],
                            width: 40.0, height: 40.0, fit: BoxFit.cover),
                      )),
                ))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                    child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                      title: Text(
                          "Cover nose and mouth with mask. Sneeze/cough into your elbow.",
                          style: TextStyle(fontSize: 13.0)),
                      leading: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                            ),
                          ),
                          child: Image.asset(preventCorona[4],
                              width: 40.0, height: 40.0, fit: BoxFit.cover))),
                )),
                Expanded(
                    child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                      title: Text(
                          "Isolation and social distancing are very important to stay safe.",
                          style: TextStyle(fontSize: 13.0)),
                      leading: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                          ),
                        ),
                        child: Image.asset(preventCorona[5],
                            width: 40.0, height: 40.0, fit: BoxFit.cover),
                      )),
                ))
              ]),
            ]))
      ]),
    );
  }
}
