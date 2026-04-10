import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LLMScraperApp());
}

class LLMScraperApp extends StatelessWidget {
  const LLMScraperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Web Data Extractor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF111111),      // Deep Black
          secondary: Color(0xFF757575),    // Medium Gray
          surface: Color(0xFFFFFFFF),      // Pure White
          error: Color(0xFFE51C23),        // Standard Red
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF111111),
        ),
        fontFamily: 'Segoe UI', // Use native Windows font heavily to avoid missing font blank text
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Impact', // Bold chunky sans for Nike-style headers
            fontSize: 72,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111111),
            letterSpacing: -1.5,
            height: 0.9,

          ),
          headlineLarge: TextStyle(
            fontFamily: 'Impact',
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111111),
            letterSpacing: -1.0,

          ),
          headlineMedium: TextStyle(
            fontFamily: 'Impact',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111111),
            letterSpacing: 0.5,

          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111111),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Color(0xFF111111),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5), // Light gray fill, like a simple text box
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0), // No rounded corners
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: const BorderSide(color: Color(0xFF111111), width: 2), // Solid black border when active
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF757575), 
            fontSize: 14, 
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF111111),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Pill shape for main action (Nike style)
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
