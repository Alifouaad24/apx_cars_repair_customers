import 'dart:ui' as ui;
import 'package:apx_cars_repair/app/Bindings/AppBinding.dart';
import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scanbot_sdk/scanbot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primary = Color(0xFF0E7490);
const Color primaryDark = Color(0xFF0A5A6B);
Color accent = Color(0xFF06B6D4);
const Color amber = Color(0xFFF59E0B);
const Color surface = Color(0xFFF8FAFC);
String? scanbotInitError;
bool scanbotInitSuccess = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const LICENSE_KEY =
      "CemX21MdG5tx8aXM8Z6LgbQ/jYSUvG" +
      "6LtzuV2ujvZlbMKczuZyjWVaHrxRTZ" +
      "HFy0nKCMUsHpA/Deg92ipLdjpLb33w" +
      "XsOpw9Jz6wbYN5LaraffPYBAao9YP4" +
      "BbELuunjfWp8w3fRmqjFkhXtjArTrx" +
      "GTMEyqnpw27KCjiqDswzxtESgy/nJ+" +
      "X1eq6UUJky5oXN5nuthJveTY7vZO5G" +
      "1Lik7XMtS3ep2WzHmVU4V6btrx2R3J" +
      "HOzkCVzzyTOD+s471/bPrwd9FItIPc" +
      "8JdEbQznTLr9Qt3Kec84G4LyilO7HE" +
      "Le9dt2XWxJvfIF37Yi/gxujqFw38+j" +
      "dRiTeMmjjdzw==\nU2NhbmJvdFNESw" +
      "pjb20uYXB4LmFweENhcnNSZXBhaXIK" +
      "MTc4NzcwMjM5OQo4Mzg4NjA3CjE5";

  final config = SdkConfiguration(
    licenseKey: LICENSE_KEY,
    loggingEnabled: false,
  );

  try {
    await ScanbotSdk.initialize(config);
    scanbotInitSuccess = true;
  } catch (e) {
    scanbotInitError = e.toString();
  }

  final prefs = await SharedPreferences.getInstance();

  Get.put<SharedPreferences>(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scanbotInitSuccess) {
        Get.dialog(
          AlertDialog(
            title: const Text('Scanbot Init Failed'),
            content: SingleChildScrollView(
              child: SelectableText(scanbotInitError ?? 'Unknown error'),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('OK')),
            ],
          ),
          barrierDismissible: false,
        );
      }
    });
    return ScreenUtilInit(
      designSize: const ui.Size(360, 690),
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
