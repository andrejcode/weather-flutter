import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather/cubits/temp_settings/temp_settings_cubit.dart';
import 'package:weather/cubits/theme/theme_cubit.dart';
import 'package:weather/cubits/weather/weather_cubit.dart';
import 'package:weather/pages/home_page.dart';
import 'package:weather/repositories/weather_repository.dart';
import 'package:weather/services/weather_api.dart';
import 'package:http/http.dart' as http;

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) =>
          WeatherRepository(weatherApi: WeatherApi(httpClient: http.Client())),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WeatherCubit>(
            create: (context) => WeatherCubit(
              weatherRepository: context.read<WeatherRepository>(),
            ),
          ),
          BlocProvider<TempSettingsCubit>(
              create: (context) => TempSettingsCubit()),
          BlocProvider<ThemeCubit>(
              create: (context) =>
                  ThemeCubit(weatherCubit: context.read<WeatherCubit>()))
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Weather',
              debugShowCheckedModeBanner: false,
              theme:
                  context.watch<ThemeCubit>().state.appTheme == AppTheme.light
                      ? ThemeData.light()
                      : ThemeData.dark(),
              home: const HomePage(),
            );
          },
        ),
      ),
    );
  }
}
