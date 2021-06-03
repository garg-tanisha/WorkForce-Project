import 'package:workforce/utils/methods/images.dart';
import 'package:workforce/utils/widgets/preventive_measures_for_covid_19.dart';
import 'package:workforce/utils/images_and_Labels.dart';
import 'package:workforce/screens/chat/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

Widget images(var _images) {
  List<Widget> list = new List<Widget>();

  for (var i = 0; i < _images.length; i += 2) {
    if (i + 1 >= _images.length) {
      list.add(Row(children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black12,
                      ),
                    ),
                    child: Image.network(_images[i],
                        width: 100, height: 100, fit: BoxFit.fill))))
      ]));
    } else {
      list.add(Row(children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black12,
                      ),
                    ),
                    child: Image.network(_images[i],
                        width: 100, height: 100, fit: BoxFit.fill)))),
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black12,
                      ),
                    ),
                    child: Image.network(_images[i + 1],
                        width: 100, height: 100, fit: BoxFit.fill))))
      ]));
    }
  }
  ;

  return new Column(children: list);
}

Widget images__(List<File> _images) {
  List<Widget> list = new List<Widget>();

  for (var i = 0; i < _images.length; i += 2) {
    if (i + 1 >= _images.length) {
      list.add(Row(children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black12,
                      ),
                    ),
                    child: Image.file(
                      _images[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.fill,
                    ))))
      ]));
    } else {
      list.add(Row(children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black12,
                      ),
                    ),
                    child: Image.file(
                      _images[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.fill,
                    )))),
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black12,
                      ),
                    ),
                    child: Image.file(
                      _images[i + 1],
                      width: 100,
                      height: 100,
                      fit: BoxFit.fill,
                    ))))
      ]));
    }
  }
  ;

  return new Column(children: list);
}
