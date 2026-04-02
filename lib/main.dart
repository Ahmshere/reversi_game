import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';
import 'screens/game_stats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем сохранённую статистику
  await StatsRepository().load();

  // Инициализация Google Mobile Ads
  await MobileAds.instance.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ReversiApp());
}

class ReversiApp extends StatelessWidget {
  const ReversiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reversi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
