import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: RankingChallengeApp()));
}

class RankingChallengeApp extends StatelessWidget {
  const RankingChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1位はどれだ？',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
        useMaterial3: true,
        fontFamily: 'Hiragino Sans',
      ),
      home: const HomeScreen(),
    );
  }
}
