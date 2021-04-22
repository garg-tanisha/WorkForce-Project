import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:places_autocomplete/src/blocs/application_bloc.dart';
import 'package:workforce/screens/userLocation/models/place.dart';
import 'package:provider/provider.dart';

import 'application_bloc.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription locationSubscription;

  @override
  void initState() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _goToPlace(place);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);

    applicationBloc.dispose();
    locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);

    return Scaffold(
        body: (applicationBloc.currentLocation == null)
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Search Location',
                          suffixIcon: Icon(Icons.search)),
                      onChanged: (value) => applicationBloc.searchPlaces(value),
                    ),
                  ),
                  Stack(
                    children: [
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
                          onMapCreated: (GoogleMapController controller) {
                            _mapController.complete(controller);
                          },
                        ),
                      ),
                      if (applicationBloc.searchResults != null &&
                          applicationBloc.searchResults.length != 0)
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.6),
                              backgroundBlendMode: BlendMode.darken),
                        ),
                      Container(
                          height: 300,
                          child: ListView.builder(
                            itemCount: applicationBloc.searchResults.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                    applicationBloc
                                        .searchResults[index].description,
                                    style: TextStyle(color: Colors.white)),
                                onTap: () {
                                  applicationBloc.setSelectedLocation(
                                      applicationBloc
                                          .searchResults[index].placeId);
                                },
                              );
                            },
                          )),
                    ],
                  ),
                ],
              ));
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 14)));
  }
}
