import 'package:flutter/material.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/helper_functions.dart';

import 'constants.dart';

class LocationAppBar extends StatefulWidget implements PreferredSizeWidget {
  const LocationAppBar({super.key, @required this.currentWeather});
  final currentWeather;
  @override
  State<LocationAppBar> createState() => _LocationAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LocationAppBarState extends State<LocationAppBar> {
  TextEditingController cityName = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cityName.text = widget.currentWeather.cityName;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: MediaQuery.of(context).size.width / 1.5,
      leading: Wrap(
        runAlignment: WrapAlignment.center,
        children: [
          Icon(Icons.location_on_outlined),
          TextField(
            controller: cityName,
            style: kCityLocationStyle,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: PopupMenuButton<Widget>(
            child: const Icon(
              Icons.settings,
              size: 32,
            ),
            itemBuilder: (context) => <PopupMenuEntry<Widget>>[
              PopupMenuItem<Widget>(
                onTap: () {
                  setToCelsius();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: Icon(
                        Icons.circle,
                        size: 20,
                        color: global_FahrenheitUnits.value == 1 ? Colors.white30 : Colors.green,
                      ),
                    ),
                    Text("Celsius"),
                  ],
                ),
              ),
              PopupMenuItem<Widget>(
                onTap: () {
                  setToFahrenheit();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: Icon(
                        Icons.circle,
                        size: 20,
                        color: global_FahrenheitUnits.value == 1 ? Colors.green : Colors.white30,
                      ),
                    ),
                    Text("Fahrenheit"),
                  ],
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
}
