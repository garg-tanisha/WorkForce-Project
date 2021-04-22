import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'geolocator_service.dart';
// import 'package:places_autocomplete/src/models/geometry.dart';
// import 'package:places_autocomplete/src/models/location.dart';
// import 'package:places_autocomplete/src/models/place.dart';
// import 'package:places_autocomplete/src/models/place_search.dart';
// import 'package:places_autocomplete/src/services/marker_service.dart';
// import 'package:places_autocomplete/src/services/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final geoLocatorService = GeolocatorService();

  //Variables
  Position currentLocation;

  ApplicationBloc() {
    setCurrentLocation();
  }

  setCurrentLocation() async {
    currentLocation = await geoLocatorService.getCurrentLocation();
    notifyListeners();
  }
}
