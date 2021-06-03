import 'package:workforce/utils/images_and_Labels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:workforce/screens/customer_orders/customer_order_status.dart';
import 'package:workforce/utils/images_and_Labels.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:workforce/screens/wsp_orders/wsp_order_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'main.dart';
import 'package:workforce/utils/widgets/preventive_measures_for_covid_19.dart';
import 'package:workforce/utils/widgets/contact_us.dart';
import 'package:workforce/utils/widgets/services.dart';
import 'package:workforce/utils/widgets/wsp_drawer.dart';

class InDemandServices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width.roundToDouble(),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.all(
            Radius.circular(5.0) //                 <--- border radius here
            ),
      ),
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Text("In Demand Services",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          ),
        ),
        Services(),
      ]),
    );
  }
}

class Services extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int imageCount = (imgList.length / 2).round();
    return Container(
        margin: const EdgeInsets.all(10.0),
        child: CarouselSlider.builder(
          options: CarouselOptions(
            aspectRatio: 2.0,
            enlargeCenterPage: false,
            viewportFraction: 1,
          ),
          itemCount: imageCount,
          itemBuilder: (context, index) {
            final int first = index * 2;
            int second;
            imgList.length % 2 == 0
                ? (second = index <= imageCount - 1 ? first + 1 : null)
                : (second = index < imageCount - 1 ? first + 1 : null);
            return Row(
              children: [first, second].map((idx) {
                return idx != null
                    ? Expanded(
                        flex: 1,
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Stack(children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(imgList[idx],
                                    width: 1000.0,
                                    height: 700.0,
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Container(
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(
                                            10.0) //                 <--- border radius here
                                        ,
                                        bottomRight: Radius.circular(
                                            10.0) //                 <--- border radius here
                                        ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Text(
                                    listPathsLabels[idx],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ])))
                    : Container();
              }).toList(),
            );
          },
        ));
  }
}
