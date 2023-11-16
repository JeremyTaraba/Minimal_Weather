import 'dart:io';

import 'package:path_provider/path_provider.dart';

String getLocalTime(int hour, int minutes) {
  String time = "";

  if (hour > 12) {
    hour -= 12;
  }

  if (minutes < 10) {
    time = "$hour:0$minutes";
  } else {
    time = "$hour:$minutes";
  }

  return time;
}

String getAMPM(int hour) {
  String time = "";
  if (hour > 12) {
    time = "PM";
  } else {
    time = "AM";
  }

  return time;
}

String getTimeWithAMPM(int hour, int minutes) {
  return getLocalTime(hour, minutes) + " " + getAMPM(hour);
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

// finds the correct local path to create a local file
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

// creates a reference to the file location using _localPath
Future<File> get localFile async {
  final path = await _localPath;
  return File('$path/counter.txt');
}
