import 'package:klimate/services/location.dart';
import 'package:klimate/services/networking.dart';

import 'keys.dart';

Future<dynamic> getCurrentLocationWeather() async {
  Location currentLocation = Location();
  await currentLocation.getCurrentLocation();

  NetworkHelper networkHelper =
      NetworkHelper('$openWeatherMapURLCurrentWeather?lat=${currentLocation.latitude}&lon=${currentLocation.longitude}&appid=$apiKey&units=imperial');

  var weatherData = await networkHelper.getData();
  return weatherData;
}

Future<dynamic> getHourlyLocationWeather() async {
  Location currentLocation = Location();
  await currentLocation.getCurrentLocation();

  NetworkHelper networkHelper =
      NetworkHelper('$openWeatherMapURLHourly?lat=${currentLocation.latitude}&lon=${currentLocation.longitude}&exclude=minutely&appid=$apiKey');

  var weatherData = await networkHelper.getData();
  return weatherData;
}

Future<dynamic> getCurrentLocationWeatherWithLatLon(num lat, num long) async {
  NetworkHelper networkHelper = NetworkHelper('$openWeatherMapURLCurrentWeather?lat=$lat&lon=$long&appid=$apiKey&units=imperial');

  var weatherData = await networkHelper.getData();
  return weatherData;
}

Future<dynamic> getHourlyLocationWeatherWithLatLon(num lat, num long) async {
  NetworkHelper networkHelper = NetworkHelper('$openWeatherMapURLHourly?lat=$lat&lon=$long&exclude=minutely&appid=$apiKey');

  var weatherData = await networkHelper.getData();
  return weatherData;
}
