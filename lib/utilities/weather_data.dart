import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:klimate/services/helper_functions.dart';

class WeatherData {
  late DateTime writeTime; // is not used anywhere
  num currentTemperature = 0;
  int currentCondition = 0;
  String cityName = ""; // name should come from geocoding
  String state = "";
  String description = "";
  late DateTime time;
  late DateTime sunrise;
  late DateTime sunset;
  double highTemp = 0;
  double lowTemp = 0;
  late AssetImage background;
  num humidity = 0;
  double windSpeed = 0;
  num uvIndex = 0;
  String currentIconNumber = "";
  String apiUsed = "";
  double long = 0.0;
  double lat = 0.0;
  List hourlyTemperatures = [];

  List daily = []; // not used by open meteo
  List forecastList = []; // not used by open meteo

  List hourlyCodes = []; // not used by openweather
  List hourlyPrecipitation = []; // not used by openweather
  List hourlyUvIndex = []; // not used by openweather
  List hourlyHumidity = []; // not used by openweather
  List hourlyWindSpeed = []; // not used by openweather
  List hourlyTime = []; // not used by openweather
  var encodedData = "";
  WeatherData() {
    //constructor
  }

  // is probably better to put all hourly data in a list

  Future<void> setWeatherDataFromOpenMeteo(var data) async {
    apiUsed = "openmeteo";
    writeTime = DateTime.now();
    encodedData = json.encode(data);

    // bunch of lists to hold the data
    hourlyTemperatures = data["hourly"]["temperature_2m"]; // 24 hour temperature info, hour by hour, 7 days
    hourlyCodes = data["hourly"]["weather_code"];
    hourlyPrecipitation = data["hourly"]["precipitation_probability"];
    hourlyUvIndex = data["hourly"]["uv_index"];
    hourlyHumidity = data["hourly"]["relative_humidity_1000hPa"];
    hourlyWindSpeed = data["hourly"]["windspeed_1000hPa"];
    hourlyTime = data["hourly"]["time"];
    int hourIndex = getHourlyTimeGivenTime(hourlyTime, DateTime.now());

    currentTemperature = hourlyTemperatures[hourIndex];
    currentCondition = hourlyCodes[hourIndex];
    description = getDescriptionFromCondition(currentCondition); // need to make new description based on condition
    int conditionToOpenWeather = getOpenWeatherConditionNumberFromCondition(currentCondition);
    int epochTime = data["utc_offset_seconds"]; // for the time offset
    time = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    sunrise = DateTime.fromMillisecondsSinceEpoch(data['daily']['sunrise'][0] * 1000);
    sunset = DateTime.fromMillisecondsSinceEpoch(data['daily']['sunset'][0] * 1000);
    highTemp = data['daily']['temperature_2m_max'][0].toDouble(); // could get rid of these and figure out using hourly temps
    lowTemp = data['daily']['temperature_2m_min'][0].toDouble(); // ^
    background = _getBackground(conditionToOpenWeather, time.hour, sunrise.hour, sunset.hour);
    humidity = hourlyHumidity[hourIndex];
    windSpeed = double.parse(hourlyWindSpeed[hourIndex].toString());
    uvIndex = hourlyUvIndex[hourIndex];
    currentIconNumber = getOpenWeatherIconFromCondition(currentCondition, sunset, time, sunrise, false, hourlyPrecipitation[hourIndex]);
    lat = data["latitude"].toDouble();
    long = data["longitude"].toDouble();
    state = await getStateFromLatAndLong(lat, long);
  }

  Future<void> setWeatherDataFromOpenWeather(var data) async {
    apiUsed = "openweather";
    writeTime = DateTime.now();
    encodedData = json.encode(data);
    currentTemperature = data["onecall"]["current"]["temp"];
    currentCondition = data["onecall"]["current"]["weather"][0]["id"].toInt();
    cityName = data["forecast"]["city"]["name"];
    description = data["onecall"]["current"]["weather"][0]["description"];
    int epochTime = data["onecall"]["current"]["dt"];
    time = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    sunrise = DateTime.fromMillisecondsSinceEpoch(data["onecall"]['daily'][0]['sunrise'] * 1000);
    sunset = DateTime.fromMillisecondsSinceEpoch(data["onecall"]['daily'][0]['sunset'] * 1000);
    highTemp = data["onecall"]['daily'][0]['temp']["max"].toDouble();
    lowTemp = data["onecall"]['daily'][0]['temp']["min"].toDouble();
    background = _getBackground(currentCondition, time.hour, sunrise.hour, sunset.hour);
    humidity = data["onecall"]["current"]["humidity"].toInt();
    windSpeed = double.parse(data["onecall"]["current"]["wind_speed"].toString());
    uvIndex = data["onecall"]["current"]["uvi"].toInt();
    currentIconNumber = data["onecall"]["current"]["weather"][0]["icon"];
    long = data["onecall"]["lon"].toDouble();
    lat = data["onecall"]["lat"].toDouble();
    hourlyTemperatures = data["onecall"]["hourly"]; // 48 hour info, hour by hour
    daily = data["onecall"]["daily"]; // 8 days weather overview, including today
    forecastList = data["forecast"]["list"]; // 5 day 3 hour forecast
    state = await getStateFromLatAndLong(lat, long);
    //timeZoneOffset = data["onecall"]["timezone_offset"];
  }

  AssetImage _getBackground(int condition, int hour, int sunrise, int sunset) {
    int length = 1;
    Random random = Random();
    bool day = false;

    //if daytime
    if ((hour > sunrise) && (hour <= sunset)) {
      day = true;
    }
    if (condition < 300) {
      // thunderstorm

      return const AssetImage("images/thunderstorm/1.jpg");
    } else if (condition < 400) {
      // drizzle

      length = random.nextInt(6) + 1;
      return AssetImage("images/rain/$length.jpg");
    } else if (condition < 600) {
      // rain

      length = random.nextInt(6) + 1;
      return AssetImage("images/rain/$length.jpg");
    } else if (condition < 700) {
      //snow
      if (condition == 611 || condition == 612 || condition == 613) {
        // sleet/hail

        length = random.nextInt(2) + 1;
        return AssetImage("images/hail/$length.jpg");
      } else {
        length = random.nextInt(4) + 1;
        return AssetImage("images/snow/$length.jpg");
      }
    } else if (condition < 800) {
      // atmosphere (fog, mist, smoke, haze)

      return const AssetImage("images/atmosphere/1.jpg");
    } else if (condition == 800 || condition == 801) {
      // clear and mostly clear
      if (day) {
        length = random.nextInt(7) + 1;
        return AssetImage("images/clear/day/$length.jpg");
      } else {
        if (condition == 801) {
          length = random.nextInt(3) + 1;
          return AssetImage("images/mostlyClear/night/$length.jpg");
        } else {
          length = random.nextInt(5) + 1;
          return AssetImage("images/clear/night/$length.jpg");
        }
      }
    } else if (condition == 802) {
      //partly cloudy
      if (day) {
        length = random.nextInt(5) + 1;
        return AssetImage("images/partlyCloudy/day/$length.jpg");
      } else {
        length = random.nextInt(3) + 1;
        return AssetImage("images/partlyCloudy/night/$length.jpg");
      }
    } else if (condition == 803) {
      // mostly cloudy
      if (day) {
        length = random.nextInt(3) + 1;
        return AssetImage("images/mostlyCloudy/day/$length.jpg");
      } else {
        length = random.nextInt(3) + 1;
        return AssetImage("images/mostlyCloudy/night/$length.jpg");
      }
    } else if (condition == 804) {
      //cloudy
      if (day) {
        length = random.nextInt(3) + 1;
        return AssetImage("images/cloudy/day/$length.jpg");
      } else {
        length = random.nextInt(3) + 1;
        return AssetImage("images/mostlyCloudy/night/$length.jpg");
      }
    } else {
      return const AssetImage("images/Error.jpg");
    }
  }

  List<String> toStringList() {
    List<String> dataInStringFormat = [];
    dataInStringFormat.add(encodedData);
    dataInStringFormat.add(apiUsed);
    return dataInStringFormat;
  }

  void convertDataFromStringList(List<String> data) {
    apiUsed = data[1];
    if (apiUsed == "openweather") {
      setWeatherDataFromOpenWeather(json.decode(data[0]));
    } else {
      setWeatherDataFromOpenMeteo(json.decode(data[0]));
    }
  }
}
