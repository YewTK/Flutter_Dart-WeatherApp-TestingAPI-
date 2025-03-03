import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  static Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,wind_speed_10m,weather_code&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  static Future<Map<String, double>> getCoordinatesFromCity(String city) async {
    final url = 'https://nominatim.openstreetmap.org/search?q=$city&format=json&limit=1';
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'YourAppName/1.0'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'latitude': double.parse(data[0]['lat']),
          'longitude': double.parse(data[0]['lon']),
        };
      } else {
        throw Exception('City not found');
      }
    } else {
      throw Exception('Failed to fetch coordinates');
    }
  }
}