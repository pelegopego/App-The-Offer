import 'package:shared_preferences/shared_preferences.dart';
import 'package:theoffer/utils/constants.dart';

Future<Map<String, String>> getHeaders() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  Map<String, String> headers = {
       'authorization': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.ImFkbWluMiI.3DqZsoGxoap0JDAedHjDiKy9LUm3vIq1eSjOzaaJcVE'
  };
  return headers;
}
