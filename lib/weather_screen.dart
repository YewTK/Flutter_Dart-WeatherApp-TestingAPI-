import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'weather_model.dart';
import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<WeatherData> futureWeather;
  final TextEditingController _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cityController.text = 'Berlin';
    futureWeather = _fetchWeatherByCity('Berlin');
  }

  Future<WeatherData> _fetchWeatherByCity(String city) async {
    try {
      final coords = await WeatherService.getCoordinatesFromCity(city);
      final lat = coords['latitude']!;
      final lon = coords['longitude']!;
      final data = await WeatherService.fetchWeather(lat, lon);
      return WeatherData.fromJson(data, cityName: city);
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  void _updateLocation() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        futureWeather = _fetchWeatherByCity(_cityController.text);
      });
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 130 * 3,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 130 * 3,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  IconData _getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0: // Clear sky
        return Icons.wb_sunny;
      case 1: // Mainly clear
      case 2: // Partly cloudy
        return Icons.wb_cloudy;
      case 3: // Overcast
        return Icons.cloud;
      case 45: // Fog
      case 48: // Depositing rime fog
        return Icons.visibility;
      case 51: // Drizzle light
      case 53: // Drizzle moderate
      case 55: // Drizzle dense
        return Icons.grain;
      case 61: // Rain slight
      case 63: // Rain moderate
      case 65: // Rain heavy
        return Icons.umbrella;
      case 71: // Snow slight
      case 73: // Snow moderate
      case 75: // Snow heavy
        return Icons.ac_unit;
      case 95: // Thunderstorm
      case 96: // Thunderstorm with slight hail
      case 99: // Thunderstorm with heavy hail
        return Icons.flash_on;
      default:
        return Icons.help_outline;
    }
  }

  String _getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Cloudy';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[900]!, Colors.blue[300]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 20),
                _buildLocationForm(),
                SizedBox(height: 30),
                FutureBuilder<WeatherData>(
                  future: futureWeather,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "${snapshot.error}",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final weather = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCurrentWeather(weather.current, weather.cityName),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: _scrollLeft,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Hourly Forecast (24 Hours)',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward, color: Colors.white),
                                onPressed: _scrollRight,
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          _buildHourlyList(weather.hourly),
                        ],
                      );
                    }
                    return Center(child: Text('No data', style: TextStyle(color: Colors.white70)));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Weather Forecast',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
          ),
        ),
        Icon(Icons.cloud, color: Colors.white, size: 32),
      ],
    );
  }

  Widget _buildLocationForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            TextFormField(
              controller: _cityController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'City Name',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Enter city name (e.g., Bangkok)',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.location_city, color: Colors.white70),
                suffixIcon: Icon(Icons.search, color: Colors.white70),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a city name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[900],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: Colors.black45,
              ),
              child: Text(
                'Get Weather',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(CurrentData current, String cityName) {
    final timeFormat = DateFormat('MMM d, y • HH:mm');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$cityName - ${_getWeatherDescription(current.weatherCode)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 1))],
                ),
              ),
              SizedBox(width: 10),
              Icon(_getWeatherIcon(current.weatherCode), color: Colors.white, size: 24),
            ],
          ),
          SizedBox(height: 15),
          Text(
            timeFormat.format(DateTime.parse(current.time)),
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${current.temperature.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Wind: ${current.windSpeed.toStringAsFixed(1)} km/h',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Icon(Icons.air, color: Colors.white70, size: 24),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyList(HourlyData hourly) {
    final timeFormat = DateFormat('HH:mm');
    return SizedBox(
      height: 220,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: hourly.time.length > 24 ? 24 : hourly.time.length, // จำกัดที่ 24 ชั่วโมง
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 130,
            margin: EdgeInsets.only(right: 15),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  timeFormat.format(DateTime.parse(hourly.time[index])),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getWeatherIcon(hourly.weatherCodes[index]), color: Colors.white70, size: 18),
                    SizedBox(width: 4),
                    Text(
                      _getWeatherDescription(hourly.weatherCodes[index]),
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
                Text(
                  '${hourly.temperatures[index].toStringAsFixed(1)}°C',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Humidity: ${hourly.humidity[index]}%',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.air, color: Colors.white70, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '${hourly.windSpeeds[index].toStringAsFixed(1)} km/h',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}