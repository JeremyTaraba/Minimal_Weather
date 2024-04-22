import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:klimate/screens/HomeScreen.dart';
import 'package:klimate/screens/error_screen.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/services/fetchWeather.dart';
import 'package:klimate/utilities/WeatherData.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:klimate/services/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utilities/helper_functions.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

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
      print("Permission enabled");
      var status = await Permission.location.status;
      if (status.isGranted) {
        //location permission is granted
        print("Permission granted");
        getLocationData();
      } else {
        //location permission is not granted
        print("Permission not granted");
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
      print("Permission not enabled");
    }
    if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    }
    return true;
  }

  void getLocationData() async {
    Location currentLocation = Location();
    await currentLocation.getCurrentLocation();
    global_CurrentWeatherData = await getCurrentLocationWeather(currentLocation); //calls the current weather api
    global_HourlyWeatherData = await getHourlyLocationWeather(currentLocation); //calls the hourly weather api
    global_ForecastWeatherData = await getFiveDayForecastWithLatLon(currentLocation); //calls the forecast weather api

    CloudFunctionsGetWeather(currentLocation.latitude, currentLocation.longitude); // using cloud functions to get weather

    if (!global_gotWeatherSuccessfully) {
      print("there was an error");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ErrorScreen();
      }));
    } else {
      //want to store this information from both apis into 1 global weather object
      WeatherData currentWeatherData = WeatherData();
      global_FahrenheitUnits.value = await getTemperatureUnits();

      //send location to firebase for analytics
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        global_userID = userCredential.user?.uid;
        print("Signed in with temporary account.");
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "operation-not-allowed":
            print("Anonymous auth hasn't been enabled for this project.");
            break;
          default:
            print("Unknown error.");
        }
      }

      await sendLocationData(currentWeatherData.cityName);

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HomeScreen(
          locationWeather: currentWeatherData,
        );
      }));
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
