import 'package:flutter/material.dart';
import 'package:klimate/screens/loading_new_city.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/services/city.dart';
import 'package:klimate/services/helper_functions.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:klimate/utilities/weather_data.dart';
import '../services/constants.dart';

class LocationAppBar extends StatefulWidget implements PreferredSizeWidget {
  const LocationAppBar({super.key, required this.cityName, required this.originalWeather, required this.isLookUp});
  final String? cityName;
  final WeatherData originalWeather;
  final bool isLookUp;
  @override
  State<LocationAppBar> createState() => _LocationAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LocationAppBarState extends State<LocationAppBar> {
  TextEditingController textController = TextEditingController();
  String originalName = "";
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    originalName = widget.cityName!;
    textController.text = originalName;
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: MediaQuery.of(context).size.width / 1.2,
      leading: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Wrap(
          runAlignment: WrapAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 20,
              decoration: const BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: TypeAheadField<City>(
                focusNode: myFocusNode,
                controller: textController,
                suggestionsCallback: allCities,
                builder: (context, textController, focusNode) {
                  return TextField(
                    cursorColor: Colors.green,
                    textCapitalization: TextCapitalization.words,
                    controller: textController,
                    focusNode: focusNode,
                    onTapOutside: (downEvent) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        textController.text = originalName;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                      ),
                    ),
                    style: kCityLocationStyle,
                    maxLines: 1,
                  );
                },
                decorationBuilder: (context, child) => Material(
                  type: MaterialType.card,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(30),
                  child: child,
                ),
                onSelected: (City value) {
                  // push loading new city screen on top of home screen
                  myFocusNode.unfocus();

                  if (widget.isLookUp) {
                    // if we already looked up a city, replace that city with a new one
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                      return LoadingNewCity(
                        lat: value.lat,
                        long: value.long,
                        cityName: textController.text.trim(),
                        originalWeather: widget.originalWeather,
                        originalCity: widget.cityName,
                      );
                    }));
                  } else {
                    // if this is the first time we are looking up a city
                    String cityName = textController.text;
                    setState(() {
                      textController.text = originalName;
                    });

                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return LoadingNewCity(
                        lat: value.lat,
                        long: value.long,
                        cityName: cityName.trim(),
                        originalWeather: widget.originalWeather,
                        originalCity: widget.cityName,
                      );
                    }));
                  }
                },
                itemBuilder: (context, City location) => ListTile(
                  title: Text(location.city),
                  subtitle: location.state != null
                      ? Text(
                          '${location.state}, ${location.country}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          '\$${location.country}',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: PopupMenuButton<Widget>(
            child: const Icon(
              color: Colors.white,
              Icons.settings,
              size: 32,
            ),
            itemBuilder: (context) => <PopupMenuEntry<Widget>>[
              PopupMenuItem<Widget>(
                onTap: () {
                  setToCelsius();
                },
                child: popUpMenuTemperatures("Celsius", Colors.white30, Colors.green),
              ),
              PopupMenuItem<Widget>(
                onTap: () {
                  setToFahrenheit();
                },
                child: popUpMenuTemperatures("Fahrenheit", Colors.green, Colors.white30),
              ),
              PopupMenuItem<Widget>(
                onTap: () {
                  setTwentyFourHourFormat();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Transform.scale(
                      scale: .7,
                      alignment: Alignment.centerLeft,
                      child: Switch(
                        value: global_twentyFourHourFormat.value == 1 ? true : false,
                        onChanged: (value) {
                          setTwentyFourHourFormat();
                          Navigator.pop(context);
                        },
                        activeColor: Colors.green,
                      ),
                    ),
                    const Text("24 hour format"),
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

Row popUpMenuTemperatures(String units, Color isFahrenheit, Color isCelsius) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 2.0),
        child: Icon(
          Icons.circle,
          size: 20,
          color: global_FahrenheitUnits.value == 1 ? isFahrenheit : isCelsius,
        ),
      ),
      Text(units),
    ],
  );
}
