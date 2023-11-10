import 'package:flutter/material.dart';

import 'WeatherData.dart';
import 'constants.dart';

AppBar weatherAppBar(BuildContext context, WeatherData currentWeather) {
  return AppBar(
    leadingWidth: MediaQuery.of(context).size.width / 1.5,
    leading: Wrap(
      runAlignment: WrapAlignment.center,
      children: [
        Icon(Icons.location_on_outlined),
        Text(
          currentWeather.cityName,
          style: kCityLocationStyle,
          overflow: TextOverflow.ellipsis,
          textWidthBasis: TextWidthBasis.parent,
        ),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: PopupMenuButton<Widget>(
          child: Icon(
            Icons.settings,
            size: 32,
          ),
          itemBuilder: (context) => <PopupMenuEntry<Widget>>[
            PopupMenuItem<Widget>(
              child: TextButton(
                onPressed: () {
                  print("celsius");
                },
                child: Text("Celsius"),
              ),
            ),
            PopupMenuItem<Widget>(
              child: TextButton(
                onPressed: () {
                  print("fahrenheit");
                },
                child: Text("Fahrenheit"),
              ),
            ),
          ],
        ),
      ),
    ],
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}
