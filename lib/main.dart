import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/theme_controller.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AutonomousBusinessAiApp());
}

class AutonomousBusinessAiApp extends StatelessWidget {
  const AutonomousBusinessAiApp({super.key});

  // User's Theme Palette: #9988A1 (Soft Mauve)
  static const Color _paletteSlate = Color(0xFF9988A1);
  static const Color _paletteSkyBlue = Color(0xFFC7BED0);

  static const Color _lightPrimary = Color(0xFF9988A1);
  static const Color _lightSecondary = Color(0xFFC7BED0);
  static const Color _lightTertiary = Color(0xFFDED8E4);
  static const Color _lightBackground = Color(0xFFF8F6FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF281E30);

  static const Color _darkPrimary = Color(0xFFC7BED0);
  static const Color _darkSecondary = Color(0xFF9988A1);
  static const Color _darkTertiary = Color(0xFFDED8E4);
  static const Color _darkBackground = Color(0xFF1B1621);
  static const Color _darkSurface = Color(0xFF26202D);
  static const Color _darkSurfaceContainer = Color(0xFF332B3D);
  static const Color _darkText = Color(0xFFF3EEF7);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder:
          (BuildContext context, ThemeMode currentThemeMode, Widget? child) {
            return MaterialApp(
              title: 'Autonomous Business AI',
              debugShowCheckedModeBanner: false,

              theme: _buildLightTheme(),

              darkTheme: _buildDarkTheme(),

              themeMode: currentThemeMode,

              themeAnimationDuration: const Duration(milliseconds: 350),

              themeAnimationCurve: Curves.easeInOut,

              home: const SplashScreen(),
            );
          },
    );
  }

  ThemeData _buildLightTheme() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
      primary: _lightPrimary,
      secondary: _lightSecondary,
      tertiary: _lightTertiary,
      surface: _lightSurface,
      error: const Color(0xFFE5484D),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      scaffoldBackgroundColor: _lightBackground,

      canvasColor: _lightBackground,

      cardColor: _lightSurface,

      dividerColor: const Color(0xFFE2E8F0),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: _lightText,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _lightText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: _lightText),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: _lightBackground,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _lightText, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(
          color: _lightText,
          fontWeight: FontWeight.w900,
        ),
        headlineLarge: TextStyle(
          color: _lightText,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          color: _lightText,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: _lightText,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF2E3E4E),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF53677A),
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF6B7E90),
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF8899A9),
          fontSize: 12,
          height: 1.4,
        ),
      ),

      iconTheme: const IconThemeData(color: _paletteSlate),

      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: _paletteSlate.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: _paletteSlate,
        textColor: _lightText,
        subtitleTextStyle: TextStyle(color: Color(0xFF6B7E90), fontSize: 13),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7FAFD),
        hintStyle: const TextStyle(color: Color(0xFF90A1B2), fontSize: 14),
        labelStyle: const TextStyle(color: _paletteSlate),
        prefixIconColor: _paletteSlate,
        suffixIconColor: _paletteSlate,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEBF0F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _lightPrimary, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5484D)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5484D), width: 1.7),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 54),
          foregroundColor: Colors.white,
          backgroundColor: _lightPrimary,
          disabledForegroundColor: Colors.white70,
          disabledBackgroundColor: const Color(0xFF9CB1C4),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          foregroundColor: Colors.white,
          backgroundColor: _lightPrimary,
          disabledForegroundColor: Colors.white70,
          disabledBackgroundColor: const Color(0xFF9CB1C4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 54),
          foregroundColor: _lightPrimary,
          side: const BorderSide(color: _paletteSkyBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return _lightPrimary;
          }

          return null;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }

          return const Color(0xFFF4F7FA);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return _lightPrimary;
          }

          return const Color(0xFFCBD8E3);
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _lightText,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _lightPrimary,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: _darkPrimary,
          brightness: Brightness.dark,
          primary: _darkPrimary,
          secondary: _darkSecondary,
          tertiary: _darkTertiary,
          surface: _darkSurface,
          error: const Color(0xFFFF6B6B),
        ).copyWith(
          onPrimary: const Color(0xFF131B24),
          onSecondary: Colors.white,
          onSurface: _darkText,
          surfaceContainerHighest: _darkSurfaceContainer,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      scaffoldBackgroundColor: _darkBackground,

      canvasColor: _darkBackground,

      cardColor: _darkSurface,

      dividerColor: const Color(0xFF27384A),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: _darkSurface,
        foregroundColor: _darkText,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _darkText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: _darkText),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: _darkBackground,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _darkText, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(color: _darkText, fontWeight: FontWeight.w900),
        headlineLarge: TextStyle(
          color: _darkText,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          color: _darkText,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: _darkText,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFD6E2EC),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFBACBD8),
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFA1B4C3),
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF8296A6),
          fontSize: 12,
          height: 1.4,
        ),
      ),

      iconTheme: const IconThemeData(color: _paletteSkyBlue),

      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),

      listTileTheme: const ListTileThemeData(
        tileColor: _darkSurface,
        iconColor: _paletteSkyBlue,
        textColor: _darkText,
        subtitleTextStyle: TextStyle(color: Color(0xFFA1B4C3), fontSize: 13),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceContainer,
        hintStyle: const TextStyle(color: Color(0xFF7A8E9F), fontSize: 14),
        labelStyle: const TextStyle(color: Color(0xFFBADDFF)),
        prefixIconColor: _darkPrimary,
        suffixIconColor: _darkPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2E3F52)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2E3F52)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF243242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _darkPrimary, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.7),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 54),
          foregroundColor: const Color(0xFF131B24),
          backgroundColor: _darkPrimary,
          disabledForegroundColor: Colors.white54,
          disabledBackgroundColor: const Color(0xFF384E62),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          foregroundColor: const Color(0xFF131B24),
          backgroundColor: _darkPrimary,
          disabledForegroundColor: Colors.white54,
          disabledBackgroundColor: const Color(0xFF384E62),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 54),
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _paletteSlate, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return _darkPrimary;
          }

          return null;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF131B24);
          }

          return const Color(0xFF90A1B2);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return _darkPrimary;
          }

          return const Color(0xFF2E3F52);
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF27384A),
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF243242),
        contentTextStyle: const TextStyle(
          color: _darkText,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _darkPrimary,
      ),
    );
  }
}
