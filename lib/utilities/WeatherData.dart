import '../services/weather.dart';

class WeatherData {
  late WeatherModel weather;
  int temperature = 0;
  int condition = 0;
  String cityName = "";
  String description = "";
  late DateTime time;
  int timeHour = 0;
  String enteredLocation = "";
  int sunsetHour = 0;
  int sunriseHour = 1;
  int sunsetMinute = 0;
  int sunriseMinute = 0;
  int timeMinute = 0;
  late DateTime sunrise;
  late DateTime sunset;
  int highTemp = 0;
  int lowTemp = 0;

  void updateUI(dynamic weatherData) {
    if (weatherData == null) {
      temperature = 0;
      cityName = "";
      description = "Oops! Could not locate weather for '$enteredLocation'";
      time = DateTime.now();
      weather = WeatherModel(condition: 1000, hour: 0, sunset: 0, sunrise: 1);

      return;
    }
    temperature = weatherData['main']['temp'].toInt();
    highTemp = weatherData['main']['temp_max'].toInt();
    lowTemp = weatherData['main']['temp_min'].toInt();
    condition = weatherData['weather'][0]['id'];
    cityName = weatherData['name'];
    description = weatherData["weather"][0]["description"];
    int timezone = weatherData['timezone'];
    DateTime localTime = DateTime.now().add(Duration(seconds: timezone - DateTime.now().timeZoneOffset.inSeconds));
    timeHour = localTime.hour;
    var timeSunrise = DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunrise'] * 1000);
    var timeSunset = DateTime.fromMillisecondsSinceEpoch(weatherData['sys']['sunset'] * 1000);
    sunrise = timeSunrise.add(Duration(seconds: timezone - timeSunrise.timeZoneOffset.inSeconds));
    sunriseHour = sunrise.hour;
    sunriseMinute = sunrise.minute;
    sunset = timeSunset.add(Duration(seconds: timezone - timeSunrise.timeZoneOffset.inSeconds));
    sunsetHour = sunset.hour;
    sunsetMinute = sunset.minute;
    timeMinute = localTime.minute;
    weather = WeatherModel(condition: condition, hour: timeHour, sunrise: sunriseHour, sunset: sunsetHour);
  }
}
