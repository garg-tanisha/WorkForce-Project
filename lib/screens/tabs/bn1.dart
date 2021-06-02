// import 'package:ff_navigation_bar/ff_navigation_bar.dart';
// import 'package:ff_navigation_bar/ff_navigation_bar.dart';
// import 'app.dart';
// import 'package:flutter/material.dart';
// import 'tabItem.dart';

// class BottomNavigation extends StatelessWidget {
//   BottomNavigation({
//     this.onSelectTab,
//     this.tabs,
//   });
//   final ValueChanged<int> onSelectTab;
//   final List<TabItem> tabs;

//   @override
//   Widget build(BuildContext context) {
//     return FFNavigationBar(
//         theme: FFNavigationBarTheme(
//           barBackgroundColor: Colors.blue,
//           unselectedItemLabelColor: Colors.white,
//           unselectedItemIconColor: Colors.white,
//           selectedItemBorderColor: Colors.blue,
//           selectedItemBackgroundColor: Colors.white,
//           selectedItemIconColor: Colors.blue,
//           selectedItemLabelColor: Colors.white,
//           showSelectedItemShadow: false,
//           barHeight: 60,
//         ),
//         selectedIndex: onSelectTab,
//         onSelectTab: (index) {
//           onSelectTab(
//             index,
//           );
//         },
//         items: [
//           FFNavigationBarItem(
//             iconData: Icons.home_outlined,
//             label: 'Home',
//           ),
//           FFNavigationBarItem(
//             iconData: Icons.timer,
//             label: 'Status',
//           ),
//           FFNavigationBarItem(
//             iconData: Icons.shopping_cart_outlined,
//             label: 'New ',
//           ),
//           FFNavigationBarItem(
//             iconData: Icons.hourglass_top_outlined,
//             label: 'Progress',
//           ),
//           FFNavigationBarItem(
//             iconData: Icons.check_circle_outline,
//             label: 'Done',
//           ),
//         ]);
//     //   ,B;ttomNavigationBar(
//     //   type: BottomNavigationBarType.fixed,
//     //   items: tabs
//     //       .map(
//     //         (e) => _buildItem(
//     //           index: e.getIndex(),
//     //           icon: e.icon,
//     //           tabName: e.tabName,
//     //         ),
//     //       )
//     //       .toList(),
//     //   onTap: (index) => onSelectTab(
//     //     index,
//     //   ),
//     // );
//   }

//   FFNavigationBarItem _buildItem({int index, IconData icon, String tabName}) {
//     return FFNavigationBarItem(
//       iconData: icon,
//       // ignore: deprecated_member_use
//       label: tabName,
//     );
//   }
// }
