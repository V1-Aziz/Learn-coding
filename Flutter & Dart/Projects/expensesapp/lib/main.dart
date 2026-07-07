import 'package:expensesapp/Widgets/expenses.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

var kColorsScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 221, 0, 255),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Color.fromARGB(255, 5, 99, 125),
);

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
  //   fn,
  // ) 
    runApp(
      MaterialApp(
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: kDarkColorScheme,
          cardTheme: CardTheme().copyWith(
            color: kDarkColorScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkColorScheme.primaryContainer,
              foregroundColor: kDarkColorScheme.onPrimaryContainer,
            ),
          ),
        ),
        theme: ThemeData(
          colorScheme: kColorsScheme,
          appBarTheme: AppBarTheme().copyWith(
            backgroundColor: kColorsScheme.onPrimaryContainer,
            foregroundColor: kColorsScheme.primaryContainer,
          ),
          cardTheme: CardTheme().copyWith(
            color: kColorsScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kColorsScheme.primaryContainer,
            ),
          ),
          textTheme: ThemeData().textTheme.copyWith(
            titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        themeMode: ThemeMode.system,
        home: Expenses(),
      ),
    );
  // });
}
