import 'package:flutter/cupertino.dart';

//String global_TempUnits = "Fahrenheit";
var global_twentyFourHourFormat = ValueNotifier(0);
var global_FahrenheitUnits = ValueNotifier(1);
bool global_gotWeatherSuccessfully = true;
String global_errorMessage = "";
String? global_userID = "";
String global_apiKey =
    "https://api.open-meteo.com/v1/forecast?latitude=33.8703&longitude=-117.9253&hourly=temperature_2m,precipitation_probability,weather_code,uv_index,relative_humidity_30hPa,windspeed_30hPa&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset&wind_speed_unit=ms&timeformat=unixtime&timezone=America%2FLos_Angeles";
