import 'package:flutter/material.dart';
import 'package:klimate/utilities/custom_icons.dart';
import 'package:klimate/utilities/helper_functions.dart';
import 'package:klimate/services/weather.dart';
import '../utilities/constants.dart';
import 'package:klimate/utilities/WeatherData.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.locationWeather});

  final locationWeather;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherData currentWeather = WeatherData();

  @override
  void initState() {
    super.initState();
    currentWeather.updateUI(widget.locationWeather);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          leadingWidth: MediaQuery.of(context).size.width / 2,
          leading: Wrap(
            children: [
              Icon(Icons.location_on_outlined),
              Text(
                currentWeather.cityName,
                style: kCityLocationStyle,
                overflow: TextOverflow.ellipsis,
                textWidthBasis: TextWidthBasis.parent,
              ),
            ],
          ),
          actions: [
            Icon(Icons.settings),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Text(currentWeather.temperature.toString()),
      ),
    );
  }
}
