import 'package:flutter/material.dart';
import 'package:klimate/utilities/WeatherData.dart';

DraggableScrollableSheet DraggableScollableWeatherDetails(List bottomWeatherList) {
  return DraggableScrollableSheet(
    initialChildSize: 0.1,
    minChildSize: 0.1,
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
  List bottomWeatherList = [
    Text(
      "-",
      style: TextStyle(fontSize: MediaQuery.of(context).size.width / 10, color: Colors.grey),
    ),
    SizedBox(
      height: MediaQuery.of(context).size.width / 4,
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: 40,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Text(
            "hi",
            style: TextStyle(color: Colors.black),
          );
        },
      ),
    )
  ];
  return bottomWeatherList;
}
