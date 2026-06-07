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
        print("Handler Notifikasi Error (Bisa diabaikan di Web/Windows): $e");
    }
    
  } catch (e) {
    print("Error Init Firebase (Bisa diabaikan jika belum setup): $e");
  }

  await Get.putAsync(() async => await SharedPreferences.getInstance());
  
  try {
    await dotenv.load(fileName: ".env"); 
  } catch (e) {
    print("Dotenv load error (ignored): $e");
  }

  await Supabase.initialize(
    url: 'https://tbphwtbqumrtekqcmvep.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRicGh3dGJxdW1ydGVrcWNtdmVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNDA1OTgsImV4cCI6MjA3OTkxNjU5OH0.wj8b6ojLnAm5rO7LHr0HkTM-zE2f4U_c4bVQukULhdU', 
  );

  await Get.putAsync<ThemeService>(() async {
    final service = ThemeService();
    await service.init(); 
    return service;
  });

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
      
      
      initialRoute: '/splash', 
      
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        
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