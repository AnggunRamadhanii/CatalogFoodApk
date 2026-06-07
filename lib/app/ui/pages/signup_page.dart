import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import '../../controllers/auth_controller.dart'; 
import '../widgets/auth_components.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: kWhiteBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration( 
                    gradient: LinearGradient(
                      colors: [kPinkGradient1, kPinkGradient2], // List warna ini yang bikin error kalau ada const
                    ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(80),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 24, bottom: 40),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Buat\nAkun Baru",
                      style: GoogleFonts.playfairDisplay( // FONT CLASSY
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
                    onPressed: () => Get.back(),
                  ),
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
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

                  Obx(() => PinkButton(
                    text: "DAFTAR SEKARANG",
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.signUp(),
                  )),

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: RichText(
                      text: TextSpan(
                        text: "Sudah punya akun? ",
                        style: GoogleFonts.poppins(color: Colors.grey), // FONT MODERN
                        children: [
                          TextSpan(
                            text: "Masuk",
                            style: GoogleFonts.poppins(
                              color: kPinkPrimary, 
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