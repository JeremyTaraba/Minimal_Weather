import 'package:flutter/material.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/helper_functions.dart';

import 'WeatherData.dart';
import 'custom_icons.dart';

class WeatherTile {
  int twentyFourHour = 0;
  int condition = 0;
  double temp = 0;

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
        convertTempUnits(
          temp: temp,
          textStyle: TextStyle(color: Colors.black),
        ),
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

    WeatherTile temp = WeatherTile(date.hour, hourly[i]["weather"][0]["id"], (hourly[i]["temp"]));
    weatherTiles.add(temp._generateTile());
  }
  return weatherTiles;
}

class WeatherBanner {
  int weekDay; //1 = Monday, 7 = Sunday
  int condition = 0;
  double minTemp = 0;
  double maxTemp = 0;

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
          child: Row(
            children: [
              convertTempUnits(
                temp: maxTemp,
                textStyle: TextStyle(color: Colors.black),
              ),
              Text(
                "/",
                style: TextStyle(color: Colors.black),
              ),
              convertTempUnits(
                temp: minTemp,
                textStyle: TextStyle(color: Colors.black),
              ),
            ],
          ),
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
      daily[i]["temp"]["min"],
      daily[i]["temp"]["max"],
    );
    weatherBanners.add(temp._generateBanner());
  }
  return weatherBanners;
}

Card createSunriseSunset(WeatherData currentWeather) {
  return Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Sunrise",
                style: TextStyle(color: Colors.black),
              ),
              Icon(
                CustomIcons.sunrise,
                color: Colors.orangeAccent,
                size: 40,
              ),
              Text("${getLocalTime(currentWeather.sunrise.hour, currentWeather.sunrise.minute)} ${getAMPM(currentWeather.sunrise.hour)}",
                  style: TextStyle(color: Colors.black)),
            ],
          ),
          Row(
            children: [
              Text(
                "Sunset",
                style: TextStyle(color: Colors.black),
              ),
              Icon(
                CustomIcons.sunset,
                color: Colors.blue,
                size: 40,
              ),
              Text(
                "${getLocalTime(currentWeather.sunset.hour, currentWeather.sunset.minute)} ${getAMPM(currentWeather.sunset.hour)}",
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
        ],
      ),
    ),
  );
}

Card createHumidity(WeatherData currentWeather) {
  return Card(
    color: Colors.white,
    child: Column(
      children: [
        Text(
          "Humidity",
          style: TextStyle(color: Colors.black),
        ),
        Icon(
          Icons.water_drop,
          color: Colors.blue,
          size: 40,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${currentWeather.humidity}%",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

Card createWind(WeatherData currentWeather) {
  return Card(
    color: Colors.white,
    child: Column(
      children: [
        Text(
          "Wind",
          style: TextStyle(color: Colors.black),
        ),
        Icon(
          Icons.air,
          color: Colors.lightBlueAccent,
          size: 40,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: convertSpeedUnits(
            speed: currentWeather.windSpeed,
            textStyle: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

Card createUVIndex(WeatherData currentWeather) {
  return Card(
    color: Colors.white,
    child: Column(
      children: [
        Text(
          "UV Index",
          style: TextStyle(color: Colors.black),
        ),
        Icon(
          Icons.brightness_7_outlined,
          color: Colors.purpleAccent,
          size: 40,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${currentWeather.uvIndex}",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
