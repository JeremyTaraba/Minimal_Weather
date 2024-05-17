import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:klimate/screens/loading_screen.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/services/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key, this.errorCode = 503});
  final int errorCode;

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  void _launchURL() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'FroggyWeatherInfo@gmail.com',
    );
    String url = params.toString();
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      if (kDebugMode) {
        print('Could not launch $url');
      }
    }
  }

  var reportButtonClicked = false;

  static const snackBar = SnackBar(
    content: Text('Report Sent'),
  );

  @override
  void initState() {
    super.initState();
    try {
      if (!kDebugMode) {
        throw Exception(global_errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      } else {
        FirebaseCrashlytics.instance.recordError("recordError: \n $e", StackTrace.current);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Error1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.15),
            ),
          ),
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 8, right: 8),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 14,
                    color: Colors.white,
                    child: _showCorrectErrorScreen(widget.errorCode),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showCorrectErrorScreen(int code) {
    switch (code) {
      case 503:
        return _errorFiveZeroThree();
      case 400:
        return _errorFourZeroZero();
      case 401:
        return _errorFourZeroOne();
      default:
        return Container(
          color: Colors.white,
          child: const Text(
            "An Unknown Error Has Occurred. Try restarting the app.",
            style: kErrorTextStyle,
          ),
        );
    }
  }

  Widget _errorFiveZeroThree() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                "Unable To Get Weather",
                style: kErrorTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 55,
                ),
              ),
              const Text(
                "Froggy Weather is experiencing more traffic than it can handle.  "
                "We are working on fixing it. \n \n"
                "If you have suggestions for making the app better send an email to:",
                style: kErrorTextStyle,
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () {
                  if (kDebugMode) {
                    print("email");
                  }
                  _launchURL();
                },
                child: Text(
                  "FroggyWeatherInfo@gmail.com",
                  style: kErrorScreenTextStyleBlue.copyWith(fontSize: 24),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (!reportButtonClicked) {
                          try {
                            if (!kDebugMode) {
                              throw Exception(global_errorMessage);
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print(e);
                            } else {
                              FirebaseCrashlytics.instance.recordError("Manually pressed Send Error Button: \n $e", StackTrace.current);
                            }
                          }

                          setState(() {
                            reportButtonClicked = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: const Text(
                        "\n Send Error Report",
                        style: kErrorScreenTextStyleBlue,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                          return const LoadingScreen();
                        }));
                      },
                      child: const Text(
                        "\n Restart App",
                        style: kErrorScreenTextStyleBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorFourZeroZero() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                "Could Not Find Location",
                style: kErrorTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.location_off,
                  color: Colors.orange,
                  size: 55,
                ),
              ),
              const Text(
                "Sorry, we can't seem to find your location. "
                "Try refreshing or enabling location permissions. \n \n",
                style: kErrorTextStyle,
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () {
                  if (kDebugMode) {
                    print("email");
                  }
                  openAppSettings();
                },
                child: Text(
                  "Enable Location Permissions",
                  style: kErrorScreenTextStyleBlue.copyWith(fontSize: 24),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (!reportButtonClicked) {
                          try {
                            if (!kDebugMode) {
                              throw Exception(global_errorMessage);
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print(e);
                            } else {
                              FirebaseCrashlytics.instance.recordError("Manually pressed Send Error Button: \n $e", StackTrace.current);
                            }
                          }

                          setState(() {
                            reportButtonClicked = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: const Text(
                        "\n Send Error Report",
                        style: kErrorScreenTextStyleBlue,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                          return const LoadingScreen();
                        }));
                      },
                      child: const Text(
                        "\n Restart App",
                        style: kErrorScreenTextStyleBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorFourZeroOne() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                "Authorization Error",
                style: kErrorTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.person_off,
                  color: Colors.red,
                  size: 55,
                ),
              ),
              const Text(
                "Sorry, temporarily locked. "
                "Send error report and try again later. \n \n",
                style: kErrorTextStyle,
                textAlign: TextAlign.center,
              ),
              const Text(
                "Asked to be unlocked by sending an email to:",
                style: kErrorTextStyle,
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () {
                  if (kDebugMode) {
                    print("email");
                  }
                  _launchURL();
                },
                child: Text(
                  "FroggyWeatherInfo@gmail.com",
                  style: kErrorScreenTextStyleBlue.copyWith(fontSize: 24),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (!reportButtonClicked) {
                          try {
                            if (!kDebugMode) {
                              throw Exception(global_errorMessage);
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print(e);
                            } else {
                              FirebaseCrashlytics.instance
                                  .recordError("Manually pressed Send Error Button: User: $global_userID \n $e", StackTrace.current);
                            }
                          }

                          setState(() {
                            reportButtonClicked = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: const Text(
                        "\n Send Error Report",
                        style: kErrorScreenTextStyleBlue,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                          return const LoadingScreen();
                        }));
                      },
                      child: const Text(
                        "\n Restart App",
                        style: kErrorScreenTextStyleBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
