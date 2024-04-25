import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../services/global_variables.dart';
import '../utilities/weather_data.dart';
import '../utilities/helper_functions.dart';
import 'home_screen.dart';
import 'error_screen.dart';

class LoadingNewCity extends StatefulWidget {
  const LoadingNewCity({super.key, required this.lat, required this.long, required this.cityName});
  final num lat;
  final num long;
  final String? cityName;
  @override
  State<LoadingNewCity> createState() => _LoadingNewCityState();
}

class _LoadingNewCityState extends State<LoadingNewCity> {
  @override
  void initState() {
    super.initState();
    loadNewCity(widget.cityName);
  }

  loadNewCity(String? tappedCity) async {
    WeatherData currentWeatherData = WeatherData();
    bool checkIfCitySaved = await isStoredLocation(widget.cityName);
    if (checkIfCitySaved) {
      currentWeatherData = await getStoredLocation();
      await Future.delayed(const Duration(milliseconds: 100));
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomeScreen(
          locationWeather: currentWeatherData,
          cityName: tappedCity,
        );
      }));
    } else {
      var response = await cloudFunctionsGetWeather(widget.lat.toDouble(), widget.long.toDouble());
      if (!global_gotWeatherSuccessfully) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const ErrorScreen();
        }));
      } else {
        String? currentCity = "";
        // need to get the city based on lat and long
        try {
          List<geocoding.Placemark> geocodingLocation = await geocoding.placemarkFromCoordinates(widget.lat.toDouble(), widget.long.toDouble());
          if (geocodingLocation[0].locality != "") {
            currentCity = geocodingLocation[0].locality;
          } else {
            print("null locality, defaulting to country");
            if (geocodingLocation[0].country != "") {
              currentCity = geocodingLocation[0].country;
            }
          }
        } catch (e) {
          print(e);
          FirebaseCrashlytics.instance.recordError("Error Geocoding: \n $e", StackTrace.current);
        }

        if (currentCity == "") {
          // geocoding failed, throw error screen
          global_errorMessage = "Geocoding failed, country was also null";
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const ErrorScreen();
          }));
        }
        currentWeatherData.setWeatherData(response);
        global_FahrenheitUnits.value = await getTemperatureUnits();
        try {
          final userCredential = await FirebaseAuth.instance.signInAnonymously();
          global_userID = userCredential.user?.uid;
          print("Manual Lookup");
          await sendLocationData("${currentWeatherData.cityName}: manual lookup");
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case "operation-not-allowed":
              global_errorMessage = "Anonymous auth hasn't been enabled for this project.";
              break;
            default:
              global_errorMessage = "Unknown error with FirebaseAuth.";
          }
        }
        currentWeatherData.cityName = currentCity!;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return HomeScreen(
            locationWeather: currentWeatherData,
            cityName: tappedCity,
          );
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      body: const Center(
        child: SpinKitCircle(
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }
}
