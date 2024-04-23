import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/global_variables.dart';
import '../services/fetchWeather.dart';
import '../utilities/WeatherData.dart';
import '../utilities/helper_functions.dart';
import 'HomeScreen.dart';

class loadingNewCity extends StatefulWidget {
  loadingNewCity({super.key, required this.lat, required this.long, required this.cityName});
  num lat;
  num long;
  String cityName;
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
    // global_CurrentWeatherData = await getCurrentLocationWeatherWithLatLon(widget.lat, widget.long); //calls the current weather api
    // global_HourlyWeatherData = await getHourlyLocationWeatherWithLatLon(widget.lat, widget.long); //calls the hourly weather api

    //want to store this information from both apis into 1 global weather object
    WeatherData currentWeatherData = WeatherData();
    currentWeatherData.cityName = widget.cityName;
    print(currentWeatherData.cityName);
    global_FahrenheitUnits.value = await getTemperatureUnits();
    await sendLocationData("${currentWeatherData.cityName}: manual lookup");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomeScreen(
        locationWeather: currentWeatherData,
      );
    }));
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
