import 'dart:async';
import 'package:location/location.dart';
import 'package:workforce/email_signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workforce/screens/location_tracking/models/place.dart';
import 'package:provider/provider.dart';
import 'package:workforce/screens/customer_orders/place_order.dart';
import 'application_bloc.dart';

typedef void StringCallback(String val);

class MapsScreen extends StatefulWidget {
  final StringCallback callback;

  MapsScreen({Key key, this.tableName, this.callback}) : super(key: key);
  final String tableName;
  @override
  _MapsScreenState createState() => _MapsScreenState(tableName);
}

class _MapsScreenState extends State<MapsScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription locationSubscription;
  StreamSubscription boundsSubscription;
  String tableName;

  _MapsScreenState(String tableName) {
    this.tableName = tableName;
  }
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
                        height: 400,
                        child: GoogleMap(
                          mapType: MapType.hybrid,
                          markers: Set<Marker>.of(applicationBloc.markers),
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  applicationBloc.currentLocation.latitude,
                                  applicationBloc.currentLocation.longitude),
                              zoom: 14),
                          onMapCreated: (GoogleMapController controller) async {
                            _mapController.complete(controller);
                            Location _locationTracker = Location();
                            var newLocalData =
                                await _locationTracker.getLocation();
                            print(newLocalData.latitude.toString() +
                                " " +
                                newLocalData.longitude.toString());
                            if (tableName == 'users') {
                              EmailSignUp.of(context).location = LatLng(
                                      newLocalData.latitude,
                                      newLocalData.longitude)
                                  .toString();
                            } else if (tableName == 'orders') {
                              PlaceOrder.of(context).location = LatLng(
                                      newLocalData.latitude,
                                      newLocalData.longitude)
                                  .toString();
                            }
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
                ],
              ));
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 14)));

    if (tableName == 'users') {
      EmailSignUp.of(context).location =
          LatLng(place.geometry.location.lat, place.geometry.location.lng)
              .toString();
    } else if (tableName == 'orders') {
      PlaceOrder.of(context).location =
          LatLng(place.geometry.location.lat, place.geometry.location.lng)
              .toString();
    }
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
}
