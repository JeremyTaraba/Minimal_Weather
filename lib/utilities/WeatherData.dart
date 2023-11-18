import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:klimate/services/global_variables.dart';

import '../services/weather.dart';
import 'helper_functions.dart';

class WeatherData {
  late WeatherModel weather;
  late DateTime writeTime;
  int temperature = 0;
  int condition = 0;
  String cityName = "";
  String description = "";
  late DateTime time;
  int timeHour = 0;
  int timeMinute = 0; //do we need these?
  String enteredLocation = "";
  int sunsetHour = 0;
  int sunriseHour = 1;
  int sunsetMinute = 0;
  int sunriseMinute = 0;
  late DateTime sunrise;
  late DateTime sunset;
  int highTemp = 0;
  int lowTemp = 0;
  late AssetImage background;
  List weatherBanners = [];
  List weatherTiles = [];

  WeatherData() {
    // sets all the variables we need
    writeTime = DateTime.now();
    temperature = global_CurrentWeatherData['main']['temp'].toInt();
  }

  void updateUI(dynamic weatherData) {
    if (weatherData == null) {
      temperature = 0;
      cityName = "";
      description = "Oops! Could not locate weather for '$enteredLocation'";
      time = DateTime.now();
      weather = WeatherModel(condition: 1000, hour: 0, sunset: 0, sunrise: 1);

      return;
    }

    temperature = weatherData['main']['temp'].toInt();
    highTemp = weatherData['main']['temp_max'].toInt();
    lowTemp = weatherData['main']['temp_min'].toInt();
    condition = weatherData['weather'][0]['id'];
    cityName = weatherData['name'];
    description = weatherData["weather"][0]["description"];
    int timezone = weatherData['timezone'];
    DateTime localTime = DateTime.now().add(Duration(seconds: timezone - DateTime.now().timeZoneOffset.inSeconds));
    timeHour = localTime.hour;
    var timeSunrise = DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunrise'] * 1000);
    var timeSunset = DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunset'] * 1000);
    sunrise = timeSunrise.add(Duration(seconds: timezone - timeSunrise.timeZoneOffset.inSeconds));
    sunriseHour = sunrise.hour;
    sunriseMinute = sunrise.minute;
    sunset = timeSunset.add(Duration(seconds: timezone - timeSunrise.timeZoneOffset.inSeconds));
    sunsetHour = sunset.hour;
    sunsetMinute = sunset.minute;
    timeMinute = localTime.minute;
    weather = WeatherModel(condition: condition, hour: timeHour, sunrise: sunriseHour, sunset: sunsetHour);
  }
}

// writes data to the file
Future<File> writeWeatherData(var weatherJson) async {
  final file = await localFile;
  DateTime writeTime = DateTime.now();

  // Write the file
  return file.writeAsString('$writeTime \n $weatherJson');
}

// reads data from the file
Future<String> readWeatherData() async {
  try {
    final file = await localFile;

    // Read the file
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error
    print("Error reading local file: $e");
    return "Error";
  }
}
