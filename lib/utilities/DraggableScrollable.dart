import 'package:flutter/material.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/WeatherData.dart';
import 'package:klimate/utilities/weatherListWidgets.dart';

DraggableScrollableSheet DraggableScollableWeatherDetails(List bottomWeatherList) {
  return DraggableScrollableSheet(
    initialChildSize: 0.15,
    minChildSize: 0.15,
    maxChildSize: 1,
    builder: (BuildContext context, ScrollController scrollController) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        color: Colors.white70,
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
    ScollableWeatherTiles(context, currentWeather),
    SevenDayForecast(context),
    DetailsOfTheDay(context, currentWeather),
    AdMobBanner()
  ];

  return bottomWeatherList;
}

Card ScollableWeatherTiles(BuildContext context, WeatherData currentWeather) {
  List hourlyWeatherTile = createWeatherTiles();
  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
    child: SizedBox(
      height: MediaQuery.of(context).size.width / 4,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: hourlyWeatherTile.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            child: hourlyWeatherTile[index],
            padding: EdgeInsets.all(10),
          );
        },
      ),
    ),
  );
}

SizedBox SevenDayForecast(BuildContext context) {
  List dailyWeatherBanner = createWeatherBanners();
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: dailyWeatherBanner.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          child: Card(color: Colors.white, child: dailyWeatherBanner[index]),
          padding: EdgeInsets.symmetric(horizontal: 2),
        );
      },
    ),
  );
}

Card DetailsOfTheDay(BuildContext context, WeatherData currentWeather) {
  double cardHeight = MediaQuery.of(context).size.height / 9;
  return Card(
    elevation: 0,
    color: Colors.transparent,
    child: Column(
      children: [
        //createSunriseSunset(currentWeather),
        Row(
          children: [
            Expanded(child: SizedBox(height: cardHeight, child: createHumidity(currentWeather))),
            Expanded(child: SizedBox(height: cardHeight, child: createWind(currentWeather))),
            Expanded(child: SizedBox(height: cardHeight, child: createUVIndex(currentWeather))),
          ],
        ),
        createSunriseSunset(currentWeather),
      ],
    ),
  );
}

Container AdMobBanner() {
  return Container(
    height: 50,
    width: 320,
    color: Colors.green,
  );
}
