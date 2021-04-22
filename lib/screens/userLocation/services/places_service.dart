import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:workforce/screens/userLocation/models/place.dart';
import 'package:workforce/screens/userLocation/models/place_search.dart';

class PlacesService {
  final key = 'AIzaSyB5S5-CwfvowRaBgBXQwGQT0LuCgiUWaiw';

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&key=$key';
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }
}

// "accounting
// "airport
// "amusement_park
// "aquarium
// "art_gallery

// "atm
// "bakery
// "bank
// "bar
// "beauty_salon
// "bicycle_store
// "book_store
// "bowling_alley
// "bus_station
// "cafe
// "campground
// "car_dealer
// "car_rental
// "car_repair
// "car_wash
// "casino
// "cemetery
// "church
// city_hall
// clothing_store
// convenience_store
// courthouse
// dentist
// department_store
// doctor
// drugstore
// electrician
// electronics_store
// embassy
// fire_station
// florist
// funeral_home
// furniture_store
// gas_station
// gym
// hair_care
// hardware_store
// hindu_temple
// home_goods_store
// hospital
// insurance_agency
// jewelry_store
// laundry
// lawyer
// library
// light_rail_station
// liquor_store
// local_government_office
// locksmith
// lodging
// meal_delivery
// meal_takeaway
// mosque
// movie_rental
// movie_theater
// moving_company
// museum
// night_club
// painter
// park
// parking
// pet_store
// pharmacy
// physiotherapist
// plumber
// police
// post_office
// primary_school
// real_estate_agency
// restaurant
// roofing_contractor
// rv_park
// school
// secondary_school
// shoe_store
// shopping_mall
// spa
// stadium
// storage
// store
// subway_station
// "supermarket
// "synagogue
// "taxi_stand
// "tourist_attraction","train_station","transit_station",
// "travel_agency",
// "university",
// "veterinary_care","zoo"]
