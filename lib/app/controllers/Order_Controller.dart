import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ReviewController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;

  Future<void> kirimReview({
    required String orderId,
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      isLoading.value = true;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      await supabase.from('reviews').insert({
        'order_id': orderId,
        'user_id': userId,
        'product_id': int.parse(productId),
        'rating': rating,
        'comment': comment,
      });

      Get.back(); 
      Get.snackbar('Terima Kasih!', 'Ulasan kamu sangat berarti bagi kami.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal mengirim ulasan: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}