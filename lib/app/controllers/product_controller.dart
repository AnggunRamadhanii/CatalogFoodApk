import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductModel {
  final String id;
  final String name;
  final int price;
  final String imagePath;
  final String category; 
  RxBool isSelected = false.obs;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category, 
  });
}

class ProductController extends GetxController {
  final Dio _dio = Dio();
  
  var products = <ProductModel>[].obs;
  var cart = <ProductModel>[].obs;
  var isLoading = true.obs;

  var searchText = ''.obs;
  var selectedCategory = 'Semua'.obs; 

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  List<ProductModel> get filteredProducts {
    return products.where((item) {
      bool matchSearch = item.name.toLowerCase().contains(searchText.value.toLowerCase());
      
      bool matchCategory = true;
      if (selectedCategory.value != 'Semua') {
        matchCategory = item.category == selectedCategory.value;
      }

      return matchSearch && matchCategory;
    }).toList();
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  String formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  int get grandTotal => cart.fold(0, (sum, item) => sum + item.price);

  void loadDummyData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    products.value = [
      ProductModel(id: '1', name: 'Nasi Goreng Spesial', price: 18000, category: 'Makanan', imagePath: 'assets/images/nasigoreng.jpg'),
      ProductModel(id: '2', name: 'Ayam Geprek Ijo', price: 15000, category: 'Makanan', imagePath: 'assets/images/ayamsambalijo.jpg'),
      ProductModel(id: '3', name: 'Mie Goreng Telur', price: 12000, category: 'Makanan', imagePath: 'assets/images/miegoreng.jpg'),
      ProductModel(id: '4', name: 'Sate Ayam Madura', price: 20000, category: 'Makanan', imagePath: 'assets/images/sateayam.jpg'),
      ProductModel(id: '5', name: 'Es Teh Manis', price: 5000, category: 'Minuman', imagePath: 'assets/images/esteh.jpg'),
      ProductModel(id: '6', name: 'Jus Alpukat', price: 12000, category: 'Minuman', imagePath: 'assets/images/jusalpukat.jpg'),
      ProductModel(id: '7', name: 'Bakso Urat', price: 15000, category: 'Makanan', imagePath: 'assets/images/baksourat.jpg'),
      ProductModel(id: '8', name: 'Soto Ayam', price: 13000, category: 'Makanan', imagePath: 'assets/images/sotoayam.jpg'),
    ];

    isLoading.value = false;
  }

  void toggleProduct(ProductModel product) {
    product.isSelected.value = !product.isSelected.value;
    if (product.isSelected.value) {
      cart.add(product);
    } else {
      cart.remove(product);
    }
    products.refresh();
  }

  Future<void> processPayment() async {
    if (cart.isEmpty) {
      Get.snackbar("Error", "Keranjang kosong!");
      return;
    }
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final response = await _dio.post(
        'https://jsonplaceholder.typicode.com/posts', 
        data: {'amount': grandTotal, 'items': cart.map((e) => e.name).toList()},
      );
      Get.back();
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.defaultDialog(
          title: "Berhasil", middleText: "Total: ${formatRupiah(grandTotal)}", textConfirm: "OK",
          onConfirm: () {
            for (var item in cart) { item.isSelected.value = false; }
            cart.clear(); products.refresh(); Get.back(); Get.back();
          },
        );
      }
    } catch (e) {
      Get.back(); Get.snackbar("Gagal", "Error: $e");
    }
  }

  Future<void> logout() async {
    try { await Supabase.instance.client.auth.signOut(); } catch (e) {}
    Get.offAllNamed('/login');
  }
}