import 'package:flutter/material.dart';
import 'package:klimate/utilities/WeatherData.dart';
import 'package:klimate/utilities/weatherListWidgets.dart';

DraggableScrollableSheet DraggableScollableWeatherDetails(List bottomWeatherList) {
  return DraggableScrollableSheet(
    initialChildSize: 0.15,
    minChildSize: 0.15,
    maxChildSize: 0.9,
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
  List hourlyWeatherTile = createWeatherTiles(currentWeather);

  List bottomWeatherList = [
    SizedBox(
      height: MediaQuery.of(context).size.width / 4,
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
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
    )
  ];
  return bottomWeatherList;
}
