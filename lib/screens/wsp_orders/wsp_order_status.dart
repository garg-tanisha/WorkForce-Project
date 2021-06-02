import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/wsp_orders/wsp_in_progress_orders.dart';
import 'wsp_new_orders.dart';
import 'package:workforce/screens/wsp_orders/order_confirmations.dart';
import 'wsp_completed_orders.dart';
import 'package:workforce/screens/wsp_orders/wsp_orders_home.dart';

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

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (selectedIndex == 0
          ? OrderHome(uid: uid, role: role)
          : (selectedIndex == 1
              ? OrderConfirmationsSent(uid: uid, role: role, flag: false)
              : (selectedIndex == 2
                  ? Orders(uid: uid, role: role, flag: false)
                  : (selectedIndex == 3
                      ? WSPInProgressOrders(uid: uid, role: role, flag: false)
                      : WSPCompletedOrders(
                          uid: uid, role: role, flag: false))))),
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.blue,
          unselectedItemLabelColor: Colors.white,
          unselectedItemIconColor: Colors.white,
          selectedItemBorderColor: Colors.blue,
          selectedItemBackgroundColor: Colors.white,
          selectedItemIconColor: Colors.blue,
          selectedItemLabelColor: Colors.white,
          showSelectedItemShadow: false,
          barHeight: 60,
        ),
        selectedIndex: selectedIndex,
        onSelectTab: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          FFNavigationBarItem(
            iconData: Icons.home_outlined,
            label: 'Home',
          ),
          FFNavigationBarItem(
            iconData: Icons.timer,
            label: 'Status',
          ),
          FFNavigationBarItem(
            iconData: Icons.shopping_cart_outlined,
            label: 'New ',
          ),
          FFNavigationBarItem(
            iconData: Icons.hourglass_top_outlined,
            label: 'Progress',
          ),
          FFNavigationBarItem(
            iconData: Icons.check_circle_outline,
            label: 'Done',
          ),
        ],
      ),
    );
  }
}
