import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../services/global_variables.dart';
import 'custom_icons.dart';

String getLocalTime(int hour, int minutes) {
  String time = "";

  if (hour > 12) {
    hour -= 12;
  } else if (hour == 0) {
    hour = 12;
  }

  if (minutes < 10) {
    time = "$hour:0$minutes";
  } else {
    time = "$hour:$minutes";
  }

  return time;
}

String getAMPM(int hour) {
  String time = "";
  if (hour > 12) {
    time = "PM";
  } else {
    time = "AM";
  }

  return time;
}

String getTimeWithAMPM(int hour, int minutes) {
  return getLocalTime(hour, minutes) + " " + getAMPM(hour);
}

String getDayFromWeekday(int weekday) {
  switch (weekday) {
    case 0:
      return "Today";
    case 1:
      return "Monday";
    case 2:
      return "Tuesday";
    case 3:
      return "Wednesday";
    case 4:
      return "Thursday";
    case 5:
      return "Friday";
    case 6:
      return "Saturday";
    default:
      return "Sunday";
  }
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}
//
// // finds the correct local path to create a local file
// Future<String> get _localPath async {
//   final directory = await getApplicationDocumentsDirectory();
//
//   return directory.path;
// }
//
// // creates a reference to the file location using _localPath
// Future<File> get localFile async {
//   final path = await _localPath;
//   return File('$path/counter.txt');
// }

setToFahrenheit() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  global_FahrenheitUnits.value = 1;
  prefs.setBool("Fahrenheit", true);
}

setToCelsius() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  global_FahrenheitUnits.value = 0;
  prefs.setBool("Fahrenheit", false);
}

getTemperatureUnits() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("Fahrenheit") == true) {
    return 1;
  }
  return 0;
}

double kelvinToCelsius(double temp) {
  double num = double.parse((temp - 273.15).toStringAsFixed(1));
  return num;
}

int kelvinToFahrenheit(double temp) {
  double num = double.parse((((temp - 273.15) * 9 / 5) + 32).toStringAsFixed(0));
  return num.toInt();
}

num convertUnitsIfNeedBe(double temp) {
  if (global_FahrenheitUnits.value == 1) {
    return kelvinToFahrenheit(temp);
  }
  return kelvinToCelsius(temp);
}

String metersSecondToMph(double mph) {
  if (global_FahrenheitUnits.value == 1) {
    return "${(mph * 2.23694).toStringAsFixed(2)} mph";
  }
  return "${(mph).toStringAsFixed(2)} m/s";
}

class convertSpeedUnits extends StatefulWidget {
  const convertSpeedUnits({super.key, required this.speed, required this.textStyle});
  final speed;
  final TextStyle textStyle;
  @override
  State<convertSpeedUnits> createState() => _convertSpeedUnitsState();
}

class _convertSpeedUnitsState extends State<convertSpeedUnits> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: global_FahrenheitUnits,
        builder: (BuildContext context, int value, Widget? child) {
          return Text(
            metersSecondToMph(widget.speed),
            style: widget.textStyle,
          );
        });
  }
}

class convertTempUnits extends StatefulWidget {
  const convertTempUnits({super.key, required this.temp, required this.textStyle});
  final temp;
  final TextStyle textStyle;
  @override
  State<convertTempUnits> createState() => _convertTempUnitsState();
}

class _convertTempUnitsState extends State<convertTempUnits> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: global_FahrenheitUnits,
        builder: (BuildContext context, int value, Widget? child) {
          return Text(
            "${convertUnitsIfNeedBe(widget.temp.toDouble())}°",
            style: widget.textStyle,
          );
        });
  }
}

Icon getWeatherIcon(String iconNumber, double size, String description) {
  switch (iconNumber) {
    case "01d":
      return Icon(WeatherIcons.sun, size: size, color: Colors.orange[600]);
    case "01n":
      return Icon(WeatherIcons.moon, size: size, color: Colors.deepPurple[300]);
    case "02d":
    case "03d":
      return Icon(WeatherIcons.cloud_sun, size: size, color: Colors.orange[200]);
    case "02n":
    case "03n":
      return Icon(WeatherIcons.cloud_moon, size: size, color: Colors.deepPurple[600]);

    case "04n":
    case "04d":
      return Icon(WeatherIcons.clouds, size: size, color: Colors.grey[600]);
    case "09n":
    case "09d":
    case "10d":
    case "10n":
      if (description == "light rain") {
        return Icon(WeatherIcons.drizzle, size: size, color: Colors.blue[300]);
      }
      return Icon(WeatherIcons.rain, size: size, color: Colors.indigo);
    case "11n":
    case "11d":
      return Icon(WeatherIcons.cloud_flash_alt, size: size, color: Colors.yellow);
    case "13n":
    case "13d":
      return Icon(WeatherIcons.snow_heavy, size: size, color: Colors.grey);
    case "50n":
    case "50d":
      return Icon(WeatherIcons.fog, size: size, color: Colors.grey);
    default:
      return Icon(WeatherIcons.sun, size: size, color: Colors.orange[600]);
  }
}
