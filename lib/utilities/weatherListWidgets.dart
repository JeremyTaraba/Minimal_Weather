import 'package:flutter/material.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/helper_functions.dart';

import 'WeatherData.dart';

class WeatherTile {
  int twentyFourHour = 0;
  int condition = 0;
  int temp = 0;

  WeatherTile(this.twentyFourHour, this.condition, this.temp);

  Column _generateTile() {
    return Column(
      children: [
        Text(
          getTimeWithAMPM(twentyFourHour, 0),
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

List createWeatherTiles() {
  List weatherTiles = [];
  // for 24 time (hours)
  // create a weather tile with time, icon, and temp
  // append it to list
  var hourly = global_HourlyWeatherData["hourly"];

  for (int i = 0; i < 24; i++) {
    int epochTime = hourly[i]["dt"];
    var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);

    WeatherTile temp = WeatherTile(date.hour, hourly[i]["weather"][0]["id"], hourly[i]["temp"].toInt());
    weatherTiles.add(temp._generateTile());
  }
  return weatherTiles;
}
