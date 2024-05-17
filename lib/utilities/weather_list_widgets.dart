import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:klimate/services/helper_functions.dart';
import 'weather_data.dart';
import '../services/constants.dart';
import '../services/custom_icons.dart';

class WeatherTile {
  int twentyFourHour = 0;
  String icon = "";
  num temp = 0;
  String description = "";
  String ifRain = "";
  num chanceOfRain = 0;
  WeatherTile(this.twentyFourHour, this.icon, this.temp, this.description, this.ifRain, this.chanceOfRain);

  Column _generateTile(int tileNumber) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          child: ConvertTimeUnits(hour: twentyFourHour, minutes: 0),
        ),
        Flexible(
          child: Text(
            ifRain == "Rain" ? "${(chanceOfRain * 100).toInt()}%" : "",
            style: const TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
        // if chance of rain is above 30% change icon to rain icon
        getWeatherIcon(chanceOfRain * 100 > 30 ? "09n" : icon, 40, description),
        Flexible(
          child: ConvertTempUnits(
            temp: temp,
            textStyle: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ],
    );
  }
}

List createWeatherTiles(WeatherData currentWeather) {
  if (currentWeather.apiUsed == "openmeteo") {
    return createWeatherTilesOpenMeteo(currentWeather);
  } else {
    return createWeatherTilesOpenWeather(currentWeather);
  }
}

List createWeatherTilesOpenWeather(WeatherData currentWeather) {
  List weatherTiles = [];
  var hourly = currentWeather.hourlyTemperatures;

  // this block is to check how long it has been since last got the time. Need it since we save the weather for 12 hours to reduce fetch requests
  int hourlyGetTimeInt = hourly[0]["dt"];
  var hourlyGetTimeDate = DateTime.fromMillisecondsSinceEpoch(hourlyGetTimeInt * 1000);
  var timeDifference = DateTime.now().difference(hourlyGetTimeDate);
  int startIndex = 0 + timeDifference.inHours;
  int endIndex = 24 + timeDifference.inHours;
  // end block

  for (int i = startIndex; i < endIndex; i++) {
    int epochTime = hourly[i]["dt"];
    var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);

    WeatherTile temp = WeatherTile(date.hour, hourly[i]["weather"][0]["icon"], hourly[i]["temp"], hourly[i]["weather"][0]["description"],
        hourly[i]["weather"][0]["main"], hourly[i]["pop"]);
    weatherTiles.add(temp._generateTile(i));
  }
  return weatherTiles;
}

List createWeatherTilesOpenMeteo(WeatherData currentWeather) {
  List weatherTiles = [];

  // this block is to check how long it has been since last got the time. And shifts the hours
  int hourlyGetTimeInt = currentWeather.hourlyTime[0];
  var hourlyGetTimeDate = DateTime.fromMillisecondsSinceEpoch(hourlyGetTimeInt * 1000);
  var timeDifference = DateTime.now().difference(hourlyGetTimeDate);
  int startIndex = 0 + timeDifference.inHours;
  int endIndex = 24 + timeDifference.inHours;
  // end block

  int condition = 0;
  for (int i = startIndex; i < endIndex; i++) {
    int epochTime = currentWeather.hourlyTime[i];
    var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    condition = currentWeather.hourlyCodes[i];
    WeatherTile temp = WeatherTile(
      date.hour,
      getOpenWeatherIconFromCondition(condition, currentWeather.sunset, date, currentWeather.sunrise, false),
      currentWeather.hourlyTemperatures[i],
      getDescriptionFromCondition(condition),
      currentWeather.hourlyPrecipitation[i] / 100 > 10 ? "Rain" : "",
      currentWeather.hourlyPrecipitation[i] / 100,
    );
    weatherTiles.add(temp._generateTile(i));
  }
  return weatherTiles;
}

List createWeatherTilesFiveDays(List forecastList, WeatherData currentWeather, int dayIndex) {
  if (currentWeather.apiUsed == "openmeteo") {
    return createWeatherTilesFiveDaysOpenMeteo(currentWeather, dayIndex);
  } else {
    return createWeatherTilesFiveDaysOpenWeather(forecastList);
  }
}

List createWeatherTilesFiveDaysOpenWeather(List forecastList) {
  List weatherTiles = [];
  Widget blank = const SizedBox(
    width: 10,
  );

  for (int i = 0; i < forecastList.length; i++) {
    int epochTime = forecastList[i]["dt"];
    var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);

    WeatherTile temp = WeatherTile(date.hour, forecastList[i]["weather"][0]["icon"], forecastList[i]["main"]["temp"],
        forecastList[i]["weather"][0]["description"], forecastList[i]["weather"][0]["main"], forecastList[i]["pop"]);
    weatherTiles.add(temp._generateTile(i));
    weatherTiles.add(blank);
  }
  return weatherTiles;
}

List createWeatherTilesFiveDaysOpenMeteo(WeatherData currentWeather, int dayIndex) {
  List weatherTiles = [];
  Widget blank = const SizedBox(
    width: 10,
  );
  int condition = 0;
  int startIndex = dayIndex * 24;
  int endIndex = (dayIndex + 1) * 24;
  for (int i = startIndex; i < endIndex; i++) {
    int epochTime = currentWeather.hourlyTime[i];
    var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    condition = currentWeather.hourlyCodes[getHourlyTimeGivenTime(currentWeather.hourlyTime, date)];
    WeatherTile temp = WeatherTile(
      date.hour,
      getOpenWeatherIconFromCondition(condition, currentWeather.sunset, date, currentWeather.sunrise, false),
      getHourlyTemperatureGivenTime(currentWeather.hourlyTemperatures, currentWeather.hourlyTime, date),
      getDescriptionFromCondition(condition),
      currentWeather.hourlyPrecipitation[i] > 10 ? "Rain" : "",
      currentWeather.hourlyPrecipitation[i] / 100,
    );
    weatherTiles.add(temp._generateTile(i));
    weatherTiles.add(blank);
  }
  return weatherTiles;
}

Widget scrollableWeatherFiveDays(int index, WeatherData currentWeather, BuildContext context) {
  List forecastList = [];
  if (currentWeather.apiUsed == "openweather") {
    //index tells us which day it is. 0 - 4, 0 being today and 1 being the next day
    //can use this to filter through the list of forecasts for the appropriate day
    // create a list to send to weatherTilesFiveDays which is just the time we need
    var now = DateTime.now();
    now = now.add(Duration(days: index));
    List forecastWeather = currentWeather.forecastList;

    for (int i = 0; i < forecastWeather.length; i++) {
      DateTime localTime =
          DateTime.parse(forecastWeather[i]["dt_txt"] + " Z").toLocal(); // Z is for utc which is needs to be in for converting to local
      if (localTime.toString().split(' ')[0] == now.toString().split(' ')[0]) {
        forecastList.add(forecastWeather[i]);
      }
      print(forecastWeather[i]["main"]["temp"]);
    }
  }

  List hourlyWeatherTile = createWeatherTilesFiveDays(forecastList, currentWeather, index);
  return SizedBox(
    height: MediaQuery.of(context).textScaler.scale(MediaQuery.of(context).size.width) / 3.5,
    child: ListView.builder(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: hourlyWeatherTile.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          child: hourlyWeatherTile[index],
          padding: const EdgeInsets.only(left: 3, right: 3),
        );
      },
    ),
  );
}

class WeatherBanner {
  int weekDay; //1 = Monday, 7 = Sunday
  String icon = "";
  num minTemp = 0;
  num maxTemp = 0;
  String description = "";
  int index = 6;

  WeatherBanner(this.weekDay, this.icon, this.minTemp, this.maxTemp, this.description, this.index);

  Widget _generateBanner(WeatherData currentWeather, BuildContext context) {
    if ((0 < index && index < 5) || (currentWeather.apiUsed == "openmeteo" && index != 0)) {
      ExpandableController controller = ExpandableController();
      return ExpandableNotifier(
        controller: controller,
        child: ScrollOnExpand(
          child: ExpandablePanel(
            theme: const ExpandableThemeData(
              tapBodyToCollapse: true,
              iconPlacement: ExpandablePanelIconPlacement.right,
              hasIcon: true,
            ),
            header: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    getDayFromWeekday(weekDay),
                    style: kBannerStyle,
                  ),
                ),
                Flexible(child: Container()),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: getWeatherIcon(icon, 40, description),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      ConvertTempUnits(
                        temp: maxTemp,
                        textStyle: kBannerTempsStyle,
                      ),
                      const Text(
                        "/",
                        style: TextStyle(color: Colors.black),
                      ),
                      ConvertTempUnits(
                        temp: minTemp,
                        textStyle: kBannerTempsStyle,
                      ),
                    ],
                  ),
                )
              ],
            ),
            collapsed: const SizedBox(),
            expanded: scrollableWeatherFiveDays(index, currentWeather, context),
            builder: (_, collapsed, expanded) {
              return Expandable(
                collapsed: collapsed,
                expanded: expanded,
                theme: const ExpandableThemeData(crossFadePoint: 0.6),
              );
            },
          ),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              getDayFromWeekday(weekDay),
              style: kBannerStyle,
            ),
          ),
          Flexible(child: Container()),
          Flexible(
            //padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: getWeatherIcon(icon, 40, description),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                ConvertTempUnits(
                  temp: maxTemp,
                  textStyle: kBannerTempsStyle,
                ),
                const Text(
                  "/",
                  style: kBannerStyle,
                ),
                ConvertTempUnits(
                  temp: minTemp,
                  textStyle: kBannerTempsStyle,
                ),
                const SizedBox(
                  width: 40,
                ),
              ],
            ),
          )
        ],
      );
    }
  }
}

List createWeatherBanners(WeatherData currentWeather, BuildContext context) {
  List weatherBanners = [];

  int condition = 0;
  if (currentWeather.apiUsed == "openmeteo") {
    for (int i = 0; i < 7; i++) {
      int epochTime = currentWeather.hourlyTime[i * 24];
      var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);

      condition = getMedianCondition(currentWeather.hourlyCodes, i * 24, (i + 1) * 24, currentWeather.hourlyPrecipitation);
      WeatherBanner temp = WeatherBanner(
        i == 0 ? 0 : date.weekday,
        getOpenWeatherIconFromCondition(condition, currentWeather.sunset, date, currentWeather.sunrise, true),
        getMinTemps(currentWeather.hourlyTemperatures, i * 24, (i + 1) * 24),
        getMaxTemps(currentWeather.hourlyTemperatures, i * 24, (i + 1) * 24),
        getDescriptionFromCondition(condition),
        i,
      );
      weatherBanners.add(temp._generateBanner(currentWeather, context));
    }
  } else {
    var daily = currentWeather.daily;
    for (int i = 0; i < daily.length; i++) {
      int epochTime = daily[i]["dt"];
      var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
      WeatherBanner temp = WeatherBanner(
        i == 0 ? 0 : date.weekday,
        daily[i]["weather"][0]["icon"],
        daily[i]["temp"]["min"],
        daily[i]["temp"]["max"],
        daily[i]["weather"][0]["description"],
        i,
      );
      weatherBanners.add(temp._generateBanner(currentWeather, context));
    }
  }
  return weatherBanners;
}

Card createSunriseSunset(WeatherData currentWeather) {
  return Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Sunrise ",
                  style: kSunsetSunriseStyle,
                ),
                const Icon(
                  CustomIcons.sunrise,
                  color: Colors.orangeAccent,
                  size: 40,
                ),
                ConvertTimeUnits(
                  hour: currentWeather.sunrise.hour,
                  minutes: currentWeather.sunrise.minute,
                  textStyle: kSunsetSunriseStyle,
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Row(
              children: [
                const Text(
                  "Sunset ",
                  style: kSunsetSunriseStyle,
                ),
                const Icon(
                  CustomIcons.sunset,
                  color: Colors.blue,
                  size: 40,
                ),
                ConvertTimeUnits(
                  hour: currentWeather.sunset.hour,
                  minutes: currentWeather.sunset.minute,
                  textStyle: kSunsetSunriseStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget createHumidity(WeatherData currentWeather) {
  return createIndexCard("${currentWeather.humidity}%", "Humidity", Icons.water_drop, Colors.indigo);
}

Widget createWind(WeatherData currentWeather) {
  return createIndexCard(metersSecondToMph(currentWeather.windSpeed), "Wind", Icons.air, Colors.lightBlueAccent);
}

Widget createUVIndex(WeatherData currentWeather) {
  return createIndexCard(currentWeather.uvIndex, "UV Index", Icons.sunny, Colors.deepPurple);
}

Widget createIndexCard(dynamic data, String text, IconData icon, Color iconColor) {
  return Card(
    color: Colors.white,
    child: Column(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: Text(
            text,
            style: kIndexCardStyle,
          ),
        ),
        Flexible(
          child: Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "$data",
            style: kIndexCardStyle,
          ),
        ),
      ],
    ),
  );
}
