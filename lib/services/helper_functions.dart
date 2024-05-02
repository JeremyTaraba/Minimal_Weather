import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'global_variables.dart';
import '../utilities/weather_data.dart';
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
  return "${getLocalTime(hour, minutes)} ${getAMPM(hour)}";
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

setTwentyFourHourFormat() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  global_twentyFourHourFormat.value == 1 ? global_twentyFourHourFormat.value = 0 : global_twentyFourHourFormat.value = 1;
  prefs.setBool("twentyFourHourFormat", global_twentyFourHourFormat.value == 1 ? true : false);
}

getTwentyFourHourFormat() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("twentyFourHourFormat") == true) {
    return 1;
  }
  return 0;
}

double kelvinToCelsius(num temp) {
  double num = double.parse((temp - 273.15).toStringAsFixed(1));
  return num;
}

int kelvinToFahrenheit(num temp) {
  double num = double.parse((((temp - 273.15) * 9 / 5) + 32).toStringAsFixed(0));
  return num.toInt();
}

num convertUnitsIfNeedBe(num temp) {
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

class ConvertTempUnits extends StatefulWidget {
  const ConvertTempUnits({super.key, required this.temp, required this.textStyle});
  final num temp;
  final TextStyle textStyle;
  @override
  State<ConvertTempUnits> createState() => _ConvertTempUnitsState();
}

class _ConvertTempUnitsState extends State<ConvertTempUnits> {
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

class ConvertTimeUnits extends StatefulWidget {
  ConvertTimeUnits({super.key, required this.hour, required this.minutes, this.textStyle = const TextStyle(color: Colors.black, fontSize: 16)});
  final int hour;
  final int minutes;
  final TextStyle textStyle;
  @override
  State<ConvertTimeUnits> createState() => _ConvertTimeUnitsState();
}

class _ConvertTimeUnitsState extends State<ConvertTimeUnits> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: global_twentyFourHourFormat,
        builder: (BuildContext context, int value, Widget? child) {
          return Text(
            global_twentyFourHourFormat.value == 1
                ? twentyFourHourToString(widget.hour, widget.minutes)
                : getTimeWithAMPM(widget.hour, widget.minutes),
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

Future<void> sendLocationData(String cityName) async {
  final data = <String, String>{DateTime.now().toString(): cityName};
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  await firestore.collection("location").doc(global_userID).set(data, SetOptions(merge: true));
  var cityHits = await firestore.collection("cities").doc(DateTime.now().toString().split(" ")[0]);
  cityHits.update({cityName: FieldValue.increment(1)});
}

Future<dynamic> cloudFunctionsGetWeather(double lat, double long) async {
  HttpsCallable weatherCloudFunction;
  if (kDebugMode) {
    weatherCloudFunction = FirebaseFunctions.instance.httpsCallable('getWeatherDebug');
  } else {
    weatherCloudFunction = FirebaseFunctions.instance.httpsCallable('getWeather');
  }

  dynamic response;
  bool gotResponse = true;
  try {
    response = await weatherCloudFunction.call(<String, dynamic>{
      'lat': lat,
      'long': long,
    });
  } on FirebaseFunctionsException catch (e) {
    // Do clever things with e
    if (kDebugMode) {
      print(e);
    }
    gotResponse = false;
    global_gotWeatherSuccessfully = false;
    global_errorMessage = "Error getting response cloud functions. $e";
  } catch (e) {
    // Do other things that might be thrown that I have overlooked
    if (kDebugMode) {
      print(e);
    }
    gotResponse = false;
    global_gotWeatherSuccessfully = false;
    global_errorMessage = "Error getting response cloud functions. $e";
  }

  try {
    if (gotResponse) {
      if (response.data["error"] != "Error") {
        global_errorMessage = "No Error";
      } else {
        if (kDebugMode) {
          print('Error getting response from url. ${response.data["error_info"]}');
        }
        global_gotWeatherSuccessfully = false;
        global_errorMessage = "Error getting response from url.  ${response.data["error_info"]}";
        return "Error";
      }
    } else {
      return "Error";
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    global_gotWeatherSuccessfully = false;
    return "Error";
  }

  return response.data;
}

Future<bool> isStoredLocation(String? city) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedLocation = prefs.getString("storedLocation"); // should be the original location
  if (storedLocation != null) {
    storedLocation = storedLocation.toLowerCase().trim();
    city = city?.toLowerCase().trim();
    // print("storedLocation - $storedLocation");
    // print("city - $city");
    if (city == storedLocation) {
      final String? storedLocationTime = prefs.getString("storedLocationTime");
      if (storedLocationTime != null) {
        var parseDate = DateTime.parse(storedLocationTime);
        var timeDelayForRefresh = DateTime.now().subtract(const Duration(hours: 3));
        if (parseDate.isAfter(timeDelayForRefresh)) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  return false;
}

Future<void> setStoredLocation(String city, WeatherData originalLocation) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("storedLocation", city);
  prefs.setString("storedLocationTime", DateTime.now().toString());
  prefs.setStringList("storedLocationData", originalLocation.toStringList());
}

Future<WeatherData> getStoredLocation() async {
  WeatherData storedLocation = WeatherData();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? dataInStringList = prefs.getStringList("storedLocationData");
  if (dataInStringList != null) {
    storedLocation.convertDataFromStringList(dataInStringList);
  }
  return storedLocation;
}

Future<bool> checkAndIncrementLookUpCounter() async {
  if (kDebugMode) {
    // no limit for debug mode
    return true;
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? lookUpCounter = prefs.getInt("lookUpCounter");
  if (lookUpCounter != null && lookUpCounter > 0) {
    String? lookUpCounterTime = prefs.getString("lookUpCounterTime");
    if (lookUpCounterTime != null) {
      var parseDate = DateTime.parse(lookUpCounterTime);
      var oneHour = DateTime.now().subtract(const Duration(hours: 1));
      if (parseDate.isBefore(oneHour)) {
        // first look up was more than an hour ago
        prefs.setInt("lookUpCounter", 1);
        prefs.setString("lookUpCounterTime", DateTime.now().toString());
        return true;
      } else {
        // first look up was within the hour
        if (lookUpCounter < 5) {
          prefs.setInt("lookUpCounter", lookUpCounter + 1);
          return true;
        } else {
          if (kDebugMode) {
            print("reached lookUpCounter limit, wait an hour for reset");
          }
          return false;
        }
      }
    }
  } else {
    prefs.setInt("lookUpCounter", 1);
    prefs.setString("lookUpCounterTime", DateTime.now().toString());
  }

  return true;
}

void goToOriginalLocation(context) {
  Navigator.of(context).pop();
}

String twentyFourHourToString(int hours, int minutes) {
  if (minutes == 0) {
    return hours < 10 ? "0$hours:00" : "$hours:00";
  }
  if (minutes < 10) {
    return hours < 10 ? "0$hours:0$minutes" : "$hours:0$minutes";
  }
  return hours < 10 ? "0$hours:$minutes" : "$hours:$minutes";
}

// Custom ValueListenable but with 2 objects
// class ValueListenableBuilder2<A, B> extends StatelessWidget {
//   const ValueListenableBuilder2({
//     required this.firstListenable,
//     required this.secondListenable,
//     super.key,
//     required this.builder,
//     this.child,
//   });
//
//   final ValueListenable<A> firstListenable;
//   final ValueListenable<B> secondListenable;
//   final Widget? child;
//   final Widget Function(BuildContext context, A a, B b, Widget? child) builder;
//
//   @override
//   Widget build(BuildContext context) => ValueListenableBuilder<A>(
//         valueListenable: firstListenable,
//         builder: (_, a, __) {
//           return ValueListenableBuilder<B>(
//             valueListenable: secondListenable,
//             builder: (context, b, __) {
//               return builder(context, a, b, child);
//             },
//           );
//         },
//       );
// }
