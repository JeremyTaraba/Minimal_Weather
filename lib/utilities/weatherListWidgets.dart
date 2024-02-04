import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/helper_functions.dart';

import 'WeatherData.dart';
import 'custom_icons.dart';

class WeatherTile {
  int twentyFourHour = 0;
  String icon = "";
  num temp = 0;
  String description = "";
  String main = "";
  num pop = 0;
  WeatherTile(this.twentyFourHour, this.icon, this.temp, this.description, this.main, this.pop);

  Column _generateTile(int tileNumber) {
    return Column(
      children: [
        Text(
          getTimeWithAMPM(twentyFourHour, 0),
          style: TextStyle(color: Colors.black),
        ),
        Container(
          height: 20,
          child: Text(
            main == "Rain" ? "${(pop * 100).toInt()}%" : "",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        getWeatherIcon(icon, 40, description),
        convertTempUnits(
          temp: temp,
          textStyle: TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}

List createWeatherTiles() {
  List weatherTiles = [];
  var hourly = global_HourlyWeatherData["hourly"];

  for (int i = 0; i < 24; i++) {
    int epochTime = hourly[i]["dt"];
    var date = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);

    WeatherTile temp = WeatherTile(date.hour, hourly[i]["weather"][0]["icon"], hourly[i]["temp"], hourly[i]["weather"][0]["description"],
        hourly[i]["weather"][0]["main"], hourly[i]["pop"]);
    weatherTiles.add(temp._generateTile(i));
  }
  return weatherTiles;
}

List createWeatherTilesFiveDays(List forecastList) {
  List weatherTiles = [];
  Widget blank = SizedBox(
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

Widget scrollableWeatherFiveDays(int index) {
  //index tells us which day it is. 0 - 4, 0 being today and 1 being the next day
  //can use this to filter through the list of forecasts for the appropriate day
  // create a list to send to weatherTilesFiveDays which is just the time we need

  var now = DateTime.now();
  now = now.add(Duration(days: index));
  List forecastList = [];

  List forecastWeather = global_ForecastWeatherData["list"];

  for (int i = 0; i < forecastWeather.length; i++) {
    DateTime localTime =
        DateTime.parse(forecastWeather[i]["dt_txt"] + " Z").toLocal(); // Z is for utc which is needs to be in for converting to local
    if (localTime.toString().split(' ')[0] == now.toString().split(' ')[0]) {
      forecastList.add(forecastWeather[i]);
    }
  }

  List hourlyWeatherTile = createWeatherTilesFiveDays(forecastList);
  return SizedBox(
    height: 100, //MediaQuery.of(context).size.width / 3.3,
    child: ListView.builder(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: hourlyWeatherTile.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          child: hourlyWeatherTile[index],
          padding: EdgeInsets.all(0),
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

  Widget _generateBanner() {
    if (0 < index && index < 5) {
      ExpandableController controller = ExpandableController();
      return ExpandableNotifier(
        controller: controller,
        child: ScrollOnExpand(
          child: ExpandablePanel(
            theme: ExpandableThemeData(
              tapBodyToCollapse: true,
              iconPlacement: ExpandablePanelIconPlacement.right,
            ),
            header: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    getDayFromWeekday(weekDay),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Flexible(child: Container()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: getWeatherIcon(icon, 40, description),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      convertTempUnits(
                        temp: maxTemp,
                        textStyle: TextStyle(color: Colors.black),
                      ),
                      Text(
                        "/",
                        style: TextStyle(color: Colors.black),
                      ),
                      convertTempUnits(
                        temp: minTemp,
                        textStyle: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                )
              ],
            ),
            collapsed: SizedBox(),
            expanded: scrollableWeatherFiveDays(index),
            builder: (_, collapsed, expanded) {
              return Expandable(
                collapsed: collapsed,
                expanded: expanded,
                theme: const ExpandableThemeData(crossFadePoint: 0),
              );
            },
          ),
        ),
      );
    } else {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              getDayFromWeekday(weekDay),
              style: TextStyle(color: Colors.black),
            ),
          ),
          Flexible(child: Container()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: getWeatherIcon(icon, 40, description),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                convertTempUnits(
                  temp: maxTemp,
                  textStyle: TextStyle(color: Colors.black),
                ),
                Text(
                  "/",
                  style: TextStyle(color: Colors.black),
                ),
                convertTempUnits(
                  temp: minTemp,
                  textStyle: TextStyle(color: Colors.black),
                ),
                SizedBox(
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

List createWeatherBanners() {
  List weatherBanners = [];

  var daily = global_HourlyWeatherData["daily"];

  for (int i = 0; i < 8; i++) {
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
    weatherBanners.add(temp._generateBanner());
  }
  return weatherBanners;
}

Card createSunriseSunset(WeatherData currentWeather) {
  return Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Sunrise ",
                style: TextStyle(color: Colors.black),
              ),
              Icon(
                CustomIcons.sunrise,
                color: Colors.orangeAccent,
                size: 40,
              ),
              Text("${getLocalTime(currentWeather.sunrise.hour, currentWeather.sunrise.minute)} ${getAMPM(currentWeather.sunrise.hour)}",
                  style: TextStyle(color: Colors.black)),
            ],
          ),
          Row(
            children: [
              Text(
                "Sunset ",
                style: TextStyle(color: Colors.black),
              ),
              Icon(
                CustomIcons.sunset,
                color: Colors.blue,
                size: 40,
              ),
              Text(
                "${getLocalTime(currentWeather.sunset.hour, currentWeather.sunset.minute)} ${getAMPM(currentWeather.sunset.hour)}",
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
        ],
      ),
    ),
  );
}

Card createHumidity(WeatherData currentWeather) {
  return createIndexCard("${currentWeather.humidity}%", "Humidity", Icons.water_drop, Colors.indigo);
}

Card createWind(WeatherData currentWeather) {
  return createIndexCard(metersSecondToMph(currentWeather.windSpeed), "Wind", Icons.air, Colors.lightBlueAccent);
}

Card createUVIndex(WeatherData currentWeather) {
  return createIndexCard(currentWeather.uvIndex, "UV Index", Icons.sunny, Colors.deepPurple);
}

Card createIndexCard(dynamic data, String text, IconData icon, Color iconColor) {
  return Card(
    color: Colors.white,
    child: Column(
      children: [
        Text(
          text,
          style: TextStyle(color: Colors.black),
        ),
        Icon(
          icon,
          color: iconColor,
          size: 30,
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "$data",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
