import 'package:flutter/material.dart';
import 'package:workforce/screens/wsp_orders/wsp_in_progress_orders.dart';
import 'wsp_new_orders.dart';
import 'package:workforce/screens/wsp_orders/order_confirmations.dart';
import 'wsp_completed_orders.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
final List<Widget> imageSliders = imgList
    .map((item) => Container(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(item,
                          width: 1000.0, height: 700.0, fit: BoxFit.cover),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          listPathsLabels[imgList.indexOf(item)],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ))
    .toList();

class OrderHome extends StatefulWidget {
  OrderHome({this.uid, this.role});
  final String uid;
  final String role;
  @override
  State<StatefulWidget> createState() => OrderHomeState(uid, role);
}

class OrderHomeState extends State {
  String uid;
  String role;
  int _current = 0;
  OrderHomeState(String uid, String role) {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              items: imageSliders,
              options: CarouselOptions(
                  viewportFraction: 1,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.map((url) {
                int index = imgList.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              }).toList(),
            ),
            // Container(
            //     width: 0.98 * MediaQuery.of(context).size.width.roundToDouble(),
            //     decoration: BoxDecoration(
            //       border: Border.all(
            //         color: Colors.black12,
            //       ),
            //       color: Colors.white,
            //       borderRadius: BorderRadius.all(Radius.circular(
            //               5.0) //                 <--- border radius here
            //           ),
            //     ),
            //     child: Column(children: [
            //       Align(
            //         alignment: Alignment.centerLeft,
            //         child: Padding(
            //           padding: EdgeInsets.all(10.0),
            //           child: Text("Order's Status",
            //               style: TextStyle(
            //                   fontWeight: FontWeight.bold, fontSize: 16.0)),
            //         ),
            //       ),
            //       Card(
            //           color: Colors.white,
            //           elevation: 2.0,
            //           child: ListTile(
            //             leading: Icon(
            //               Icons.timer,
            //               color: Colors.blue,
            //               size: 30.0,
            //               semanticLabel: 'Order Confirmations Sent',
            //             ),
            //             trailing: Icon(
            //               Icons.arrow_right_outlined,
            //               color: Colors.blue,
            //               size: 40.0,
            //               semanticLabel: 'Right Arrow',
            //             ),
            //             title: Text("Order Confirmations Sent"),
            //             onTap: () {
            //               Navigator.push(
            //                   context,
            //                   //builder of MaterialPageRoute will call TodoDetail class
            //                   MaterialPageRoute(
            //                     builder: (context) => OrderConfirmationsSent(
            //                         uid: uid, role: role, flag: true),
            //                   ));
            //             },
            //           )),
            //       Card(
            //           color: Colors.white,
            //           elevation: 2.0,
            //           child: ListTile(
            //             leading: Icon(
            //               Icons.shopping_cart_outlined,
            //               color: Colors.blue,
            //               size: 30.0,
            //               semanticLabel: 'New Orders',
            //             ),
            //             trailing: Icon(
            //               Icons.arrow_right_outlined,
            //               color: Colors.blue,
            //               size: 40.0,
            //               semanticLabel: 'Right Arrow',
            //             ),
            //             title: Text("New"),
            //             onTap: () {
            //               Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     builder: (context) =>
            //                         Orders(uid: uid, role: role, flag: true),
            //                   ));
            //             },
            //           )),
            //       Card(
            //           color: Colors.white,
            //           elevation: 2.0,
            //           child: ListTile(
            //             leading: Icon(
            //               Icons.hourglass_top_outlined,
            //               color: Colors.blue,
            //               size: 30.0,
            //               semanticLabel: 'In Progress Orders',
            //             ),
            //             trailing: Icon(
            //               Icons.arrow_right_outlined,
            //               color: Colors.blue,
            //               size: 40.0,
            //               semanticLabel: 'Right Arrow',
            //             ),
            //             title: Text("In Progress"),
            //             onTap: () {
            //               Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     builder: (context) => WSPInProgressOrders(
            //                         uid: uid, role: role, flag: true),
            //                   ));
            //             },
            //           )),
            //       Card(
            //           color: Colors.white,
            //           elevation: 2.0,
            //           child: ListTile(
            //             leading: Icon(
            //               Icons.check_circle_outline,
            //               color: Colors.blue,
            //               size: 30.0,
            //               semanticLabel: 'Completed Orders',
            //             ),
            //             trailing: Icon(
            //               Icons.arrow_right_outlined,
            //               color: Colors.blue,
            //               size: 40.0,
            //               semanticLabel: 'Right Arrow',
            //             ),
            //             title: Text("Completed"),
            //             onTap: () {
            //               Navigator.push(
            //                   context,
            //                   //builder of MaterialPageRoute will call TodoDetail class
            //                   MaterialPageRoute(
            //                     builder: (context) => WSPCompletedOrders(
            //                         uid: uid, role: role, flag: true),
            //                   ));
            //             },
            //           )),
            //     ])),
            Container(
              width: MediaQuery.of(context).size.width.roundToDouble(),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(
                        5.0) //                 <--- border radius here
                    ),
              ),
              child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Preventive Measures To Fight Covid",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0)),
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              title: Text(
                                  "Wash your hands timely for atleast 30 seconds.",
                                  style: TextStyle(fontSize: 13.0)),
                              leading: Image.asset(imgList[0],
                                  width: 40.0, height: 40.0, fit: BoxFit.cover),
                            )),
                      ),
                      Expanded(
                        child: Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              title: Text(
                                  "Use soaps or alcohol based sanitizers.",
                                  style: TextStyle(fontSize: 13.0)),
                              leading: Image.asset(imgList[0],
                                  width: 40.0, height: 40.0, fit: BoxFit.cover),
                            )),
                      )
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              title: Text(
                                  "Do social distancing. Avoid any close contact with sick people.",
                                  style: TextStyle(fontSize: 13.0)),
                              leading: Image.asset(imgList[0],
                                  width: 40.0, height: 40.0, fit: BoxFit.cover),
                            )),
                      ),
                      Expanded(
                        child: Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              title: Text(
                                  "Avoid touching your nose, eyes or face with unclean hands.",
                                  style: TextStyle(fontSize: 13.0)),
                              leading: Image.asset(imgList[0],
                                  width: 40.0, height: 40.0, fit: BoxFit.cover),
                            )),
                      )
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                                title: Text(
                                    "Cover nose and mouth with mask. Sneeze/cough into your elbow.",
                                    style: TextStyle(fontSize: 13.0)),
                                leading: Image.asset(imgList[0],
                                    width: 40.0,
                                    height: 40.0,
                                    fit: BoxFit.cover))),
                      ),
                      Expanded(
                        child: Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: ListTile(
                              title: Text(
                                  "Isolation and social distancing are very important to stay safe.",
                                  style: TextStyle(fontSize: 13.0)),
                              leading: Image.asset(imgList[0],
                                  width: 40.0, height: 40.0, fit: BoxFit.cover),
                            )),
                      )
                    ]),
              ]),
            ),
            Container(
              width: MediaQuery.of(context).size.width.roundToDouble(),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        5.0) //                 <--- border radius here
                    ,
                    topRight: Radius.circular(
                        5.0) //                 <--- border radius here
                    ),
              ),
              child: Column(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset("images/customer_home/contact_us.jpg",
                      width: MediaQuery.of(context).size.width.roundToDouble(),
                      height: 0.25 *
                          MediaQuery.of(context).size.height.roundToDouble(),
                      fit: BoxFit.cover),
                ),
                Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: ListTile(
                      title: RichText(
                        text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                                text: 'For any questions or enquires '),
                            new TextSpan(
                                text: 'contact us or whatsapp us',
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold)),
                            new TextSpan(text: ' at 98xxxxxxxx'),
                          ],
                        ),
                      ),
                      leading: Icon(
                        Icons.call_outlined,
                        color: Colors.blue,
                        size: 30.0,
                        semanticLabel: 'Query',
                      ),
                    )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
