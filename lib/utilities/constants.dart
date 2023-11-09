import 'package:flutter/material.dart';

const TextStyle kTempStyle = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.bold,
  fontFamily: 'Alice',
);

const TextStyle kWeatherTextStyle = TextStyle(
  fontSize: 50,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle kTemperatureNumberStyle = TextStyle(
  fontSize: 40,
  fontWeight: FontWeight.bold,
);

const TextStyle kWeatherTip = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.bold,
);

const TextStyle kLocalTimeStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  fontFamily: 'Alice',
);

const TextStyle kSunsetSunriseStyle = TextStyle(
  fontSize: 18,
  fontFamily: 'Alice',
);

const TextStyle kTempHighLowStyle = TextStyle(
  fontSize: 20,
  fontFamily: 'Alice',
);

const TextStyle kLocalTimeAMPMStyle = TextStyle(
  fontSize: 12,
  fontFamily: 'Alice',
);

const TextStyle kDescriptionStyle = TextStyle(
  fontSize: 22,
  fontFamily: 'Alice',
);

const TextStyle kCityLocationStyle = TextStyle(
  fontSize: 26,
  fontFamily: 'Alice',
);

const InputDecoration kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  icon: Icon(
    Icons.location_city,
    color: Colors.white,
    size: 50,
  ),
  hintText: "Search places",
  hintStyle: TextStyle(
    color: Colors.grey,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  ),
);

const Color kErrorDayColor = Color(0xFF77837B);
const Color kClearDayColor = Color(0xff28a3ce); // and mostly clear day
const Color kClearNightColor = Color(0xFF7644D9); // and mostly clear night;
const Color kPartlyCloudyDayColor = Color(0xFF529AC9); // and mostly cloudy day
const Color kPartlyCloudyNightColor = Color(0xFF807CD3); // and mostly cloudy night
const Color kCloudyColor = Color(0xFF7995B9);
const Color kRainColor = Color(0xFF1A78D5); // and heavy rain
const Color kRainstormColor = Color(0xFF933C74);
const Color kIceColor = Color(0xFF6C7A85);
const Color kSnowColor = Color(0xFF8C8B96);
const Color kAtmosphere = Color(0xFF9B8F8F);
