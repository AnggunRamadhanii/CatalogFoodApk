import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/pages/admin_dashboard_page.dart'; 

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  
  var isLoading = false.obs;
  var isObscure = true.obs;

  void togglePass() => isObscure.value = !isObscure.value;

  
  Future<void> signUp() async {
    if (nameC.text.isEmpty || emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar(
        "Peringatan", 
        "Semua kolom pendaftaran wajib diisi!",
        backgroundColor: Colors.amber,
        colorText: Colors.black
      );
      return;
    }

    try {
      isLoading.value = true;
      
      
      final AuthResponse res = await _supabase.auth.signUp(
        email: emailC.text.trim(),
        password: passwordC.text.trim(),
        data: {'full_name': nameC.text.trim()},
      );

      final user = res.user;

      
      if (user != null) {
        await _supabase.from('users').insert({
          'id': user.id,              
          'email': user.email,         
          'username': nameC.text.trim(),      
          'password': passwordC.text.trim(),  
        });

        
        Get.snackbar(
          "Sukses", 
          "Akun berhasil dibuat! Silakan login.",
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        
        nameC.clear();
        emailC.clear();
        passwordC.clear();
        
        
        Get.offAllNamed('/login'); 
      }
      
    } catch (e) {
      Get.snackbar(
        "Pendaftaran Gagal", 
        e.toString(),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar("Peringatan", "Email dan Password wajib diisi!");
      return;
    }

    try {
      isLoading.value = true;

      
      final res = await _supabase.auth.signInWithPassword(
        email: emailC.text.trim(),
        password: passwordC.text.trim(),
      );

      
      String inputEmail = emailC.text.trim().toLowerCase();

      if (res.user != null) {
        
        if (inputEmail == "admin@kantin.com") {
          
          emailC.clear();
          passwordC.clear();
          
          
          Get.offAll(() => const AdminDashboardPage());
          
          Get.snackbar(
            "Halo Admin", 
            "Berhasil masuk ke Dashboard Admin!",
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
          );

        } else {
          
          
          emailC.clear();
          passwordC.clear();
          Get.offAllNamed('/home');
          
          Get.snackbar(
            "Login Berhasil", 
            "Selamat Berbelanja!",
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
          );
          
        }
      }
    } catch (e) {
      Get.snackbar(
        "Login Gagal", 
        e.toString(),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }
}