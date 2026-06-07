import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  
  var isLoading = false.obs;
  var isObscure = true.obs;

  void togglePass() => isObscure.value = !isObscure.value;

  Future<void> signUp() async {
    try {
      isLoading.value = true;
      await _supabase.auth.signUp(
        email: emailC.text,
        password: passwordC.text,
        data: {'full_name': nameC.text},
      );
      Get.snackbar("Sukses", "Cek email Anda / Login");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      final res = await _supabase.auth.signInWithPassword(
        email: emailC.text,
        password: passwordC.text,
      );
      if (res.user != null) {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar("Error", "Login Gagal: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}