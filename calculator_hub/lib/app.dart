import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/calculator_provider.dart';
import 'screens/calculator_screen.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalculatorProvider(),
      child: Consumer<CalculatorProvider>(
        builder: (context, provider, _) {
          final darkScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6E56FF),
            brightness: Brightness.dark,
            primary: const Color(0xFF7B61FF),
            secondary: const Color(0xFF00C2FF),
            surface: const Color(0xFF11121A),
          );

          final lightScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6E56FF),
            brightness: Brightness.light,
            primary: const Color(0xFF6E56FF),
            secondary: const Color(0xFF00A6D6),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Calculator Hub',
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            darkTheme: _buildTheme(darkScheme),
            theme: _buildTheme(lightScheme),
            home: const CalculatorScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.brightness == Brightness.dark
          ? const Color(0xFF0A0B11)
          : const Color(0xFFF6F7FB),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }
}
