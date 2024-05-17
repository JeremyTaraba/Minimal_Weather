import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../services/global_variables.dart';
import '../utilities/weather_data.dart';
import '../services/helper_functions.dart';
import 'home_screen.dart';
import 'error_screen.dart';

class LoadingNewCity extends StatefulWidget {
  const LoadingNewCity(
      {super.key, required this.lat, required this.long, required this.cityName, required this.originalWeather, required this.originalCity});
  final num lat;
  final num long;
  final String? cityName;
  final WeatherData originalWeather;
  final String? originalCity; // might be different city name from originalWeather.cityName
  @override
  State<LoadingNewCity> createState() => _LoadingNewCityState();
}

class _LoadingNewCityState extends State<LoadingNewCity> {
  @override
  void initState() {
    super.initState();
    loadNewCity(widget.cityName, widget.originalCity);
  }

  static const snackBarLookUpLimit = SnackBar(
    backgroundColor: Colors.red,
    content: Text(
      'Limit reached. Try again later',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  Future<void> goToSavedCity(String? tappedCity) async {
    WeatherData currentWeatherData = await getStoredLocation();
    await Future.delayed(const Duration(milliseconds: 100));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomeScreen(
        locationWeather: currentWeatherData,
        cityName: tappedCity,
        isLookUp: false,
      );
    }));
  }

  loadNewCity(String? tappedCity, String? originalCity) async {
    int dailyCalls = 0;
    WeatherData currentWeatherData = WeatherData();
    bool checkIfCitySaved = await isStoredLocation(widget.cityName);
    if (checkIfCitySaved) {
      // if city saved we grab weather data from storage
      goToSavedCity(tappedCity);
    } else {
      // will do a manual look up
      bool underLookUpCounterLimit = await checkAndIncrementLookUpCounter();
      if (underLookUpCounterLimit) {
        // look up new location
        dailyCalls += 1; // fetch daily calls from firebase
        if (dailyCalls < 9990) {
          // use openmeteo api
          // increment daily calls
          String? currentCity = "";
          try {
            List<geocoding.Placemark> geocodingLocation = await geocoding.placemarkFromCoordinates(widget.lat.toDouble(), widget.long.toDouble());
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
          currentWeatherData.cityName = currentCity!;
          var response = await getWeatherFromOpenMeteo(widget.lat.toDouble(), widget.long.toDouble());
          if (!global_gotWeatherSuccessfully) {
            if (kDebugMode) {
              print("Did not get weather successfully");
            }
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return const ErrorScreen(errorCode: 503); // server is too full
            }));
            return;
          }
          //want to store this information into 1 weather object
          currentWeatherData.setWeatherDataFromOpenMeteo(response);
          global_FahrenheitUnits.value = await getTemperatureUnits();
          //send location to firebase for analytics
          _sendManualLocationToFirebase(currentWeatherData);
          currentWeatherData.cityName = currentCity!;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return HomeScreen(
              locationWeather: currentWeatherData,
              cityName: tappedCity,
              isLookUp: true,
            );
          }));
          return;
        }

        var response = await cloudFunctionsGetWeather(widget.lat.toDouble(), widget.long.toDouble());
        if (!global_gotWeatherSuccessfully) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const ErrorScreen(errorCode: 503); // server is too full
          }));
        } else {
          String? currentCity = "";
          // need to get the city based on lat and long to get the city name
          try {
            List<geocoding.Placemark> geocodingLocation = await geocoding.placemarkFromCoordinates(widget.lat.toDouble(), widget.long.toDouble());
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

          if (currentCity == "") {
            // geocoding failed, throw error screen
            global_errorMessage = "Geocoding failed, country was also null";
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ErrorScreen(errorCode: 400); // couldn't find city
            }));
          } else {
            currentWeatherData.setWeatherDataFromOpenWeather(response);
            global_FahrenheitUnits.value = await getTemperatureUnits();
            // send manual lookup to firebase for analytics
            _sendManualLocationToFirebase(currentWeatherData);
            incrementDailyCalls(currentWeatherData.cityName);
            // normal lookup where we get the weather data from cloud functions
            currentWeatherData.cityName = currentCity!;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return HomeScreen(
                locationWeather: currentWeatherData,
                cityName: tappedCity,
                isLookUp: true,
              );
            }));
          }
        }
      } else {
        // you have exceeded the lookup limit, returns you to last location
        // what if last location is original?
        // can't be because original is saved, unless they waited 3 hours to reload their original
        ScaffoldMessenger.of(context).showSnackBar(snackBarLookUpLimit);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return HomeScreen(
            locationWeather: widget.originalWeather,
            cityName: originalCity,
            isLookUp: true,
          );
        }));
      }
    }
  }

  _sendManualLocationToFirebase(WeatherData currentWeatherData) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      global_userID = userCredential.user?.uid;
      if (kDebugMode) {
        print("Manual Lookup");
      }
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
