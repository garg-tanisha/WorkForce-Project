import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:places_autocomplete/src/blocs/application_bloc.dart';
// import 'package:places_autocomplete/src/models/place.dart';
import 'package:provider/provider.dart';

import 'application_bloc.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);

    return Scaffold(
        body: (applicationBloc.currentLocation == null)
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: 'Search Location'),
                  ),
                  Container(
                    height: 300,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(
                              applicationBloc.currentLocation.latitude,
                              applicationBloc.currentLocation.longitude),
                          zoom: 14),
                    ),
                  ),
                ],
              ));
  }
}
