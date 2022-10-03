import 'package:weather/exceptions/weather_exception.dart';
import 'package:weather/models/custom_error.dart';
import 'package:weather/models/direct_geocoding.dart';
import 'package:weather/services/weather_api.dart';

import '../models/weather.dart';

class WeatherRepository {
  final WeatherApi weatherApi;

  const WeatherRepository({
    required this.weatherApi,
  });

  Future<Weather> fetchWeather(String city) async {
    try {
      final DirectGeocoding directGeocoding =
          await weatherApi.getDirectGeocoding(city);

      final Weather tempWeather = await weatherApi.getWeather(directGeocoding);

      final Weather weather = tempWeather.copyWith(
          name: directGeocoding.name, country: directGeocoding.country);
      return weather;
    } on WeatherException catch (e) {
      throw CustomError(errorMessage: e.message);
    } catch (e) {
      CustomError(errorMessage: e.toString());
      rethrow;
    }
  }
}
