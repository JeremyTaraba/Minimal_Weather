import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:klimate/services/global_variables.dart';

class NetworkHelper {
  NetworkHelper(this.url);

  final String url;

  Future getData() async {
    var convertUrl = Uri.parse(url);
    http.Response response = await http.get(convertUrl);

    if (response.statusCode == 200) {
      String data = response.body;
      global_errorMessage = "No Error";
      return jsonDecode(data);
    } else {
      print('Error getting response from url. Code: ${response.statusCode}');
      global_gotWeatherSuccessfully = false;
      global_errorMessage = "Error getting response from url. Code: ${response.statusCode}";
    }
  }
}
