import 'package:flutter/material.dart';

import 'keys.dart';
import 'networking.dart';

@immutable
class City {
  final String city;
  final String country;
  final String? state;
  final num lat;
  final num long;

  const City({
    required this.city,
    required this.country,
    this.state,
    required this.lat,
    required this.long,
  });
}

Future<List<City>> allCities(String pattern) async {
  return Future<List<City>>.delayed(const Duration(milliseconds: 300), () async {
    List<City> result = [];
    List Cities = await getAllCities(pattern);
    for (final data in Cities) {
      City newCity = City(
        city: data["name"],
        country: data["country"],
        state: data["state"],
        lat: data["lat"],
        long: data["lon"],
      );
      result.add(newCity);
    }
    final orderedResult = result.where((city) {
      final cityNameLower = city.city.toLowerCase().split(' ').join('');
      final patternNameLower = pattern.toLowerCase().split(' ').join('');
      return cityNameLower.contains(patternNameLower);
    }).toList();
    return orderedResult;
  });
}

Future<dynamic> getAllCities(String cityName) async {
  if (cityName.isEmpty) {
    cityName = " ";
  }

  NetworkHelper networkHelper = NetworkHelper("https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=5&appid=$apiKey");

  var weatherData = await networkHelper.getData();
  return weatherData!;
}
