import 'package:flutter/material.dart';
import 'package:klimate/services/weather.dart';

@immutable
class City {
  final String city;
  final String country;
  final String? state;

  const City({
    required this.city,
    required this.country,
    this.state,
  });
}

Future<List<City>> allCities(String cityName) async {
  return Future<List<City>>.delayed(const Duration(milliseconds: 300), () async {
    List<City> result = [];
    List Cities = await getAllCities(cityName);
    for (final name in Cities) {
      City newCity = City(
        city: name["name"],
        country: name["country"],
        state: name["state"],
      );
      result.add(newCity);
    }

    return result;
  });
}
