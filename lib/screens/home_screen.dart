import 'package:flutter/material.dart';
import 'package:klimate/screens/loading_new_city.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/draggable_scrollable.dart';
import 'package:klimate/utilities/app_bar.dart';
import 'package:klimate/utilities/helper_functions.dart';
import '../utilities/gradient_text.dart';
import '../utilities/constants.dart';
import 'package:klimate/utilities/weather_data.dart';

// These will be in the next update
// Done: Added a way to refresh weather by pulling down
// Done: Servers are slightly more stable, more fixes incoming
// Done: changing system font size should no longer overflow any objects
// Done: Fixed location name changing when looking up other cities

// Known Issues:
// No way to change langauge
// No option for military time in settings
// when looking up locations, time is local time to you, not local time to the location
// Servers have a limit to how many users it can handle

// TODO: Add way to contribute through subscription using Google Wallet? or Google Pay? within the app itself and with error screen may need to add incentive like golden status or something, problem is how to check if user has subscribed or not when have no logins? use google play login?
// TODO: Add notification for weather updates (government thingy) and for tomorrows weather
// TODO: Add localization for other languages and be able to choose language
// TODO: Way to go back to original location when searching? would need to add logic to homescreen to know when searching
// TODO: Add military time in settings

// TODO: Going back on loading screen should do something when it takes forever to load
// TODO: Searching for new city only shows some of the cities by name not all of them
// TODO: Time is not local city time when doing manual look up, it is your own local time
// TODO: Make it so checking if stored city is saved will be more precise, ie: city name + state/country not just city name
// TODO: make it so when doing a manual lookup, save that lookup somewhere just like saving the original location
// TODO: check firebase database to see if city already exists in last 12 hours, if not then lookup and add to database
// TODO: sometimes it takes a really long time to load when installing for first time, make app reset after long time

// TODO: Should add tests if every updating this after it goes into production, don't want to unknowing break things by adding 1 small feature

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.locationWeather, required this.cityName});

  final WeatherData locationWeather;
  final String? cityName; // sending city name separate because it might be different for geocoding and openweather when using manual lookup

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
              ], stops: const [
                0.0,
                0.4,
              ])),
        ),
        SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: LocationAppBar(
              cityName: widget.cityName,
            ),
            body: ValueListenableBuilder(
              valueListenable: global_FahrenheitUnits,
              builder: (BuildContext context, int value, Widget? child) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    RefreshIndicator(
                      strokeWidth: 3,
                      semanticsLabel: "Refresh weather",
                      color: Colors.green,
                      onRefresh: _pullRefresh,
                      child: Column(
                        children: [
                          Flexible(
                            flex: 6,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    //padding: const EdgeInsets.only(left: 20.0),
                                    child: GradientText(
                                      "${convertUnitsIfNeedBe(widget.locationWeather.temperature)}°",
                                      style: kTempStyle,
                                      gradient: kTempGradient,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                widget.locationWeather.description.toTitleCase(),
                                style: kDescriptionStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(),
                            ),
                          )
                        ],
                      ),
                    ),
                    DraggableScollableWeatherDetails(bottomWeatherList, context),
                  ],
                );
              },
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _pullRefresh() async {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return LoadingNewCity(lat: widget.locationWeather.lat, long: widget.locationWeather.long, cityName: widget.cityName);
    }));
  }
}
