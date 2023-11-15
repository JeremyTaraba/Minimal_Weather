import 'package:flutter/material.dart';

import 'WeatherData.dart';

class WeatherTile {
  int hour = 0;
  String condition = "";
  int temp = 0;

  WeatherTile(this.hour, this.condition, this.temp);

  Column _generateTile() {
    return Column(
      children: [
        Text(
          hour.toString() + ":00",
          style: TextStyle(color: Colors.black),
        ),
        Icon(
          Icons.sunny,
          color: Colors.orange,
          size: 50,
        ),
        Text(temp.toString(), style: TextStyle(color: Colors.black)),
      ],
    );
  }
}

List createWeatherTiles(WeatherData currentWeather) {
  List weatherTiles = [];
  // for 24 time (hours)
  // create a weather tile with time, icon, and temp
  // append it to list

  for (int i = 0; i < 24; i++) {
    WeatherTile temp = WeatherTile(11, "sunny", 75);
    weatherTiles.add(temp._generateTile());
  }
  return weatherTiles;
}
