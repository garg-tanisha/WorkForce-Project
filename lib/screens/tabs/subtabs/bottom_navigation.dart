import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/tabs/subtabs/tab_item.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({@required this.currentTab, @required this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;
  // int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return FFNavigationBar(
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
      selectedIndex: currentTab.index,
      onSelectTab: (index) {
        // setState(() {
        onSelectTab(
          TabItem.values[index],
        );
      },
      // selectedIndex = index;

      items: [
        _buildItem(TabItem.red),
        _buildItem(TabItem.green),
        _buildItem(TabItem.blue), // FFNavigationBarItem(
        //   iconData: Icons.home_outlined,
        //   label: 'Home',
        // ),
        // FFNavigationBarItem(
        //   iconData: Icons.timer,
        //   label: 'Status',
        // ),
        // FFNavigationBarItem(
        //   iconData: Icons.shopping_cart_outlined,
        //   label: 'New ',
        // ),
        // FFNavigationBarItem(
        //   iconData: Icons.hourglass_top_outlined,
        //   label: 'Progress',
        // ),
        // FFNavigationBarItem(
        //   iconData: Icons.check_circle_outline,
        //   label: 'Done',
        // ),
      ],
      // )
      // ,BottomNavigationBar(
      // type: BottomNavigationBarType.fixed,
      // items: [
      //   _buildItem(TabItem.red),
      //   _buildItem(TabItem.green),
      //   _buildItem(TabItem.blue),
      // ],
      // onTap: (index) => onSelectTab(
      //   TabItem.values[index],
      // ),
    );
  }

  FFNavigationBarItem _buildItem(TabItem tabItem) {
    return FFNavigationBarItem(
      iconData: Icons.layers,
      label: tabName[tabItem],
    );
  }
}
