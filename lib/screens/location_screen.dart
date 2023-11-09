import 'package:flutter/material.dart';
import 'package:klimate/services/weather.dart';
import 'package:klimate/utilities/constants.dart';
import 'package:klimate/utilities/custom_icons.dart';
import 'package:klimate/utilities/helper_functions.dart';
import 'city_screen.dart';

//TODO: Once finished, clean up all unused fonts and constants
//TODO: add 24 hour forecast, add 7 day forecast (can use icons for these)
//TODO: Add little weather icon next to description

class LocationScreen extends StatefulWidget {
  LocationScreen({this.locationWeather});

  final locationWeather;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late WeatherModel weather;
  int temperature = 0;
  int condition = 0;
  String cityName = "";
  String description = "";
  late DateTime time;
  int timeHour = 0;
  String enteredLocation = "";
  int sunsetHour = 0;
  int sunriseHour = 1;
  int sunsetMinute = 0;
  int sunriseMinute = 0;
  int timeMinute = 0;
  late DateTime sunrise;
  late DateTime sunset;
  int highTemp = 0;
  int lowTemp = 0;

  @override
  void initState() {
    super.initState();
    updateUI(widget.locationWeather);
  }

  void updateUI(dynamic weatherData) {
    if (weatherData == null) {
      temperature = 0;
      cityName = "";
      description = "Oops! Could not locate weather for '$enteredLocation'";
      time = DateTime.now();
      weather = WeatherModel(condition: 1000, hour: 0, sunset: 0, sunrise: 1);

      return;
    }
    temperature = weatherData['main']['temp'].toInt();
    highTemp = weatherData['main']['temp_max'].toInt();
    lowTemp = weatherData['main']['temp_min'].toInt();
    condition = weatherData['weather'][0]['id'];
    cityName = weatherData['name'];
    description = weatherData["weather"][0]["description"];
    int timezone = weatherData['timezone'];
    DateTime localTime = DateTime.now().add(Duration(seconds: timezone - DateTime.now().timeZoneOffset.inSeconds));
    timeHour = localTime.hour;
    var timeSunrise = DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunrise'] * 1000);
    var timeSunset = DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunset'] * 1000);
    sunrise = timeSunrise.add(Duration(seconds: timezone - timeSunrise.timeZoneOffset.inSeconds));
    sunriseHour = sunrise.hour;
    sunriseMinute = sunrise.minute;
    sunset = timeSunset.add(Duration(seconds: timezone - timeSunrise.timeZoneOffset.inSeconds));
    sunsetHour = sunset.hour;
    sunsetMinute = sunset.minute;
    timeMinute = localTime.minute;
    weather = WeatherModel(condition: condition, hour: timeHour, sunrise: sunriseHour, sunset: sunsetHour);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: weather.appBarColor,
          leading: GestureDetector(
            onTap: () async {
              var weatherData = await getLocationWeather();
              setState(() {
                updateUI(weatherData);
              });
            },
            child: const Icon(
              Icons.my_location,
              size: 30,
              color: Colors.white,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                var typedName = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CityScreen();
                    },
                  ),
                );
                if (typedName != null) {
                  enteredLocation = typedName;
                  var weatherData = await weather.getCityWeather(typedName);
                  setState(() {
                    updateUI(weatherData);
                  });
                }
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.search,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: weather.weatherBackground,
              fit: BoxFit.cover,
            ),
          ),
          constraints: const BoxConstraints.expand(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: Row(
                    children: [
                      Text(
                        getLocalTime(timeHour, timeMinute),
                        style: kLocalTimeStyle,
                      ),
                      Column(
                        children: [
                          Text(
                            getAMPM(timeHour),
                            style: kLocalTimeAMPMStyle,
                          ),
                          const SizedBox(
                            height: 5,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                  child: Center(
                    child: Text(
                      cityName,
                      textAlign: TextAlign.center,
                      style: kCityLocationStyle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                  child: Center(
                    child: Text(
                      description.toCapitalized(),
                      textAlign: TextAlign.center,
                      style: kDescriptionStyle,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$temperature",
                      style: kTemperatureNumberStyle,
                    ),
                    Column(
                      children: const [
                        Text(
                          "°F",
                          style: kTempStyle,
                        ),
                        SizedBox(
                          height: 12,
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$highTemp°",
                      style: kTempHighLowStyle,
                    ),
                    const Icon(
                      Icons.arrow_upward,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      "$lowTemp°",
                      style: kTempHighLowStyle,
                    ),
                    const Icon(
                      Icons.arrow_downward,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getLocalTime(sunriseHour, sunriseMinute),
                      style: kSunsetSunriseStyle,
                    ),
                    Text(
                      getAMPM(sunriseHour),
                      style: kSunsetSunriseStyle,
                    ),
                    const Icon(
                      CustomIcons.sunrise,
                      color: Color(0xFFEFE79F),
                      size: 25,
                    ),
                    SizedBox(width: 15),
                    Text(
                      getLocalTime(sunsetHour, sunsetMinute),
                      style: kSunsetSunriseStyle,
                    ),
                    Text(
                      getAMPM(sunsetHour),
                      style: kSunsetSunriseStyle,
                    ),
                    const Icon(
                      CustomIcons.sunset,
                      color: Color(0xFFFFB852),
                      size: 25,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
