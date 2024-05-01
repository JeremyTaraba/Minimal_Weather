import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:klimate/screens/home_screen.dart';
import 'package:klimate/screens/error_screen.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/weather_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:klimate/services/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/helper_functions.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    checkIfLocationOn();
  }

  Future<bool> checkIfLocationOn() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      //permission is enabled
      if (kDebugMode) {
        print("Permission enabled");
      }
      var status = await Permission.location.status;
      if (status.isGranted) {
        //location permission is granted
        if (kDebugMode) {
          print("Permission granted");
        }
        getLocationData();
      } else {
        //location permission is not granted
        if (kDebugMode) {
          print("Permission not granted");
        }
        Map<Permission, PermissionStatus> status = await [
          Permission.location,
        ].request();
        getLocationData();
      }
    } else {
      Map<Permission, PermissionStatus> status = await [
        Permission.location,
      ].request();
      //permission is not enabled
      if (kDebugMode) {
        print("Permission not enabled");
      }
    }
    if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    }
    return true;
  }

  void getLocationData() async {
    //updating global units from saved settings
    global_FahrenheitUnits.value = await getTemperatureUnits();
    global_twentyFourHourFormat.value = await getTwentyFourHourFormat();
    Location currentLocation = Location();
    await currentLocation.getCurrentLocation();
    WeatherData weatherData = WeatherData();
    String? currentCity = "";
    bool geocodingCityFailed = false;
    // need to get the city based on lat and long
    try {
      List<geocoding.Placemark> geocodingLocation = await geocoding.placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude);
      if (geocodingLocation[0].locality != "") {
        currentCity = geocodingLocation[0].locality;
      } else {
        if (kDebugMode) {
          print("null locality, defaulting to country");
        }
        if (geocodingLocation[0].country != "") {
          geocodingCityFailed = true;
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const ErrorScreen(errorCode: 400); // could not find location
      }));
    }

    bool checkIfCitySaved = await isStoredLocation(currentCity!); // checking if location is currently stored
    if (checkIfCitySaved) {
      weatherData = await getStoredLocation();
      if (!geocodingCityFailed) {
        weatherData.cityName = currentCity;
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomeScreen(
          locationWeather: weatherData,
          cityName: weatherData.cityName,
        );
      }));
    } else {
      // look up new location
      var response = await cloudFunctionsGetWeather(currentLocation.latitude, currentLocation.longitude);
      if (!global_gotWeatherSuccessfully) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return const ErrorScreen(errorCode: 503); // server is too full
        }));
      } else {
        //want to store this information into 1 weather object
        weatherData.setWeatherData(response);

        // save initial lookup into local storage
        if (!geocodingCityFailed) {
          weatherData.cityName = currentCity;
          setStoredLocation(currentCity, weatherData);
        }

        //send location to firebase for analytics
        _sendLocationToFirebase(weatherData);

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomeScreen(
            locationWeather: weatherData,
            cityName: weatherData.cityName,
          );
        }));
      }
    }
  }

  Future<void> _sendLocationToFirebase(WeatherData weatherData) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      global_userID = userCredential.user?.uid;
      if (kDebugMode) {
        print("Signed in with temporary account.");
      }
      await sendLocationData(weatherData.cityName);
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
