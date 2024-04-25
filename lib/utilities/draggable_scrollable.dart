import 'package:flutter/material.dart';

import 'package:klimate/utilities/weather_data.dart';
import 'package:klimate/utilities/weather_list_widgets.dart';

DraggableScrollableSheet DraggableScollableWeatherDetails(List bottomWeatherList, BuildContext context) {
  return DraggableScrollableSheet(
    initialChildSize: MediaQuery.of(context).textScaler.scale(0.17),
    minChildSize: 0.17,
    maxChildSize: 1,
    builder: (BuildContext context, ScrollController scrollController) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          controller: scrollController,
          itemCount: bottomWeatherList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [bottomWeatherList[index]],
            );
          },
        ),
      ),
    ),
  );
}

List createBottomWeatherList(BuildContext context, WeatherData currentWeather) {
  List bottomWeatherList = [
    scrollableWeatherTiles(context, currentWeather),
    sevenDayForecast(context, currentWeather),
    DetailsOfTheDay(context, currentWeather),
    //AdMobBanner() //ad space
  ];

  return bottomWeatherList;
}

Card scrollableWeatherTiles(BuildContext context, WeatherData currentWeather) {
  List hourlyWeatherTile = createWeatherTiles(currentWeather);
  return Card(
    color: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
    child: SizedBox(
      height: MediaQuery.of(context).textScaler.scale(MediaQuery.of(context).size.width / 3.3),
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: hourlyWeatherTile.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            child: hourlyWeatherTile[index],
            padding: const EdgeInsets.all(10),
          );
        },
      ),
    ),
  );
}

Widget sevenDayForecast(BuildContext context, WeatherData currentWeather) {
  List dailyWeatherBanner = createWeatherBanners(currentWeather, context);
  return ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: dailyWeatherBanner.length,
    itemBuilder: (BuildContext context, int index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Card(color: Colors.white, child: dailyWeatherBanner[index]),
      );
    },
  );
}

Card DetailsOfTheDay(BuildContext context, WeatherData currentWeather) {
  double cardHeight = MediaQuery.of(context).textScaler.scale(MediaQuery.of(context).size.height) / 9;
  return Card(
    elevation: 0,
    color: Colors.transparent,
    child: Column(
      children: [
        //createSunriseSunset(currentWeather),
        Row(
          children: [
            Flexible(fit: FlexFit.tight, child: SizedBox(height: cardHeight, child: createHumidity(currentWeather))),
            Flexible(fit: FlexFit.tight, child: SizedBox(height: cardHeight, child: createWind(currentWeather))),
            Flexible(fit: FlexFit.tight, child: SizedBox(height: cardHeight, child: createUVIndex(currentWeather))),
          ],
        ),
        createSunriseSunset(currentWeather),
      ],
    ),
  );
}

Container adMobBanner() {
  return Container(
    height: 50,
    width: 320,
    color: Colors.green,
  );
}
