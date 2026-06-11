import 'package:apx_cars_repair/app/Bindings/AppBinding.dart';
import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primary = Color(0xFF0E7490);
const Color primaryDark = Color(0xFF0A5A6B);
Color accent = Color(0xFF06B6D4);
const Color amber = Color(0xFFF59E0B);
const Color surface = Color(0xFFF8FAFC);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  Get.put<SharedPreferences>(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: '',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          initialBinding: AppBinding(),
          initialRoute: AppRoutes.main,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
