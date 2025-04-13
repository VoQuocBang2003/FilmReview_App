import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:review_film_app/ui/providers/movie_provider.dart';
import 'package:review_film_app/ui/providers/category_provider.dart';
import 'package:review_film_app/ui/providers/user_provider.dart';
import 'package:review_film_app/ui/providers/wishlist_provider.dart';
import 'package:review_film_app/ui/screens/login_screen.dart';
import 'package:review_film_app/ui/services/database_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // Ensure Flutter is initialized - Đảm bảo Flutter đã được khởi tạo trước khi chạy bất kỳ logic nào.
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo cơ sở dữ liệu SQLite trước khi chạy ứng dụng để tránh lỗi truy cập dữ liệu.
  try {
    print('Starting app initialization...');

    // Initialize database factory first
    await DatabaseService.initializeDatabaseFactory();

    // Pre-initialize the database to catch any issues early
    print('Pre-initializing database...');
    final dbService = DatabaseService();

    try {
      await dbService.database;

      // Check if database is accessible (db truy cập được?). Nếu bị lỗi, nó sẽ reset database để sửa lỗi.
      final isAccessible = await dbService.isDatabaseAccessible();
      if (isAccessible) {
        print('Database pre-initialization successful');
      } else {
        print('WARNING: Database is not accessible, attempting to reset...');
        await dbService.resetDatabase();
        final isAccessibleAfterReset = await dbService.isDatabaseAccessible();
        if (isAccessibleAfterReset) {
          print('Database reset successful');
        } else {
          print('ERROR: Database is still not accessible after reset');
        }
      }
    } catch (dbError) {
      print('Error with database: $dbError');
      print('Attempting to reset database...');
      try {
        await dbService.resetDatabase();
        print('Database reset completed');
      } catch (resetError) {
        print('Error resetting database: $resetError');
      }
    }

    // Run the app
    print('Starting app...');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');
    // Still try to run the app even if there's an error
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Cung cấp dữ liệu toàn cục (Provider pattern) cho các màn hình khác trong ứng dụng.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title: 'Rạp Phim Việt',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
        locale: const Locale('vi', 'VN'),
        theme: ThemeData(
          primaryColor: const Color(0xFF1E3A8A), // Màu xanh đậm
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            primary: const Color(0xFF1E3A8A),
            secondary: const Color(0xFFE11D48), // Màu đỏ cho các nút nhấn
            background: Colors.white,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: const Color(0xFF1F2937),
            onSurface: const Color(0xFF1F2937),
          ),
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: const TextStyle(color: Color(0xFF6B7280)),
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E3A8A),
              side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            displaySmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            headlineMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            titleLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
            bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          ),
          dividerTheme: const DividerThemeData(
            color: Color(0xFFE5E7EB),
            thickness: 1,
            space: 24,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFEEF2FF),
            disabledColor: Colors.grey.shade200,
            selectedColor: const Color(0xFF1E3A8A),
            secondarySelectedColor: const Color(0xFF1E3A8A),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            labelStyle: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            secondaryLabelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide.none,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF1E3A8A),
            unselectedItemColor: Color(0xFF9CA3AF),
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
