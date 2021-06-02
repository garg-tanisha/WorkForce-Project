import 'package:flutter/material.dart';

enum TabItem { home, placeOrder, newOrder, inProgress, completed }

const Map<TabItem, String> tabName = {
  TabItem.home: 'Home',
  TabItem.placeOrder: 'Place Order',
  TabItem.newOrder: 'New',
  TabItem.inProgress: 'In Progress',
  TabItem.completed: 'Done'
};

const Map<TabItem, MaterialColor> activeTabColor = {
  TabItem.home: Colors.red,
  TabItem.placeOrder: Colors.green,
  TabItem.newOrder: Colors.blue,
  TabItem.inProgress: Colors.green,
  TabItem.completed: Colors.blue,
};
