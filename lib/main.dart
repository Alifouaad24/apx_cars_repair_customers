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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const LICENSE_KEY =
      "Y6eHbf/P6GM8PIN3GpcjJ34ILGI1j4" +
      "cfz/QTbkht9TjRQEvR/Nil3fHiqkGQ" +
      "luxPf8/ie0+jvId+QkpLqitw6DuX+r" +
      "jXHYjQC3cULH/AaBBVr/HidHRK1Xj5" +
      "Fnoyv/IiOJkhCTlGiYIZbyJZAQBxfi" +
      "XNosqE2ktjRJbz797X7RAWySltHlQt" +
      "Drz5iAUA8oNQKzNLUKr1wkReBh8ZYo" +
      "fFzech8f1KofvjjyoRbW3JiKVo+9YY" +
      "gr02DOKoyYp9TFi/EyrQGx0vFq3KjS" +
      "pmhzRvW4aLzAnHwd0gz9NKwR4p1o3G" +
      "qWWlgXmzA3j4Ja6wQ8HEo0p4ilq3Ar" +
      "e2crjZnTQrvA==\nU2NhbmJvdFNESw" +
      "pjb20uZXhhbXBsZS5hcHhfY2Fyc19y" +
      "ZXBhaXIKMTc4NzYxNTk5OQo4Mzg4Nj" +
      "A3CjE5\n";

  final config = SdkConfiguration(
    licenseKey: LICENSE_KEY,
    loggingEnabled: false,
  );

  await ScanbotSdk.initialize(config);

  final prefs = await SharedPreferences.getInstance();

  Get.put<SharedPreferences>(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
