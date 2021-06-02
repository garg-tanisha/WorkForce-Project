// import 'package:workforce/screens/customer_orders/place_order.dart';
// import 'package:workforce/customer_home.dart';
// import 'package:workforce/screens/customer_orders/customer_in_progress_or_completed_orders.dart';
// import 'package:workforce/screens/customer_orders/customer_cancelled_orders.dart';
// import 'package:workforce/screens/customer_orders/customer_order_new.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:ff_navigation_bar/ff_navigation_bar.dart';
// import 'package:workforce/screens/tabs/tabItem.dart';
// import 'package:workforce/screens/tabs/bottomNavigation.dart';

// class CustomerOrderStatus extends StatefulWidget {
//   CustomerOrderStatus({this.uid});
//   // final String uid;
//   final String uid;
//   @override
//   State<StatefulWidget> createState() => CustomerOrderStatusState(uid);
// }

// class CustomerOrderStatusState extends State {
//   final CarouselController _controller = CarouselController();
//   String uid;
//   final String title = "Customer Home";
//   final List<Map<dynamic, dynamic>> lists = [];
//   CustomerOrderStatusState(String uid) {
//     this.uid = uid;
//     tabs = [
//       TabItem(
//         tabName: "Home",
//         icon: Icons.home,
//         page: CustomerHome(uid: uid),
//       ),
//       TabItem(
//           tabName: "Place Order",
//           icon: Icons.add_shopping_cart_outlined,
//           page: PlaceOrder(
//             uid: uid,
//           )),
//       TabItem(
//           tabName: "New Order",
//           icon: Icons.shopping_cart_outlined,
//           page: CustomerNewOrders(uid: uid)),
//       TabItem(
//           tabName: "In Progress Order",
//           icon: Icons.hourglass_top_outlined,
//           page: CustomerInProgressOrCompletedOrders(
//               uid: uid, status: "In Progress")),
//       TabItem(
//           tabName: "Completed Order",
//           icon: Icons.check_circle_outline,
//           page: CustomerInProgressOrCompletedOrders(
//               uid: uid, status: "Completed")),
//     ];

//     tabs.asMap().forEach((index, details) {
//       details.setIndex(index);
//     });
//   }
//   int selectedIndex = 0;
//   static int currentTab = 0;
//   List<TabItem> tabs;
//   void _selectTab(int index) {
//     if (index == currentTab) {
//       tabs[index].key.currentState.popUntil((route) => route.isFirst);
//     } else {
//       setState(() => currentTab = index);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         final isFirstRouteInCurrentTab =
//             !await tabs[currentTab].key.currentState.maybePop();
//         if (isFirstRouteInCurrentTab) {
//           if (currentTab != 0) {
//             _selectTab(0);
//             return false;
//           }
//         }
//         return isFirstRouteInCurrentTab;
//       },
//       child: Scaffold(
//         body: IndexedStack(
//           index: currentTab,
//           children: tabs.map((e) => e.page).toList(),
//         ),
//         bottomNavigationBar: BottomNavigation(
//           onSelectTab: _selectTab,
//           tabs: tabs,
//         ),
//          FFNavigationBar(
//           theme: FFNavigationBarTheme(
//             barBackgroundColor: Colors.blue,
//             unselectedItemLabelColor: Colors.white,
//             unselectedItemIconColor: Colors.white,
//             selectedItemBorderColor: Colors.blue,
//             selectedItemBackgroundColor: Colors.white,
//             selectedItemIconColor: Colors.blue,
//             selectedItemLabelColor: Colors.white,
//             showSelectedItemShadow: false,
//             barHeight: 60,
//           ),
//           selectedIndex: currentTab,
//           onSelectTab: (index) {
//             setState(() {
//               // currentTab = index;
//               _selectTab(index);
//               // selectedIndex = index;
//             });
//           },
//           items: [
//             FFNavigationBarItem(
//               iconData: Icons.home_outlined,
//               label: 'Home',
//             ),
//             FFNavigationBarItem(
//               iconData: Icons.add_shopping_cart_outlined,
//               label: 'Place Order',
//             ),
//             FFNavigationBarItem(
//               iconData: Icons.shopping_cart_outlined,
//               label: 'New ',
//             ),
//             FFNavigationBarItem(
//               iconData: Icons.hourglass_top_outlined,
//               label: 'Progress',
//             ),
//             FFNavigationBarItem(
//               iconData: Icons.check_circle_outline,
//               label: 'Done',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
