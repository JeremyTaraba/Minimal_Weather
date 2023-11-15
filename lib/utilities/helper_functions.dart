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
Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/counter.txt');
}

// writes data to the file
Future<File> writeWeatherData(int counter) async {
  final file = await _localFile;

  // Write the file
  return file.writeAsString('$counter');
}

// reads data from the file
Future<int> readWeatherData() async {
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return int.parse(contents);
  } catch (e) {
    // If encountering an error, return 0
    print(e);
    return 0;
  }
}
