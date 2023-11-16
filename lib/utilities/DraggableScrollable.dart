import 'package:flutter/material.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/services/weather.dart';
import 'package:klimate/utilities/WeatherData.dart';
import 'package:klimate/utilities/weatherListWidgets.dart';

DraggableScrollableSheet DraggableScollableWeatherDetails(List bottomWeatherList) {
  return DraggableScrollableSheet(
    initialChildSize: 0.15,
    minChildSize: 0.15,
    maxChildSize: 0.99,
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
  List bottomWeatherList = [];

  bottomWeatherList.add(ScollableWeatherTiles(context));
  bottomWeatherList.add(SevenDayForecast(context));
  bottomWeatherList.add(DetailsOfTheDay());
  return bottomWeatherList;
}

Card ScollableWeatherTiles(BuildContext context) {
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

Card DetailsOfTheDay() {
  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
    child: Row(
      children: [
        Container(
          height: 100,
          width: 100,
          color: Colors.red,
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.green,
        ),
        Container(
          height: 100,
          width: 100,
          color: Colors.blue,
        )
      ],
    ),
  );
}
