import 'package:catalogfood/app/controllers/auth_controller.dart';
import 'package:catalogfood/app/controllers/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 

import 'app/ui/pages/splash_page.dart'; 
import 'app/ui/pages/login_page.dart';
import 'app/ui/pages/signup_page.dart';
import 'app/ui/pages/home_page.dart'; 
import 'app/ui/pages/cart_page.dart';
import 'app/ui/pages/map_page.dart';
import 'app/ui/pages/notification_page.dart'; 

import 'app/services/theme_service.dart';
import 'app/themes/custom_themes.dart'; 

import 'app/services/firebase_messaging_handler.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBJm45zJW4ydWYPJJwJv5IFFRXNBE4yK4k',
        appId: '1:1043041897786:android:ee28113dbb39d3cbb05403',
        messagingSenderId: '1043041897786',
        projectId: 'foodcatalog-bdeaf',
        storageBucket: 'foodcatalog-bdeaf.firebasestorage.app',
      ),
    );
    
    try {
        await FirebaseMessagingHandler().initPushNotification();
    } catch (e) {
        print("$e");
    }
    
  } catch (e) {
    print("$e");
  }

  await Get.putAsync(() async => await SharedPreferences.getInstance());
  
  try {
    await dotenv.load(fileName: ".env"); 
  } catch (e) {
    print("$e");
  }
  Get.lazyPut(() => ProductController(), fenix: true);
  Get.lazyPut(() => AuthController(), fenix: true);
  await Supabase.initialize(
    url: 'https://dbcyjlaakegpbidqiuox.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRiY3lqbGFha2VncGJpZHFpdW94Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExNzY5NjAsImV4cCI6MjA5Njc1Mjk2MH0.kwwUp61VJXbGHob1n0eCJuHkBD-0zRnhmRUafnuusaM', 
  );

  final service = ThemeService();
  await service.init();
  Get.put<ThemeService>(service);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();

    return GetMaterialApp(
      title: 'Kantin App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', 
      getPages: [
        GetPage(name: '/', page: () => const SplashPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/cart', page: () => CartPage()),
        GetPage(name: '/map', page: () => MapPage()), 
        GetPage(name: '/promo', page: () => const NotificationPage()),
      ],
      theme: CustomThemes.light, 
      darkTheme: CustomThemes.dark, 
      themeMode: themeService.theme, 
    );
  }
}