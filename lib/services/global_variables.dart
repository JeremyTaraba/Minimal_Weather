import 'package:flutter/cupertino.dart';

late var global_CurrentWeatherData;
late var global_HourlyWeatherData;
String global_TempUnits = "Fahrenheit";
var global_FahrenheitUnits = ValueNotifier(1);
late var global_ForecastWeatherData;
bool global_gotWeatherSuccessfully = true;
String global_errorMessage = "";
String? global_userID = "";
