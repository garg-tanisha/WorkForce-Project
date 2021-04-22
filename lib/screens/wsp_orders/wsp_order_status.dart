import 'package:flutter/material.dart';
import 'package:workforce/screens/wsp_orders/wsp_in_progress_orders.dart';
import 'wsp_new_orders.dart';
import 'package:workforce/screens/wsp_orders/order_confirmations.dart';
import 'wsp_completed_orders.dart';

class OrderHistory extends StatefulWidget {
  OrderHistory({this.uid, this.role});
  final String uid;
  final String role;
  @override
  State<StatefulWidget> createState() => OrderHistoryState(uid, role);
}

class OrderHistoryState extends State {
  String uid;
  String role;

  OrderHistoryState(String uid, String role) {
    this.uid = uid;
    this.role = role;
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(role)),
      body: Column(
        children: [
          Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                title: Text("Order Confirmations Sent"),
                onTap: () {
                  Navigator.push(
                      context,
                      //builder of MaterialPageRoute will call TodoDetail class
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderConfirmationsSent(uid: uid, role: role),
                      ));
                },
              )),
          Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                title: Text("Order Requests"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Orders(uid: uid, role: role),
                      ));
                },
              )),
          Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                title: Text("Orders In Progress"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WSPInProgressOrders(uid: uid, role: role),
                      ));
                },
              )),
          Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                title: Text("Orders Completed"),
                onTap: () {
                  Navigator.push(
                      context,
                      //builder of MaterialPageRoute will call TodoDetail class
                      MaterialPageRoute(
                        builder: (context) =>
                            WSPCompletedOrders(uid: uid, role: role),
                      ));
                },
              )),
        ],
      ),
    );
  }
}
