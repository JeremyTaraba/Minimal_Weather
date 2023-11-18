import 'package:flutter/material.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/helper_functions.dart';

import 'WeatherData.dart';
import 'custom_icons.dart';

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
        Text("${temp.toString()}°", style: TextStyle(color: Colors.black)),
      ],
    );
  }
}

List createWeatherTiles() {
  List weatherTiles = [];
  var hourly = global_HourlyWeatherData["hourly"];

  for (int i = 0; i < 24; i++) {
    int epochTime = hourly[i]["dt"];
    var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);

    WeatherTile temp = WeatherTile(date.hour, hourly[i]["weather"][0]["id"], hourly[i]["temp"].toInt());
    weatherTiles.add(temp._generateTile());
  }
  return weatherTiles;
}

class WeatherBanner {
  int weekDay; //1 = Monday, 7 = Sunday
  int condition = 0;
  int minTemp = 0;
  int maxTemp = 0;

  WeatherBanner(this.weekDay, this.condition, this.minTemp, this.maxTemp);

  Row _generateBanner() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            getDayFromWeekday(weekDay),
            style: TextStyle(color: Colors.black),
          ),
        ),
        Flexible(child: Container()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
          child: Icon(
            Icons.sunny,
            color: Colors.orange,
            size: 40,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("${maxTemp}°/${minTemp}°", style: TextStyle(color: Colors.black)),
        )
      ],
    );
  }
}

List createWeatherBanners() {
  List weatherBanners = [];

  var daily = global_HourlyWeatherData["daily"];

  for (int i = 0; i < 8; i++) {
    int epochTime = daily[i]["dt"];
    var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    WeatherBanner temp = WeatherBanner(
      i == 0 ? 0 : date.weekday,
      daily[i]["weather"][0]["id"].toInt(),
      daily[i]["temp"]["min"].toInt(),
      daily[i]["temp"]["max"].toInt(),
    );
    weatherBanners.add(temp._generateBanner());
  }
  return weatherBanners;
}

Card createSunriseSunset() {
  return Card(
    color: Colors.white,
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              CustomIcons.sunrise,
              color: Color(0xFFEFE79F),
              size: 25,
            ),
            Text(global_CurrentWeatherData["sys"]["sunrise"]),
          ],
        ),
        Row(
          children: [
            Icon(
              CustomIcons.sunset,
              color: Color(0xFFFFB852),
              size: 25,
            ),
            Text("8:00"),
          ],
        )
      ],
    ),
  );
}
