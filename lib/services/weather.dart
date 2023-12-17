import 'package:klimate/services/location.dart';
import 'package:klimate/services/networking.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:klimate/utilities/constants.dart';

import 'keys.dart';

class WeatherModel {
  int condition;
  int hour;
  Color appBarColor = kErrorDayColor;
  Image? weatherIcon;
  AssetImage weatherBackground = AssetImage("images/Error.jpg");
  int sunset;
  int sunrise;

  WeatherModel({
    required this.condition,
    required this.hour,
    required this.sunrise,
    required this.sunset,
  }) {
    int length = 1;
    Random random = new Random();
    bool day = false;

    //if daytime
    if ((hour > sunrise) && (hour <= sunset)) {
      day = true;
    }
    if (condition < 300) {
      // thunderstorm
      appBarColor = kRainstormColor;
      weatherBackground = AssetImage("images/thunderstorm/1.jpg");
    } else if (condition < 400) {
      // drizzle
      appBarColor = kRainColor;
      length = random.nextInt(6) + 1;
      weatherBackground = AssetImage("images/rain/$length.jpg");
    } else if (condition < 600) {
      // rain
      appBarColor = kRainColor;
      length = random.nextInt(6) + 1;
      weatherBackground = AssetImage("images/rain/$length.jpg");
    } else if (condition < 700) {
      //snow
      if (condition == 611 || condition == 612 || condition == 613) {
        // sleet/hail
        appBarColor = kIceColor;
        length = random.nextInt(2) + 1;
        weatherBackground = AssetImage("images/hail/$length.jpg");
      } else {
        appBarColor = kSnowColor;
        length = random.nextInt(4) + 1;
        weatherBackground = AssetImage("images/snow/$length.jpg");
      }
    } else if (condition < 800) {
      // atmosphere (fog, mist, smoke, haze)
      appBarColor = kAtmosphere;
      weatherBackground = AssetImage("images/atmosphere/1.jpg");
    } else if (condition == 800 || condition == 801) {
      // clear and mostly clear
      if (day) {
        appBarColor = kClearDayColor;
        length = random.nextInt(10) + 1;
        weatherBackground = AssetImage("images/clear/day/$length.jpg");
      } else {
        appBarColor = kClearNightColor;
        if (condition == 801) {
          length = random.nextInt(3) + 1;
          weatherBackground = AssetImage("images/mostlyClear/night/$length.jpg");
        } else {
          length = random.nextInt(5) + 1;
          weatherBackground = AssetImage("images/clear/night/$length.jpg");
        }
      }
    } else if (condition == 802) {
      //partly cloudy
      if (day) {
        appBarColor = kPartlyCloudyDayColor;
        length = random.nextInt(5) + 1;
        weatherBackground = AssetImage("images/partlyCloudy/day/$length.jpg");
      } else {
        appBarColor = kPartlyCloudyNightColor;
        length = random.nextInt(3) + 1;
        weatherBackground = AssetImage("images/partlyCloudy/night/$length.jpg");
      }
    } else if (condition == 803) {
      // mostly cloudy
      if (day) {
        appBarColor = kPartlyCloudyDayColor;
        length = random.nextInt(3) + 1;
        weatherBackground = AssetImage("images/mostlyCloudy/day/$length.jpg");
      } else {
        appBarColor = kPartlyCloudyNightColor;
        length = random.nextInt(3) + 1;
        weatherBackground = AssetImage("images/mostlyCloudy/night/$length.jpg");
      }
    } else if (condition == 804) {
      //cloudy
      if (day) {
        appBarColor = kCloudyColor;
        length = random.nextInt(3) + 1;
        weatherBackground = AssetImage("images/cloudy/day/$length.jpg");
      } else {
        appBarColor = kPartlyCloudyNightColor;
        length = random.nextInt(3) + 1;
        weatherBackground = AssetImage("images/mostlyCloudy/night/$length.jpg");
      }
    } else {
      weatherBackground = AssetImage("images/Error.jpg");
    }
  }

  Future<dynamic> getCityWeather(String cityName) async {
    var url = '$openWeatherMapURLHourly?q=$cityName&appid=$apiKey&units=imperial';
    NetworkHelper networkHelper = NetworkHelper(url);
    var weatherData = await networkHelper.getData();
    return weatherData;
  }
}

Future<dynamic> getCurrentLocationWeather() async {
  Location currentLocation = Location();
  await currentLocation.getCurrentLocation();

  NetworkHelper networkHelper =
      NetworkHelper('$openWeatherMapURLCurrentWeather?lat=${currentLocation.latitude}&lon=${currentLocation.longitude}&appid=$apiKey&units=imperial');

  var weatherData = await networkHelper.getData();
  return weatherData;
}

Future<dynamic> getHourlyLocationWeather() async {
  Location currentLocation = Location();
  await currentLocation.getCurrentLocation();

  NetworkHelper networkHelper =
      NetworkHelper('$openWeatherMapURLHourly?lat=${currentLocation.latitude}&lon=${currentLocation.longitude}&exclude=minutely&appid=$apiKey');

  var weatherData = await networkHelper.getData();
  return weatherData;
}

Future<dynamic> getCurrentLocationWeatherWithName(String cityName) async {
  List<double> pair = [0, 0]; //lat = 0, long = 1
  NetworkHelper latAndLong = NetworkHelper("https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=5&appid=$apiKey");
  var location = await latAndLong.getData();
  pair[0] = location[1]["lat"];
  pair[1] = location[1]["lon"];

  NetworkHelper networkHelper = NetworkHelper('$openWeatherMapURLCurrentWeather?lat=${pair[0]}&lon=${pair[1]}&appid=$apiKey&units=imperial');

  var weatherData = await networkHelper.getData();
  return weatherData;
}

Future<dynamic> getHourlyLocationWeatherWithName(String cityName) async {
  List<double> pair = [0, 0]; //lat = 0, long = 1
  NetworkHelper latAndLong = NetworkHelper("https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=5&appid=$apiKey");
  var location = await latAndLong.getData();
  pair[0] = location[1]["lat"];
  pair[1] = location[1]["lon"];

  NetworkHelper networkHelper = NetworkHelper('$openWeatherMapURLHourly?lat=${pair[0]}&lon=${pair[1]}&exclude=minutely&appid=$apiKey');

  var weatherData = await networkHelper.getData();
  return weatherData;
}
