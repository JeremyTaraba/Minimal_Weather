import 'package:flutter/material.dart';
import 'package:klimate/utilities/DraggableScrollable.dart';
import 'package:klimate/utilities/appBar.dart';
import 'package:klimate/utilities/custom_icons.dart';
import 'package:klimate/utilities/helper_functions.dart';
import 'package:klimate/services/weather.dart';
import '../utilities/GradientText.dart';
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
  List bottomWeatherList = [];

  @override
  void initState() {
    super.initState();
    currentWeather.updateUI(widget.locationWeather);
  }

  @override
  Widget build(BuildContext context) {
    bottomWeatherList = createBottomWeatherList(context, currentWeather);
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/clear/day/1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: weatherAppBar(context, currentWeather),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Flexible(flex: 1, child: Container()),
                    Flexible(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: GradientText(
                              "${currentWeather.temperature}°",
                              style: kTempStyle,
                              gradient: kTempGradient,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                currentWeather.description.toTitleCase(),
                                style: kDescriptionStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                DraggableScollableWeatherDetails(bottomWeatherList),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
