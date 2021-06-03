import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/tabs/subtabs/bottom_navigation.dart';
import 'package:workforce/screens/tabs/subtabs/tab_item.dart';
import 'package:workforce/screens/customer_orders/place_order.dart';
import 'package:workforce/customer_home.dart';
import 'package:workforce/screens/customer_orders/customer_in_progress_or_completed_orders.dart';
import 'package:workforce/screens/customer_orders/customer_order_new.dart';

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
  var _currentTab = TabItem.home;
  final _navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.placeOrder: GlobalKey<NavigatorState>(),
    TabItem.newOrder: GlobalKey<NavigatorState>(),
    TabItem.inProgress: GlobalKey<NavigatorState>(),
    TabItem.completed: GlobalKey<NavigatorState>(),
  };

  void _selectTab(TabItem tabItem) {
    if (tabItem == _currentTab) {
      _navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  CustomerOrderStatusState(String uid) {
    this.uid = uid;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentTab].currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentTab != TabItem.home) {
            _selectTab(TabItem.home);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          _buildOffstageNavigator(TabItem.home),
          _buildOffstageNavigator(TabItem.placeOrder),
          _buildOffstageNavigator(TabItem.newOrder),
          _buildOffstageNavigator(TabItem.inProgress),
          _buildOffstageNavigator(TabItem.completed),
        ]),
        bottomNavigationBar: BottomNavigation(
          currentTab: _currentTab,
          onSelectTab: _selectTab,
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    return Offstage(
      offstage: _currentTab != tabItem,
      child: (tabItem == TabItem.home
          ? CustomerHome(uid: uid)
          : (tabItem == TabItem.placeOrder
              ? PlaceOrder(
                  uid: uid,
                )
              : (tabItem == TabItem.newOrder
                  ? CustomerNewOrders(uid: uid)
                  : (tabItem == TabItem.inProgress
                      ? CustomerInProgressOrCompletedOrders(
                          uid: uid, status: "In Progress")
                      : CustomerInProgressOrCompletedOrders(
                          uid: uid, status: "Completed"))))),
    );
  }
}
