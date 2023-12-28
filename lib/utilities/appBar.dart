import 'package:flutter/material.dart';
import 'package:klimate/screens/loading_new_city.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/City.dart';
import 'package:klimate/utilities/helper_functions.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
  TextEditingController textController = TextEditingController();
  String originalName = "";
  SuggestionsController<City> suggestionsController = SuggestionsController<City>();

  @override
  void initState() {
    super.initState();
    textController.text = widget.currentWeather.cityName;
    originalName = widget.currentWeather.cityName;
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
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: TypeAheadField<City>(
                suggestionsCallback: allCities,
                suggestionsController: suggestionsController,
                builder: (context, textController, focusNode) {
                  return TextField(
                    onTapOutside: (downEvent) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        textController.text = originalName;
                      });
                    },
                    // onSubmitted: (value) {
                    //   setState(() {
                    //     textController.text = value.toTitleCase().trim();
                    //     originalName = value.toTitleCase().trim();
                    //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    //       return loadingNewCity(cityName: textController.text);
                    //     }));
                    //   });
                    // },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                      ),
                    ),
                    controller: textController,
                    style: kCityLocationStyle,
                    maxLines: 1,
                  );
                },
                onSelected: (Object? value) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return loadingNewCity(cityName: value.toString());
                  }));
                },
                itemBuilder: (context, City) => ListTile(
                  title: Text(City.city),
                  subtitle: City.state != null
                      ? Text(
                          '${City.state}, ${City.country}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text('\$${City.country}'),
                ),
              ),
              // child: TextField(
              //   onTapOutside: (downEvent) {
              //     FocusManager.instance.primaryFocus?.unfocus();
              //     setState(() {
              //       cityName.text = originalName;
              //     });
              //   },
              //   onSubmitted: (value) {
              //     setState(() {
              //       cityName.text = value.toTitleCase().trim();
              //       originalName = value.toTitleCase().trim();
              //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              //         return loadingNewCity(cityName: cityName.text);
              //       }));
              //     });
              //   },
              //   decoration: InputDecoration(
              //     border: InputBorder.none,
              //     prefixIcon: Icon(
              //       Icons.location_on_outlined,
              //       color: Colors.white,
              //     ),
              //   ),
              //   controller: cityName,
              //   style: kCityLocationStyle,
              //   maxLines: 1,
              // ),
            ),
          ],
        ),
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
