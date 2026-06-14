import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'order_model.dart'; 
import 'package:catalogfood/app/ui/pages/waiting_confirmation_page.dart'; 


class ProductModel {
  final String id;
  final String name;
  final int price;
  final String imagePath;
  final String category; 

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category, 
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(), 
      name: json['name'] ?? 'Tanpa Nama',
      price: json['price'] ?? 0,
      imagePath: json['imagePath'] ?? 'assets/images/default.jpg',
      category: json['category'] ?? 'Lainnya',
    );
  }
}

class ProductController extends GetxController {
  
  final SupabaseClient supabase = Supabase.instance.client;
  
  var products = <ProductModel>[].obs;
  var isLoading = true.obs;

  var searchText = ''.obs;
  var selectedCategory = 'Semua'.obs; 
  
  var cartItems = <String, int>{}.obs; 
  var totalCartItems = 0.obs;

  
  var currentActiveOrder = Rxn<OrderModel>();

  int getItemQuantity(String productId) {
    return cartItems[productId] ?? 0;
  }

  void addItem(String productId) {
    if (cartItems.containsKey(productId)) {
      cartItems[productId] = cartItems[productId]! + 1;
    } else {
      cartItems[productId] = 1;
    }
    _updateCartBadge();
  }

  void removeItem(String productId) {
    if (cartItems.containsKey(productId)) {
      if (cartItems[productId]! > 1) {
        cartItems[productId] = cartItems[productId]! - 1;
      } else {
        cartItems.remove(productId); 
      }
      _updateCartBadge();
    }
  }

  void _updateCartBadge() {
    totalCartItems.value = cartItems.values.fold(0, (sum, qty) => sum + qty);
  }

  @override
  void onInit() {
    super.onInit();
    fetchProductsFromDB();
  }

  List<ProductModel> get filteredProducts {
    return products.where((item) {
      bool matchSearch = item.name.toLowerCase().contains(searchText.value.toLowerCase());
      
      String currentCategory = selectedCategory.value.trim().toLowerCase();
      String itemCategory = item.category.trim().toLowerCase();
      
      bool matchCategory = currentCategory == 'semua' || itemCategory == currentCategory;
      
      return matchSearch && matchCategory;
    }).toList();
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  String formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  int get grandTotal {
    int total = 0;
    cartItems.forEach((id, qty) {
      var product = products.firstWhereOrNull((p) => p.id == id);
      if (product != null) {
        total += (product.price * qty);
      }
    });
    return total;
  }

  Future<void> fetchProductsFromDB() async {
    isLoading.value = true;
    try {
      final response = await supabase.from('products').select();
      products.value = response.map((item) => ProductModel.fromJson(item)).toList();
    } catch (e) {
      Get.snackbar("Waduh!", "Gagal ngambil data makanan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  
  void processPayment() async {
    if (cartItems.isEmpty) {
      Get.snackbar("Eits!", "Pilih makanan dulu dong buat masuk keranjang!");
      return;
    }

    
    final user = supabase.auth.currentUser;
    if (user == null) {
      
      Get.snackbar(
        "Sesi Berakhir", 
        "Silakan login ulang untuk melanjutkan pesanan.", 
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
      Get.offAllNamed('/login'); 
      return;
    }

    
    final String currentUserId = user.id;

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      String orderId = "TRX-${DateTime.now().millisecondsSinceEpoch}";
      
      OrderModel newOrder = OrderModel(
        id: orderId,
        items: Map.from(cartItems),
        totalHarga: grandTotal,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      
      Map<String, dynamic> orderDataToInsert = newOrder.toJson();
      orderDataToInsert['user_id'] = currentUserId; 

      
      await supabase.from('orders').insert(orderDataToInsert);

      
      currentActiveOrder.value = newOrder;
      listenToOrderStatusRealtime(orderId);

      cartItems.clear();
      _updateCartBadge();

      Get.back(); 
      Get.to(() => const WaitingConfirmationPage());

    } catch (e) {
      Get.back(); 
      Get.snackbar(
        "Gagal", 
        "Error sistem saat mengirim pesanan: $e", 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
      );
    }
  }
Future<void> markOrderAsPaid(String orderId) async {
  await Supabase.instance.client
      .from('orders')
      .update({'status': 'paid'}) 
      .eq('id', orderId);
}

Future<void> addProductReview({required String productId, required int rating, required String comment}) async {
  await Supabase.instance.client.from('reviews').insert({
    'product_id': productId,
    'rating': rating,
    'comment': comment,
    'created_at': DateTime.now().toIso8601String(),
  });
}
  
Stream<List<Map<String, dynamic>>> getAdminReviewsStream() {
  return Supabase.instance.client
      .from('reviews')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false); 
}

  Stream<List<Map<String, dynamic>>> getAdminPendingOrdersStream() {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .order('created_at', ascending: false);
  }

  
 

  
  void listenToOrderStatusRealtime(String orderId) {
    supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            
            var updatedOrder = OrderModel.fromJson(data.first);
            currentActiveOrder.value = updatedOrder;
          }
        }, onError: (error) {
          debugPrint("Realtime Stream Error: $error");
        });
  }

  Future<void> logout() async {
    try { 
      await supabase.auth.signOut(); 
    } catch (e) {
      debugPrint("Gagal logout dari Supabase: $e"); 
    }
    Get.offAllNamed('/login');
  }
} 