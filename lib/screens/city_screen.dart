import 'package:flutter/material.dart';
import 'package:klimate/utilities/constants.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({Key? key}) : super(key: key);

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String cityName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('images/Search.jpg'),
          fit: BoxFit.cover,
        )),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                    alignment: Alignment.topLeft,
                    iconColor: MaterialStateColor.resolveWith(
                        (states) => Colors.white)),
                child: const Icon(
                  Icons.arrow_back,
                  size: 50,
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: Colors.black),
                  decoration: kTextFieldDecoration,
                  onSubmitted: (value) {
                    Navigator.pop(context, value.trim());
                  },
                  onChanged: (value) {
                    cityName = value;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, cityName.trim());
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green,
                  ),
                  child: Text(
                    "Search",
                    style: kWeatherTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
