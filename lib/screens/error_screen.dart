import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:klimate/screens/loading_screen.dart';
import 'package:klimate/services/global_variables.dart';
import 'package:klimate/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

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
      print('Could not launch $url');
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
      throw Exception(global_errorMessage);
    } catch (e) {
      print(e);
      FirebaseCrashlytics.instance.recordError("recordError: \n $e", StackTrace.current);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green[300],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.3),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Card(
                elevation: 20,
                color: Colors.white,
                child: Column(
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
                              print("email");
                              _launchURL();
                            },
                            child: const Text(
                              "FroggyWeatherInfo@gmail.com",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (!reportButtonClicked) {
                                    try {
                                      throw Exception(global_errorMessage);
                                    } catch (e) {
                                      print(e);
                                      FirebaseCrashlytics.instance.recordError("Manually pressed Send Error Button: \n $e", StackTrace.current);
                                    }

                                    setState(() {
                                      reportButtonClicked = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                },
                                child: const Text(
                                  "\n Send Error Report",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return const LoadingScreen();
                                  }));
                                },
                                child: const Text(
                                  "\n Restart App",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
