import 'package:flutter/material.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/DraggableScrollable.dart';
import 'package:klimate/utilities/appBar.dart';
import 'package:klimate/utilities/helper_functions.dart';
import '../utilities/GradientText.dart';
import '../utilities/constants.dart';
import 'package:klimate/utilities/WeatherData.dart';

// TODO: Add way to contribute through subscription using Google Wallet? or Google Pay? within the app itself and with error screen may need to add incentive like golden status or something, problem is how to check if user has subscribed or not when have no logins? use google play login?
// TODO: Add notification for weather updates (government thingy) and for tomorrows weather
// TODO: Add localization for other languages and be able to choose language
// TODO: Add a way to refresh weather by pulling down (changes wallpaper) and also go back to original location when searching
// TODO: Limit to 1 refresh per 12 hours (will use the 48 hour forecast to update the 24 hour)
// TODO: Fix it so that changing system font size does not overflow any objects
// TODO: make it so the weather list isn't constant size of 7 but gets size of list
// TODO: Time is not local time, can add local time somewhere or change all the times to local
// TODO: Something is wrong with manual lookup where it changes city name
// TODO: Fix loading new location, broke it when adding firebase functions and deleting global_weatherVariables

// TODO: Save location lookups to local storage, check lookups to see if have looked up in last 12 hours before doing a lookup then
// TODO: check firebase database to see if city already exists in last 12 hours, if not then lookup and add to database

// Done: Before going into production MUST encrypt api key / api call then refresh key before final upload

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.locationWeather});

  final WeatherData locationWeather;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List bottomWeatherList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bottomWeatherList = createBottomWeatherList(context, widget.locationWeather);
    return PopScope(
      canPop: false,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: widget.locationWeather.background,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [
                Colors.black.withOpacity(.5),
                Colors.transparent,
              ], stops: [
                0.0,
                0.4,
              ])),
        ),
        SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: LocationAppBar(
              currentWeather: widget.locationWeather,
            ),
            body: ValueListenableBuilder(
              valueListenable: global_FahrenheitUnits,
              builder: (BuildContext context, int value, Widget? child) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Column(
                      children: [
                        Flexible(
                          flex: 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: GradientText(
                                  "${convertUnitsIfNeedBe(widget.locationWeather.temperature)}°",
                                  style: kTempStyle,
                                  gradient: kTempGradient,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Text(
                            widget.locationWeather.description.toTitleCase(),
                            style: kDescriptionStyle,
                          ),
                        ),
                      ],
                    ),
                    DraggableScollableWeatherDetails(bottomWeatherList),
                  ],
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}
