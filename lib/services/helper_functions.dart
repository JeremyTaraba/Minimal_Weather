import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'global_variables.dart';
import '../utilities/weather_data.dart';
import 'custom_icons.dart';
import 'networking.dart';

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
  if (hour >= 12) {
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

double getCelsius(num temp) {
  double num = double.parse(temp.toStringAsFixed(1));
  return num;
}

int celsiusToFahrenheit(num temp) {
  double num;
  if (temp > 100) {
    // its in kelvin not celsius
    num = double.parse((((temp - 273.15) * 9 / 5) + 32).toStringAsFixed(0));
  } else {
    num = double.parse(((temp * 9 / 5) + 32).toStringAsFixed(0));
  }

  return num.toInt();
}

num convertUnitsIfNeedBe(num temp) {
  if (global_FahrenheitUnits.value == 1) {
    return celsiusToFahrenheit(temp);
  }
  return getCelsius(temp);
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
  const ConvertTimeUnits({super.key, required this.hour, required this.minutes, this.textStyle = const TextStyle(color: Colors.black, fontSize: 16)});
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
      if (description.toLowerCase() == "light rain") {
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
      return Icon(WeatherIcons.mist, size: size, color: Colors.grey);
    default:
      return Icon(WeatherIcons.sun, size: size, color: Colors.orange[600]);
  }
}

bool isAfterSunsetBeforeSunrise(DateTime sunset, DateTime time, DateTime sunrise) {
  if (time.hour <= sunrise.hour) {
    return true;
  }
  if (time.hour >= sunset.hour) {
    return true;
  }
  return false;
}

Future<void> sendLocationData(String cityName) async {
  try {
    String date = DateTime.now().toUtc().toString();
    final data = <String, String>{date: cityName};
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection("location").doc(global_userID).set(data, SetOptions(merge: true));
  } catch (e) {
    if (kDebugMode) {
      print("error sending city to firebase, account potentially disabled");
      print(e);
    }
    global_accountEnabled = false;
    global_errorMessage = "Account has been disabled.";
  }
}

Future<void> incrementDailyCalls(String cityName) async {
  try {
    String date = DateTime.now().toUtc().toString();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var cityHits = await firestore.collection("cities").doc(date.split(" ")[0]).get();
    if (cityHits.exists) {
      var cities = firestore.collection("cities").doc(date.split(" ")[0]);
      cities.update({cityName: FieldValue.increment(1)});
      cities.update({"total": FieldValue.increment(1)});
    } else {
      await firestore.collection("cities").doc(date.split(" ")[0]).set({cityName: 1}, SetOptions(merge: true));
    }
  } catch (e) {
    if (kDebugMode) {
      print("error updating daily calls");
      print(e);
    }
    global_accountEnabled = false;
    global_errorMessage = "Account has been disabled.";
  }
}

Future<int> getCallsFromFirebase() async {
  int cityHits = 10000;
  try {
    String date = DateTime.now().toUtc().toString();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var snapshot = await firestore.collection("cities").doc(date.split(" ")[0]).get();
    if (snapshot.exists) {
      cityHits = snapshot.data()?["total"];
    } else {
      await firestore.collection("cities").doc(date.split(" ")[0]).set({"total": 1}, SetOptions(merge: true));
      cityHits = 1;
    }

    return cityHits;
  } catch (e) {
    print("error getting snapshot from getCallsFromFirebase, total must not exist. Attempting to create total");
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String date = DateTime.now().toUtc().toString();
      await firestore.collection("cities").doc(date.split(" ")[0]).set({"total": 1}, SetOptions(merge: true));
      cityHits = 1;
    } catch (e) {
      if (kDebugMode) {
        print("total could not be created");
        print(e);
      }
    }
    if (kDebugMode) {
      print(e);
    }
  }
  return cityHits;
}

Future<String?> getCurrentCityName(double lat, double long) async {
  String? currentCity = "";
  try {
    List<geocoding.Placemark> geocodingLocation = await geocoding.placemarkFromCoordinates(lat, long);
    if (geocodingLocation[0].locality != "") {
      currentCity = geocodingLocation[0].locality;
    } else {
      if (kDebugMode) {
        print("null locality, defaulting to country");
      }
      if (geocodingLocation[0].country != "") {
        currentCity = geocodingLocation[0].country;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    FirebaseCrashlytics.instance.recordError("Error Geocoding: \n $e", StackTrace.current);
  }
  return currentCity;
}

// get request from cloud functions (no longer available because google account ran out of trial time)
// Future<dynamic> cloudFunctionsGetWeather(double lat, double long) async {
//   HttpsCallable weatherCloudFunction;
//   if (kDebugMode) {
//     weatherCloudFunction = FirebaseFunctions.instance.httpsCallable('getWeatherDebug');
//   } else {
//     weatherCloudFunction = FirebaseFunctions.instance.httpsCallable('getWeather');
//   }
//
//   dynamic response;
//   bool gotResponse = true;
//   try {
//     response = await weatherCloudFunction.call(<String, dynamic>{
//       'lat': lat,
//       'long': long,
//     });
//   } on FirebaseFunctionsException catch (e) {
//     // Do clever things with e
//     if (kDebugMode) {
//       print(e);
//     }
//     gotResponse = false;
//     global_gotWeatherSuccessfully = false;
//     global_errorMessage = "Error getting response cloud functions. $e";
//   } catch (e) {
//     // Do other things that might be thrown that I have overlooked
//     if (kDebugMode) {
//       print(e);
//     }
//     gotResponse = false;
//     global_gotWeatherSuccessfully = false;
//     global_errorMessage = "Error getting response cloud functions. $e";
//   }
//
//   try {
//     if (gotResponse) {
//       if (response.data["error"] != "Error") {
//         global_errorMessage = "No Error";
//       } else {
//         if (kDebugMode) {
//           print('Error getting response from url. ${response.data["error_info"]}');
//         }
//         global_gotWeatherSuccessfully = false;
//         global_errorMessage = "Error getting response from url.  ${response.data["error_info"]}";
//         return "Error";
//       }
//     } else {
//       return "Error";
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print(e);
//     }
//     global_gotWeatherSuccessfully = false;
//     return "Error";
//   }
//
//   return response.data;
// }

Future<bool> isStoredLocation(String? city, String? state) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedLocation = prefs.getString("storedLocation"); // should be the original location
  if (storedLocation != null) {
    String location = city! + state!;

    storedLocation = storedLocation.toLowerCase().trim();
    location = location.toLowerCase().trim();

    if (location == storedLocation) {
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

Future<void> setStoredLocation(String city, String state, WeatherData originalLocation) async {
  if (kDebugMode) {
    print("saving location");
  }
  String location = city + state;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("storedLocation", location.toLowerCase().trim());
  prefs.setString("storedLocationTime", DateTime.now().toString());
  prefs.setStringList("storedLocationData", originalLocation.toStringList());
}

Future<WeatherData> getStoredLocation() async {
  if (kDebugMode) {
    print("getting saved location");
  }
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

Future<dynamic> getWeatherFromOpenMeteo(double lat, double long) async {
  String openMeteoLink =
      "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&hourly=temperature_2m,precipitation_probability,weather_code,uv_index,relative_humidity_1000hPa,windspeed_1000hPa&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset&wind_speed_unit=ms&timeformat=unixtime&timezone=auto";
  var openMeteo = NetworkHelper(openMeteoLink);
  var data = await openMeteo.getData();
  return data;
}

int getHourlyTimeGivenTime(List<dynamic> timeList, DateTime time) {
  for (int i = 0; i < timeList.length; i++) {
    if (DateUtils.isSameDay(time, DateTime.fromMillisecondsSinceEpoch(timeList[i] * 1000))) {
      if (time.hour == DateTime.fromMillisecondsSinceEpoch(timeList[i] * 1000).hour) {
        return i;
      }
    }
  }

  return -1;
}

int getMedianCondition(List<dynamic> hourlyConditions, int startIndex, int endIndex, List<dynamic> hourlyPrecipitation) {
  // use precipitation to overwrite condition
  num totalPrecipitation = 0;
  Map<int, int> dictConditions = {};
  for (int i = startIndex; i < endIndex; i++) {
    dictConditions.update(hourlyConditions[i], (value) => value++, ifAbsent: () => 1);
    totalPrecipitation += hourlyPrecipitation[i];
  }
  if (totalPrecipitation >= 720) {
    // average 20% per hour
    return 21; // code for rain, 20 = code for drizzle
  }
  if (totalPrecipitation >= 240) {
    // average 10% per hour
    return 20; // code for rain, 20 = code for drizzle
  }

  int maxValue = 0;
  int maxKey = 0;
  dictConditions.forEach((key, value) {
    if (value > maxValue) {
      maxValue = value;
      maxKey = key;
    }
  });
  return maxKey;
}

num getMinTemps(List<dynamic> temps, int startIndex, int endIndex) {
  num minTemp = temps[startIndex];
  for (int i = startIndex; i < endIndex; i++) {
    if (minTemp > temps[i]) {
      minTemp = temps[i];
    }
  }
  return minTemp;
}

num getMaxTemps(List<dynamic> temps, int startIndex, int endIndex) {
  num maxTemp = temps[startIndex];
  for (int i = startIndex; i < endIndex; i++) {
    if (maxTemp < temps[i]) {
      maxTemp = temps[i];
    }
  }
  return maxTemp;
}

num getHourlyTemperatureCurrent(var temperatureList, var timeList) {
  // need to get current time and check it with time list, the index they meet up is the index the temp we give them
  int index = getHourlyTimeGivenTime(timeList, DateTime.now());
  return temperatureList[index];
}

num getHourlyTemperatureGivenTime(var temperatureList, var timeList, DateTime time) {
  // need to get current time and check it with time list, the index they meet up is the index the temp we give them
  int index = getHourlyTimeGivenTime(timeList, time);
  return temperatureList[index];
}

int getOpenWeatherConditionNumberFromCondition(int condition) {
  if (condition == 0) {
    return 800;
  }
  if (condition == 1) {
    return 801;
  }
  if (condition == 2) {
    return 802;
  }
  if (condition == 3) {
    return 804;
  }
  if (condition <= 5) {
    return 721;
  }
  if (condition <= 9) {
    return 731;
  }
  if (condition == 10) {
    return 701;
  }
  if (condition <= 12) {
    return 741;
  }
  if (condition == 13) {
    return 211;
  }
  if (condition <= 16) {
    return 300;
  }
  if (condition == 17) {
    return 211;
  }
  if (condition <= 19) {
    return 771;
  }
  if (condition == 20) {
    return 301;
  }
  if (condition == 21) {
    return 501;
  }

  if (condition <= 24) {
    return 601;
  }
  if (condition == 25) {
    return 502;
  }
  if (condition <= 27) {
    return 602;
  }
  if (condition == 28) {
    return 741;
  }
  if (condition == 29) {
    return 211;
  }
  if (condition <= 35) {
    return 731;
  }
  if (condition <= 39) {
    return 601;
  }
  if (condition <= 49) {
    return 741;
  }
  if (condition <= 59) {
    return 301;
  }
  if (condition <= 69) {
    return 501;
  }
  if (condition <= 75) {
    return 601;
  }
  if (condition <= 79) {
    return 611;
  }
  if (condition <= 84) {
    return 521;
  }
  if (condition <= 88) {
    return 602;
  }
  if (condition <= 90) {
    return 611;
  }
  if (condition == 91) {
    return 500;
  }
  if (condition == 92) {
    return 503;
  }
  if (condition <= 94) {
    return 601;
  }
  if (condition <= 99) {
    return 200;
  }
  return 900; // error
}

String getDescriptionFromCondition(int condition) {
  if (condition == 0) {
    return "Clear Sky";
  }
  if (condition == 1) {
    return "Few Clouds";
  }
  if (condition == 2) {
    return "Scattered Clouds";
  }
  if (condition == 3) {
    return "Cloudy";
  }
  if (condition <= 5) {
    return "Haze";
  }
  if (condition <= 9) {
    return "Dusty";
  }
  if (condition == 10) {
    return "Misty";
  }
  if (condition <= 12) {
    return "Foggy";
  }
  if (condition == 13) {
    return "Lightning";
  }
  if (condition <= 16) {
    return "Precipitation";
  }
  if (condition == 17) {
    return "Thunderstorm";
  }
  if (condition <= 19) {
    return "Squalls";
  }
  if (condition == 20) {
    return "Light Rain";
  }
  if (condition == 21) {
    return "Rain";
  }
  if (condition == 22) {
    return "Snow";
  }
  if (condition <= 24) {
    return "Snow Pellets";
  }
  if (condition == 25) {
    return "Heavy Rain";
  }
  if (condition <= 27) {
    return "Heavy Snow";
  }
  if (condition == 28) {
    return "Fog";
  }
  if (condition == 29) {
    return "Thunderstorm";
  }
  if (condition <= 35) {
    return "Dust Storm";
  }
  if (condition <= 39) {
    return "Blowing Snow";
  }
  if (condition <= 49) {
    return "Foggy";
  }
  if (condition <= 59) {
    return "Light Rain";
  }
  if (condition <= 69) {
    return "Rain";
  }
  if (condition <= 75) {
    return "Snowflakes";
  }
  if (condition <= 79) {
    return "Ice Pellets";
  }
  if (condition <= 84) {
    return "Rain Showers";
  }
  if (condition <= 88) {
    return "Snow Showers";
  }
  if (condition <= 90) {
    return "Hail Showers";
  }
  if (condition == 91) {
    return "Light Rain";
  }
  if (condition == 92) {
    return "Heavy Rain";
  }
  if (condition <= 94) {
    return "Snow";
  }
  if (condition <= 99) {
    return "Thunderstorm";
  }
  return "";
}

String getOpenWeatherIconFromCondition(int condition, DateTime sunset, DateTime time, DateTime sunrise, bool ignoreNight, num precipitation) {
  bool isNight = isAfterSunsetBeforeSunrise(sunset, time, sunrise);
  if (condition == 0) {
    if (isNight && !ignoreNight) {
      return "01n";
    }
    return "01d";
  }
  if (condition == 1) {
    if (isNight && !ignoreNight) {
      return "02n";
    }
    return "02d";
  }
  if (condition == 2) {
    if (isNight && !ignoreNight) {
      return "03n";
    }
    return "03d";
  }
  if (condition == 3) {
    if (isNight && !ignoreNight) {
      return "04n";
    }
    return "04d";
  }
  if (condition <= 12) {
    return "50d";
  }
  if (condition == 13) {
    return "11d";
  }
  if (condition <= 16) {
    if (precipitation > 10) {
      return "09d";
    } else {
      return "03d";
    }
  }
  if (condition == 17) {
    return "11d";
  }
  if (condition <= 19) {
    return "50d";
  }
  if (condition == 20) {
    if (precipitation > 10) {
      return "09d";
    } else {
      return "03d";
    }
  }
  if (condition == 21) {
    if (precipitation > 10) {
      return "10d";
    } else {
      return "04d";
    }
  }
  if (condition <= 24) {
    return "13d";
  }
  if (condition == 25) {
    if (precipitation > 10) {
      return "10d";
    } else {
      return "04d";
    }
  }
  if (condition <= 27) {
    return "13d";
  }
  if (condition == 28) {
    return "50d";
  }
  if (condition == 29) {
    return "11d";
  }
  if (condition <= 35) {
    return "50d";
  }
  if (condition <= 39) {
    return "13d";
  }
  if (condition <= 49) {
    return "50d";
  }
  if (condition <= 59) {
    if (precipitation > 10) {
      return "09d";
    } else {
      return "03d";
    }
  }
  if (condition <= 69) {
    if (precipitation > 10) {
      return "10d";
    } else {
      return "04d";
    }
  }
  if (condition <= 79) {
    return "13d";
  }
  if (condition <= 84) {
    if (precipitation > 10) {
      return "10d";
    } else {
      return "04d";
    }
  }
  if (condition <= 90) {
    return "13d";
  }
  if (condition == 92) {
    if (precipitation > 10) {
      return "10d";
    } else {
      return "04d";
    }
  }
  if (condition <= 94) {
    return "13d";
  }
  if (condition <= 99) {
    return "11d";
  }
  return "";
}

getStateFromLatAndLong(double lat, double long) async {
  String? currentState = "";
  try {
    List<geocoding.Placemark> geocodingLocation = await geocoding.placemarkFromCoordinates(lat, long);

    if (geocodingLocation[0].administrativeArea != "") {
      // used for saving location more accurately, if no administrative Area then just leave it blank
      currentState = geocodingLocation[0].administrativeArea;
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    FirebaseCrashlytics.instance.recordError("Error Geocoding: \n $e", StackTrace.current);
  }

  return currentState;
}
