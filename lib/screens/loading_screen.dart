import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:klimate/screens/HomeScreen.dart';
import 'package:klimate/screens/error_screen.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/services/fetchWeather.dart';
import 'package:klimate/utilities/WeatherData.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:klimate/services/location.dart';

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
    // check to see if we need to make another API response or not by reading local weather file
    // String content =
    //     await readWeatherData(); //TODO: Remove this and make it so you can check the 1 global object which is the only thing saved in secure storage/ shared preferences

    //if there is data in the file
    // if (content != "Error") {
    //   int i = 0;
    //   String lastWrite = "";
    // while (content[i] != "\n" || i < content.length) {
    //   lastWrite += content[i];
    //   i++;
    // }
    //DateTime writeTime = DateTime.parse(lastWrite);
    //check to see if writeTime is larger than 1 hour
    // if yes, can make new API request and write to file
    // if no, weatherDataOld = read from file
    // } else {
    //   // we can make a new API request and write to file
    // }

    Location currentLocation = Location();
    await currentLocation.getCurrentLocation();
    global_CurrentWeatherData = await getCurrentLocationWeather(currentLocation); //calls the current weather api
    global_HourlyWeatherData = await getHourlyLocationWeather(currentLocation); //calls the hourly weather api
    global_ForecastWeatherData = await getFiveDayForecastWithLatLon(currentLocation); //calls the forecast weather api

    if (global_gotWeatherSuccessfully) {
      print("there was an error");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ErrorScreen();
      }));
    } else {
      //want to store this information from both apis into 1 global weather object
      WeatherData currentWeatherData = WeatherData();
      global_FahrenheitUnits.value = await getTemperatureUnits();

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
