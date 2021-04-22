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
  StreamSubscription boundsSubscription;

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

    boundsSubscription = applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    });
    super.initState();
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);

    applicationBloc.dispose();
    boundsSubscription.cancel();
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
                          markers: Set<Marker>.of(applicationBloc.markers),
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
                      if (applicationBloc.searchResults != null)
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Find Nearest',
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: [
                        FilterChip(
                          label: Text("Campground"),
                          onSelected: (val) => applicationBloc.togglePlaceType(
                              "campground", val),
                          selected: applicationBloc.placeType == 'campground',
                          selectedColor: Colors.blue,
                        ),
                        FilterChip(
                          label: Text("Bus Station"),
                          onSelected: (val) => applicationBloc.togglePlaceType(
                              "bus_station", val),
                          selected: applicationBloc.placeType == 'bus_station',
                          selectedColor: Colors.blue,
                        ),
                        FilterChip(
                          label: Text("ATM"),
                          onSelected: (val) =>
                              applicationBloc.togglePlaceType("atm", val),
                          selected: applicationBloc.placeType == 'atm',
                          selectedColor: Colors.blue,
                        ),
                        FilterChip(
                          label: Text("Park"),
                          onSelected: (val) =>
                              applicationBloc.togglePlaceType("park", val),
                          selected: applicationBloc.placeType == 'park',
                          selectedColor: Colors.blue,
                        ),
                        FilterChip(
                          label: Text("Zoo"),
                          onSelected: (val) =>
                              applicationBloc.togglePlaceType("zoo", val),
                          selected: applicationBloc.placeType == 'zoo',
                          selectedColor: Colors.blue,
                        )
                      ],
                    ),
                  )
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
