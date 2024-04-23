import 'dart:math';

import 'package:flutter/cupertino.dart';

class WeatherData {
  late DateTime writeTime;
  num temperature = 0;
  int condition = 0;
  String cityName = "";
  String description = "";
  late DateTime time;
  late DateTime sunrise;
  late DateTime sunset;
  double highTemp = 0;
  double lowTemp = 0;
  late AssetImage background;
  num humidity = 0;
  double windSpeed = 0;
  int uvIndex = 0;
  String currentIconNumber = "";
  List<String> dailyIconNumber = [];
  List<String> hourlyIconNumber = [];
  double long = 0.0;
  double lat = 0.0;
  List hourly = [];
  List daily = [];
  List forecastList = [];

  WeatherData() {
    //constructor
  }

  void setWeatherData(var data) {
    writeTime = DateTime.now();
    temperature = data["onecall"]["current"]["temp"];
    condition = data["onecall"]["current"]["weather"][0]["id"].toInt();
    cityName = data["forecast"]["city"]["name"];
    description = data["onecall"]["current"]["weather"][0]["description"];

    int epochTime = data["onecall"]["current"]["dt"];
    time = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    sunrise = DateTime.fromMillisecondsSinceEpoch(data["onecall"]['daily'][0]['sunrise'] * 1000);
    sunset = DateTime.fromMillisecondsSinceEpoch(data["onecall"]['daily'][0]['sunset'] * 1000);
    highTemp = data["onecall"]['daily'][0]['temp']["max"];
    lowTemp = data["onecall"]['daily'][0]['temp']["min"];
    background = _getBackground(condition, time.hour, sunrise.hour, sunset.hour);
    humidity = data["onecall"]["current"]["humidity"].toInt();
    windSpeed = double.parse(data["onecall"]["current"]["wind_speed"].toString());
    uvIndex = data["onecall"]["current"]["uvi"].toInt();
    currentIconNumber = data["onecall"]["current"]["weather"][0]["icon"];
    for (int i = 0; i < 24; i++) {
      hourlyIconNumber.add(data["onecall"]["hourly"][i]["weather"][0]["icon"]);
    }
    for (int i = 0; i < 7; i++) {
      dailyIconNumber.add(data["onecall"]["daily"][i]["weather"][0]["icon"]);
    }
    long = data["onecall"]["lon"];
    lat = data["onecall"]["lat"];
    hourly = data["onecall"]["hourly"]; // 48 hour info, hour by hour
    daily = data["onecall"]["daily"];
    forecastList = data["forecast"]["list"];
  }

  AssetImage _getBackground(int condition, int hour, int sunrise, int sunset) {
    int length = 1;
    Random random = Random();
    bool day = false;

    //if daytime
    if ((hour > sunrise) && (hour <= sunset)) {
      day = true;
    }
    if (condition < 300) {
      // thunderstorm

      return AssetImage("images/thunderstorm/1.jpg");
    } else if (condition < 400) {
      // drizzle

      length = random.nextInt(6) + 1;
      return AssetImage("images/rain/$length.jpg");
    } else if (condition < 600) {
      // rain

      length = random.nextInt(6) + 1;
      return AssetImage("images/rain/$length.jpg");
    } else if (condition < 700) {
      //snow
      if (condition == 611 || condition == 612 || condition == 613) {
        // sleet/hail

        length = random.nextInt(2) + 1;
        return AssetImage("images/hail/$length.jpg");
      } else {
        length = random.nextInt(4) + 1;
        return AssetImage("images/snow/$length.jpg");
      }
    } else if (condition < 800) {
      // atmosphere (fog, mist, smoke, haze)

      return AssetImage("images/atmosphere/1.jpg");
    } else if (condition == 800 || condition == 801) {
      // clear and mostly clear
      if (day) {
        length = random.nextInt(7) + 1;
        return AssetImage("images/clear/day/$length.jpg");
      } else {
        if (condition == 801) {
          length = random.nextInt(3) + 1;
          return AssetImage("images/mostlyClear/night/$length.jpg");
        } else {
          length = random.nextInt(5) + 1;
          return AssetImage("images/clear/night/$length.jpg");
        }
      }
    } else if (condition == 802) {
      //partly cloudy
      if (day) {
        length = random.nextInt(5) + 1;
        return AssetImage("images/partlyCloudy/day/$length.jpg");
      } else {
        length = random.nextInt(3) + 1;
        return AssetImage("images/partlyCloudy/night/$length.jpg");
      }
    } else if (condition == 803) {
      // mostly cloudy
      if (day) {
        length = random.nextInt(3) + 1;
        return AssetImage("images/mostlyCloudy/day/$length.jpg");
      } else {
        length = random.nextInt(3) + 1;
        return AssetImage("images/mostlyCloudy/night/$length.jpg");
      }
    } else if (condition == 804) {
      //cloudy
      if (day) {
        length = random.nextInt(3) + 1;
        return AssetImage("images/cloudy/day/$length.jpg");
      } else {
        length = random.nextInt(3) + 1;
        return AssetImage("images/mostlyCloudy/night/$length.jpg");
      }
    } else {
      return const AssetImage("images/Error.jpg");
    }
  }
}
//
// // writes data to the file
// Future<File> writeWeatherData(var weatherJson) async {
//   final file = await localFile;
//   DateTime writeTime = DateTime.now();
//
//   // Write the file
//   return file.writeAsString('$writeTime \n $weatherJson');
// }
//
// // reads data from the file
// Future<String> readWeatherData() async {
//   try {
//     final file = await localFile;
//
//     // Read the file
//     final contents = await file.readAsString();
//
//     return contents;
//   } catch (e) {
//     // If encountering an error
//     print("Error reading local file: $e");
//     return "Error";
//   }
// }
