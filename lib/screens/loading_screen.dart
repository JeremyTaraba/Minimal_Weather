import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:klimate/screens/HomeScreen.dart';
import 'location_screen.dart';
import 'package:klimate/services/weather.dart';
import 'package:permission_handler/permission_handler.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    checkIfLocationOn();
  }

  Future<bool> checkIfLocationOn() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      //permission is enabled
      print("Permission enabled");
      var status = await Permission.location.status;
      if (status.isGranted) {
        //location permission is granted
        print("Permission granted");
        getLocationData();
      } else {
        //location permission is not granted
        print("Permission not granted");
        Map<Permission, PermissionStatus> status = await [
          Permission.location,
        ].request();
        getLocationData();
      }
    } else {
      Map<Permission, PermissionStatus> status = await [
        Permission.location,
      ].request();
      //permission is not enabled
      print("Permission not enabled");
    }
    if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    }
    return true;
  }

  void getLocationData() async {
    var weatherData = await getLocationWeather();
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return LocationScreen(
    //     locationWeather: weatherData,
    //   );
    // }));
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HomeScreen(
        locationWeather: weatherData,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SpinKitSpinningLines(
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }
}
