class WeatherData {
  final double latitude;
  final double longitude;
  final String cityName;
  final CurrentData current;
  final HourlyData hourly;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.current,
    required this.hourly,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, {required String cityName}) {
    return WeatherData(
      latitude: json['latitude'],
      longitude: json['longitude'],
      cityName: cityName,
      current: CurrentData.fromJson(json['current']),
      hourly: HourlyData.fromJson(json['hourly']),
    );
  }
}

class CurrentData {
  final String time;
  final double temperature;
  final double windSpeed;
  final int weatherCode; // เพิ่ม weatherCode

  CurrentData({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
  });

  factory CurrentData.fromJson(Map<String, dynamic> json) {
    return CurrentData(
      time: json['time'],
      temperature: json['temperature_2m'],
      windSpeed: json['wind_speed_10m'],
      weatherCode: json['weather_code'],
    );
  }
}

class HourlyData {
  final List<String> time;
  final List<double> temperatures;
  final List<int> humidity;
  final List<double> windSpeeds;
  final List<int> weatherCodes; // เพิ่ม weatherCodes

  HourlyData({
    required this.time,
    required this.temperatures,
    required this.humidity,
    required this.windSpeeds,
    required this.weatherCodes,
  });

  factory HourlyData.fromJson(Map<String, dynamic> json) {
    return HourlyData(
      time: List<String>.from(json['time']),
      temperatures: List<double>.from(json['temperature_2m']),
      humidity: List<int>.from(json['relative_humidity_2m']),
      windSpeeds: List<double>.from(json['wind_speed_10m']),
      weatherCodes: List<int>.from(json['weather_code']),
    );
  }
}