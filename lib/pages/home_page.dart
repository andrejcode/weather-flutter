import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recase/recase.dart';
import 'package:weather/constants.dart';
import 'package:weather/cubits/temp_settings/temp_settings_cubit.dart';
import 'package:weather/cubits/weather/weather_cubit.dart';
import 'package:weather/pages/search_page.dart';
import 'package:weather/pages/settings_page.dart';
import 'package:weather/widgets/error_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _city;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
              onPressed: () async {
                _city = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const SearchPage();
                  }),
                );

                if (_city != null) {
                  context.read<WeatherCubit>().fetchWeather(_city!);
                }
              },
              icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const SettingsPage();
                  }),
                );
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: _showWeather(),
    );
  }

  String showTemperature(double temperature) {
    final tempUnit = context.watch<TempSettingsCubit>().state.tempUnit;

    if (tempUnit == TempUnit.fahrenheit) {
      return '${((temperature * 9 / 5) + 32).toStringAsFixed(2)}℉';
    }

    return '${temperature.toStringAsFixed(2)}℃';
  }

  Widget showIcon(String icon) {
    return FadeInImage.assetNetwork(
      placeholder: 'assets/images/loading.gif',
      image: 'http://$kIconHost/img/wn/$icon@4x.png',
      width: 96,
      height: 96,
    );
  }

  Widget formatText(String description) {
    final formattedString = description.titleCase;
    return Text(
      formattedString,
      style: const TextStyle(fontSize: 24.0),
      textAlign: TextAlign.center,
    );
  }

  Widget _showWeather() {
    return BlocConsumer<WeatherCubit, WeatherState>(listener: (context, state) {
      if (state.status == WeatherStatus.error) {
        errorDialog(context, state.error.errorMessage);
      }
    }, builder: (context, state) {
      if (state.status == WeatherStatus.initial) {
        return const Center(
          child: Text(
            'Select a city',
            style: TextStyle(fontSize: 20.0),
          ),
        );
      }

      if (state.status == WeatherStatus.error && state.weather.name == '') {
        return const Center(
          child: Text(
            'Select a city',
            style: TextStyle(fontSize: 20.0),
          ),
        );
      }

      if (state.status == WeatherStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 6,
          ),
          Text(
            state.weather.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                TimeOfDay.fromDateTime(state.weather.lastUpdated)
                    .format(context),
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(width: 10.0),
              Text(
                '(${state.weather.country})',
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
          const SizedBox(height: 60.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                showTemperature(state.weather.temp),
                style: const TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 20.0),
              Column(
                children: [
                  Text(
                    showTemperature(state.weather.tempMax),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    showTemperature(state.weather.tempMin),
                    style: const TextStyle(fontSize: 16.0),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 40.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Spacer(),
              showIcon(state.weather.icon),
              Expanded(flex: 3, child: formatText(state.weather.description)),
              const Spacer(),
            ],
          ),
        ],
      );
    });
  }
}
