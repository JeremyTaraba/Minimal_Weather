import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/global_variables.dart';
import '../services/weather.dart';
import '../utilities/WeatherData.dart';
import '../utilities/helper_functions.dart';
import 'HomeScreen.dart';

class loadingNewCity extends StatefulWidget {
  loadingNewCity({super.key, required this.lat, required this.long});
  num lat;
  num long;
  @override
  State<loadingNewCity> createState() => _loadingNewCityState();
}

class _loadingNewCityState extends State<loadingNewCity> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadNewCity();
  }

  loadNewCity() async {
    global_CurrentWeatherData = await getCurrentLocationWeatherWithLatLon(widget.lat, widget.long); //calls the current weather api
    global_HourlyWeatherData = await getHourlyLocationWeatherWithLatLon(widget.lat, widget.long); //calls the hourly weather api

    //want to store this information from both apis into 1 global weather object
    WeatherData currentWeatherData = WeatherData();
    global_FahrenheitUnits.value = await getTemperatureUnits();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomeScreen(
        locationWeather: currentWeatherData,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: SpinKitCubeGrid(
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }
}
