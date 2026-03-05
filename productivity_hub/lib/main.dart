import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/note_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ProductivityHubApp());
}

class ProductivityHubApp extends StatelessWidget {
  const ProductivityHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final baseTheme = ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            appBarTheme: const AppBarTheme(centerTitle: false),
            cardTheme: CardThemeData(
              elevation: 1.5,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Productivity Hub',
            themeMode: settingsProvider.themeMode,
            theme: baseTheme.copyWith(
              scaffoldBackgroundColor: const Color(0xFFF6F7FB),
              inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
                fillColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(centerTitle: false),
              cardTheme: baseTheme.cardTheme,
              inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
                fillColor: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
