import 'package:flutter/material.dart';
import 'package:klimate/screens/loading_new_city.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/draggable_scrollable.dart';
import 'package:klimate/utilities/app_bar.dart';
import 'package:klimate/services/helper_functions.dart';
import '../utilities/gradient_text.dart';
import '../services/constants.dart';
import 'package:klimate/utilities/weather_data.dart';

// TODO: Not Working! If account is disabled, make it so can't use app, need a better way to identify user so can shadow ban them. also limit firebase read and writes per day incase of abuse
// TODO: Make it so checking if stored city is saved will be more precise, ie: city name + state/country not just city name
// TODO: make it so when doing a manual lookup, save that lookup somewhere just like saving the original location

// TODO: Add way to contribute through subscription using Google Wallet? or Google Pay? within the app itself and with error screen may need to add incentive like golden status or something, problem is how to check if user has subscribed or not when have no logins? use google play login?
// TODO: Add notification for tomorrows weather
// TODO: Going back on loading screen should do something when it takes forever to load
// TODO: Searching for new city only shows some of the cities by name not all of them, should be able to search by country too
// TODO: Time is not local city time when doing manual look up, it is your own local time
// TODO: check firebase database to see if city already exists in last 12 hours, if not then lookup and add to database
// TODO: sometimes it takes a really long time to load when installing for first time, make app reset after long time
// TODO: Setting/saving locations so can look up fast
// TODO: limit countries froggy can be in if releasing to production (english speaking only)

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.locationWeather,
    required this.cityName,
    this.isLookUp = false,
  });

  final WeatherData locationWeather;
  final String? cityName; // sending city name separate because it might be different for geocoding and openweather when using manual lookup
  final bool isLookUp;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List bottomWeatherList = [];

  @override
  void initState() {
    super.initState();
    print(widget.locationWeather.hourlyCodes);
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
              originalWeather: widget.locationWeather,
              isLookUp: widget.isLookUp,
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
                                      "${convertUnitsIfNeedBe(widget.locationWeather.currentTemperature)}°",
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
                          extraSizeForOnRefresh(),
                          extraSizeForOnRefresh(),
                          extraSizeForOnRefresh(),
                        ],
                      ),
                    ),
                    widget.isLookUp ? homeButton() : const SizedBox(),
                    draggableScrollableWeatherDetails(bottomWeatherList, context),
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
    // if reloading current city then push replacement
    String? currentCity = await getCurrentCityName(widget.locationWeather.lat, widget.locationWeather.long);
    if (currentCity != "") {
      if (currentCity?.toLowerCase() != widget.cityName?.toLowerCase()) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return LoadingNewCity(
            lat: widget.locationWeather.lat,
            long: widget.locationWeather.long,
            cityName: currentCity,
            originalWeather: widget.locationWeather,
            originalCity: widget.cityName,
          );
        }));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return LoadingNewCity(
            lat: widget.locationWeather.lat,
            long: widget.locationWeather.long,
            cityName: widget.cityName,
            originalWeather: widget.locationWeather,
            originalCity: widget.cityName,
          );
        }));
      }
    }
  }

  Widget extraSizeForOnRefresh() {
    return Expanded(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(),
      ),
    );
  }

  Widget homeButton() {
    return Positioned(
      // home button
      top: 0.0,
      left: 0.0,
      child: IconButton(
        onPressed: () {
          goToOriginalLocation(context);
        },
        icon: const Icon(
          Icons.home,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
