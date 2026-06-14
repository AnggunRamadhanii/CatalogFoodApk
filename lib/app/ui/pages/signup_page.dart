import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../controllers/auth_controller.dart'; 
import '../widgets/auth_components.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    const Color kMaroon = Color(0xFF800000);
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: kWhiteBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: WaveClipper(),
              child: Stack(
                children: [
                  Container(
                    height: 240, 
                    decoration: BoxDecoration( 
                      gradient: LinearGradient(
                        colors: [
                          kMaroon.withAlpha(220), 
                          kMaroon.withAlpha(160), 
                        ], 
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(left: 24, bottom: 65), 
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Buat\nAkun Baru",
                        style: GoogleFonts.playfairDisplay( 
                          fontSize: 32, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white, 
                          height: 1.2
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Get.offAllNamed('/login'); 
                        }
                      },
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  AuthInput(hint: "Nama Lengkap", icon: Icons.person_outline, controller: controller.nameC),
                  AuthInput(hint: "Email", icon: Icons.email_outlined, controller: controller.emailC),
                  
                  Obx(() => AuthInput(
                    hint: "Password", 
                    icon: Icons.lock_outline, 
                    controller: controller.passwordC,
                    isPassword: true,
                    isObscure: controller.isObscure.value,
                    onEyeTap: controller.togglePass,
                  )),

                  const SizedBox(height: 40),

                  
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
                          : () => controller.signUp(),
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
                              "DAFTAR SEKARANG",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                    ),
                  )),

                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () => Get.offAllNamed('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: "Sudah punya akun? ",
                        style: GoogleFonts.poppins(color: Colors.grey), 
                        children: [
                          TextSpan(
                            text: "Masuk",
                            style: GoogleFonts.poppins(
                              color: kMaroon, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40); 

    var firstStart = Offset(size.width * 0.35, size.height - 65);
    var firstEnd = Offset(size.width * 0.65, size.height - 25);
    path.quadraticBezierTo(firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    var secondStart = Offset(size.width * 0.85, size.height);
    var secondEnd = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0); 
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}