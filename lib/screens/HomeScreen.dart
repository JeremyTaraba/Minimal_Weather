import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/DraggableScrollable.dart';
import 'package:klimate/utilities/appBar.dart';
import 'package:klimate/utilities/helper_functions.dart';
import '../utilities/GradientText.dart';
import '../utilities/constants.dart';
import 'package:klimate/utilities/WeatherData.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.locationWeather});

  final locationWeather;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherData currentWeather = WeatherData();
  List bottomWeatherList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bottomWeatherList = createBottomWeatherList(context, currentWeather);

    return PopScope(
      canPop: false,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: currentWeather.background,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [
                Colors.black.withOpacity(.5),
                Colors.transparent,
              ], stops: [
                0.0,
                0.4,
              ])),
        ),
        SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: LocationAppBar(
              currentWeather: currentWeather,
            ),
            body: ValueListenableBuilder(
              valueListenable: global_FahrenheitUnits,
              builder: (BuildContext context, int value, Widget? child) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Column(
                      children: [
                        ExpandableNotifier(
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 50,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.rectangle,
                                    ),
                                  ),
                                ),
                                ScrollOnExpand(
                                  child: ExpandablePanel(
                                    theme: ExpandableThemeData(
                                      hasIcon: false,
                                      tapBodyToExpand: true,
                                      tapBodyToCollapse: true,
                                      iconPadding: EdgeInsets.zero,
                                      alignment: Alignment.topLeft,
                                    ),
                                    header: Text("expand test"),
                                    collapsed: Text(""),
                                    expanded: Text("hello bye"),
                                    builder: (_, collapsed, expanded) {
                                      return Padding(
                                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                        child: Expandable(
                                          collapsed: collapsed,
                                          expanded: expanded,
                                          theme: const ExpandableThemeData(crossFadePoint: 0),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: GradientText(
                                  "${convertUnitsIfNeedBe(currentWeather.temperature)}°",
                                  style: kTempStyle,
                                  gradient: kTempGradient,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Text(
                            currentWeather.description.toTitleCase(),
                            style: kDescriptionStyle,
                          ),
                        ),
                      ],
                    ),
                    DraggableScollableWeatherDetails(bottomWeatherList),
                  ],
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}
