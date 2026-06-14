import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  
  final isLoadingProfile = false.obs;
  final isLoadingOrders = false.obs; 
  final usernameController = TextEditingController();
  
  final orderHistory = [].obs; 

  @override
  void onInit() {
    super.onInit();
    fetchProfile(); 
    fetchOrders();  
  }

  Future<void> fetchProfile() async {
    isLoadingProfile.value = true;
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('users') 
            .select('username')
            .eq('id', userId)
            .maybeSingle(); 
            
        if (response != null) {
          usernameController.text = response['username'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat profil: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> updateUsername() async {
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Username tidak boleh kosong');
      return;
    }

    isLoadingProfile.value = true;
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('users').update({
          'username': usernameController.text.trim(),
        }).eq('id', userId);
        
        Get.snackbar('Sukses', 'Username berhasil diperbarui', 
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal update profil: $e');
    } finally {
      isLoadingProfile.value = false; 
    }
  }
  Future<void> fetchOrders() async {
    isLoadingOrders.value = true;
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('orders')
            .select()
            .eq('user_id', userId) 
            .order('created_at', ascending: false); 
            
        orderHistory.assignAll(response); 
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat riwayat pesanan: $e');
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login'); 
  }
}