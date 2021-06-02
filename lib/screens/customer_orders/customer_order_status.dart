import 'package:workforce/screens/customer_orders/place_order.dart';
import 'package:workforce/customer_home.dart';
import 'package:workforce/screens/customer_orders/customer_in_progress_or_completed_orders.dart';
import 'package:workforce/screens/customer_orders/customer_cancelled_orders.dart';
import 'package:workforce/screens/customer_orders/customer_order_new.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:workforce/screens/tabs/tabItem.dart';
import 'package:workforce/screens/tabs/screens.dart';
import 'package:workforce/screens/tabs/subtabs/app.dart';
import 'package:workforce/screens/tabs/bottomNavigation.dart';

class CustomerOrderStatus extends StatefulWidget {
  CustomerOrderStatus({this.uid});
  // final String uid;
  final String uid;
  @override
  State<StatefulWidget> createState() => CustomerOrderStatusState(uid);
}

class CustomerOrderStatusState extends State {
  final CarouselController _controller = CarouselController();
  String uid;
  final String title = "Customer Home";
  final List<Map<dynamic, dynamic>> lists = [];
  // int selectedIndex = 0;
  // this is static property so other widget throughout the app
  // can access it simply by AppState.currentTab
  static int currentTab = 0;

  // list tabs here
  final List<TabItem> tabs = [
    TabItem(
      tabName: "Home",
      icon: Icons.home,
      page: HomeScreen(),
    ),
    TabItem(
      tabName: "Settings",
      icon: Icons.settings,
      page: SettingsScreen(),
    ),
  ];
  CustomerOrderStatusState(String uid) {
    this.uid = uid;

    tabs.asMap().forEach((index, details) {
      details.setIndex(index);
    });
  }

  // sets current tab index
  // and update state
  void _selectTab(int index) {
    if (index == currentTab) {
      // pop to first route
      // if the user taps on the active tab
      tabs[index].key.currentState.popUntil((route) => route.isFirst);
    } else {
      // update the state
      // in order to repaint
      setState(() => currentTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return App();
    // WillPopScope handle android back btn
    // return WillPopScope(
    //   onWillPop: () async {
    //     final isFirstRouteInCurrentTab =
    //         !await tabs[currentTab].key.currentState.maybePop();
    //     if (isFirstRouteInCurrentTab) {
    //       // if not on the 'main' tab
    //       if (currentTab != 0) {
    //         // select 'main' tab
    //         _selectTab(0);
    //         // back button handled by app
    //         return false;
    //       }
    //     }
    //     // let system handle back button if we're on the first route
    //     return isFirstRouteInCurrentTab;
    //   },
    //   // this is the base scaffold
    //   // don't put appbar in here otherwise you might end up
    //   // with multiple appbars on one screen
    //   // eventually breaking the app
    //   child: Scaffold(
    //     // indexed stack shows only one child
    //     body: IndexedStack(
    //       index: currentTab,
    //       children: tabs.map((e) => e.page).toList(),
    //     ),
    //     // Bottom navigation
    //     bottomNavigationBar: BottomNavigation(
    //       onSelectTab: _selectTab,
    //       tabs: tabs,
    //     ),
    //   ),
    // );
  }
}
