import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import '../../controllers/auth_controller.dart'; 
import '../widgets/auth_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController controller = Get.put(AuthController());
  
  int _currentIndex = 0;
  Timer? _timer;
  final List<String> _bgImages = []; 

  @override
  void initState() {
    super.initState();
    _fetchBackgroundImages(); 
  }

  Future<void> _fetchBackgroundImages() async {
    final connect = GetConnect();
    try {
      for (int i = 0; i < 5; i++) {
        final response = await connect.get('https://www.themealdb.com/api/json/v1/1/random.php');
        if (response.statusCode == 200 && response.body['meals'] != null) {
          final imageUrl = response.body['meals'][0]['strMealThumb'];
          if (imageUrl != null) {
            setState(() {
              _bgImages.add(imageUrl);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal load gambar login: $e");
    } finally {
      if (_bgImages.isEmpty) {
        _bgImages.addAll([
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80',
        ]);
        setState(() {});
      }
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (_bgImages.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _bgImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                      ),
                      child: _bgImages.isEmpty
                          ? Container(color: kPinkGradient1) 
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 1500),
                              child: Image.network(
                                _bgImages[_currentIndex],
                                key: ValueKey<String>(_bgImages[_currentIndex]),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) => Container(color: kPinkGradient1),
                              ),
                            ),
                    ),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(60),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            kPinkGradient1.withOpacity(0.85), 
                            kPinkGradient2.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                          ),
                          child: const Icon(Icons.storefront_outlined, size: 80, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Kantin App",
                          style: GoogleFonts.playfairDisplay( // FONT CLASSY
                            fontSize: 32, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white, 
                            letterSpacing: 1.2,
                            shadows: [const Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))]
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Silakan Masuk", 
                    style: GoogleFonts.playfairDisplay( 
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: kTextDark
                    )
                  ),
                  Text(
                    "Lanjutkan untuk memesan makanan lezat.", 
                    style: GoogleFonts.poppins( 
                      color: Colors.grey,
                      fontSize: 14,
                    )
                  ),
                  
                  const SizedBox(height: 30),

                  AuthInput(hint: "Email", icon: Icons.email_outlined, controller: controller.emailC),
                  
                  Obx(() => AuthInput(
                    hint: "Password", 
                    icon: Icons.lock_outline, 
                    controller: controller.passwordC,
                    isPassword: true,
                    isObscure: controller.isObscure.value,
                    onEyeTap: controller.togglePass,
                  )),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Lupa Password?", 
                        style: GoogleFonts.poppins(color: kPinkPrimary, fontWeight: FontWeight.w500)
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Obx(() => PinkButton(
                    text: "MASUK",
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.login(),



                    
                  )),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Belum punya akun? ", style: GoogleFonts.poppins(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Get.toNamed('/signup'),
                        child: Text(
                          "Daftar", 
                          style: GoogleFonts.poppins(color: kPinkPrimary, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}