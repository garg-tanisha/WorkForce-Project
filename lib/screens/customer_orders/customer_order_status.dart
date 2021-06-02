import 'package:workforce/screens/customer_orders/place_order.dart';
import 'package:workforce/customer_home.dart';
import 'package:workforce/screens/customer_orders/customer_in_progress_or_completed_orders.dart';
import 'package:workforce/screens/customer_orders/customer_cancelled_orders.dart';
import 'package:workforce/screens/customer_orders/customer_order_new.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';

final List<String> imgList = [
  "images/customer_home/carpenter.jpg",
  "images/customer_home/electrician.jpg",
  "images/customer_home/mechanic.jpg",
  "images/customer_home/plumber.jpg",
  "images/customer_home/sofa_cleaning.jpg",
  "images/customer_home/women_hair_cut_and_styling.jpg",
];

List<String> listPathsLabels = [
  "Carpenter",
  "Electrician",
  "Mechanic",
  "Plumber",
  "Sofa Cleaning",
  "Women's Hair Cut and Spa"
];

class CustomerOrderStatus extends StatefulWidget {
  CustomerOrderStatus({this.uid});
  // final String uid;
  final String uid;
  @override
  State<StatefulWidget> createState() => CustomerOrderStatusState(uid);
}

class CustomerOrderStatusState extends State {
// class CustomerHome extends StatelessWidget {
  final CarouselController _controller = CarouselController();
  String uid;
  final String title = "Customer Home";
  final List<Map<dynamic, dynamic>> lists = [];
  CustomerOrderStatusState(String uid) {
    this.uid = uid;
  }
  int _current = 0;
  int selectedIndex = 0;
  // int currentPos = 0;
  @override
  Widget build(BuildContext context) {
    int imageCount = (imgList.length / 2).round();
    List<int> list = [1, 2, 3, 4, 5];
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              body: (selectedIndex == 0
                  ? CustomerHome(uid: uid)
                  : (selectedIndex == 1
                      ? PlaceOrder(
                          uid: uid,
                        )
                      : (selectedIndex == 2
                          ? CustomerNewOrders(uid: uid)
                          : (selectedIndex == 3
                              ? CustomerInProgressOrCompletedOrders(
                                  uid: uid, status: "In Progress")
                              : CustomerInProgressOrCompletedOrders(
                                  uid: uid, status: "Completed"))))),
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
                    iconData: Icons.add_shopping_cart_outlined,
                    label: 'Place Order',
                  ),
                  // FFNavigationBarItem(
                  //   iconData: Icons.timer,
                  //   label: 'Status',
                  // ),
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
            )));
  }
}
