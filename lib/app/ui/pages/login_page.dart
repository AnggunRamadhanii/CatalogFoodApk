import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; 
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
    const Color kMaroon = Color(0xFF800000); 
    const Color kWhiteBg = Colors.white; 

    return Scaffold(
      backgroundColor: kWhiteBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: LoginWaveClipper(),
              child: SizedBox(
                height: 320, 
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _bgImages.isEmpty
                          ? Container(color: kMaroon) 
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 1500),
                              child: Image.network(
                                _bgImages[_currentIndex],
                                key: ValueKey<String>(_bgImages[_currentIndex]),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Container(color: kMaroon),
                              ),
                            ),
                    ),

                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kMaroon.withAlpha(220), 
                              kMaroon.withAlpha(160), 
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
                          Image.asset(
                            'assets/logo.png', 
                            width: 300, 
                            height: 300,
                            fit: BoxFit.contain, 
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.storefront_outlined, size: 75, color: Colors.white);
                            },
                          ),
                          const SizedBox(height: 16),
                        ], 
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Masuk ke Akun Anda", 
                    style: GoogleFonts.poppins(   
                      color: kMaroon,
                      fontSize: 15,                      
                      fontWeight: FontWeight.w600,        
                      letterSpacing: 0.3,                 
                    ),
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
                        style: GoogleFonts.poppins(color: kMaroon, fontWeight: FontWeight.w500)
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMaroon, 
                        foregroundColor: Colors.white, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), 
                        ),
                        elevation: 2,
                      ),
                      onPressed: controller.isLoading.value 
                          ? null 
                          : () => controller.login(),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "MASUK",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                    ),
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
                          style: GoogleFonts.poppins(color: kMaroon, fontWeight: FontWeight.bold)
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

class LoginWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 45); 

    var firstStart = Offset(size.width * 0.35, size.height - 75);
    var firstEnd = Offset(size.width * 0.65, size.height - 30);
    path.quadraticBezierTo(firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    var secondStart = Offset(size.width * 0.85, size.height - 5);
    var secondEnd = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0); 
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}