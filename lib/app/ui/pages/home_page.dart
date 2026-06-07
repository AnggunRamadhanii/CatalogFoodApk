import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catalogfood/app/controllers/product_controller.dart';
import 'package:catalogfood/app/ui/widgets/product_card.dart';
import 'package:catalogfood/app/ui/pages/cart_page.dart';
import 'package:catalogfood/app/ui/pages/map_page.dart'; 
import 'package:catalogfood/app/ui/widgets/auth_components.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'package:flutter/services.dart'; 

class HomePage extends StatelessWidget {
  HomePage({super.key});
  
  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context), 
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    _buildSearchBar(),
                    
                    const SizedBox(height: 20),
                    _buildPromoBanner(),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Kategori", 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)
                          ),
                          
                          GestureDetector(
                            onTap: () => Get.to(() => MapPage()), 
                            child: Row(
                              children: [
                                Icon(Icons.map_outlined, color: kPinkPrimary, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "Lihat Peta", 
                                  style: TextStyle(color: kPinkPrimary, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _buildCategoryList(),
                    const SizedBox(height: 24),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text("Rekomendasi Untukmu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
                    ),
                    const SizedBox(height: 12),

                    _buildProductGrid(),
                    
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Halo, Anggun! 👋", style: TextStyle(color: Colors.grey, fontSize: 14)),
              SizedBox(height: 4),
              Text("Mau makan apa?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextDark)),
            ],
          ),
          
          Row(
            children: [
               // --- TOMBOL RAHASIA COPY TOKEN (DEBUG) ---
              IconButton(
                icon: const Icon(Icons.token, color: kPinkPrimary),
                onPressed: () async {
                  // Ambil token
                  String? token = await FirebaseMessaging.instance.getToken();
                  
                  // Gunakan debugPrint agar token panjang TIDAK TERPOTONG di console
                  debugPrint("\n==================================");
                  debugPrint("FCM TOKEN:");
                  debugPrint(token);
                  debugPrint("==================================\n");
                  
                  // Copy ke Clipboard HP
                  if (token != null) {
                    await Clipboard.setData(ClipboardData(text: token));
                    Get.snackbar("Token Disalin!", "Cek Debug Console VS Code");
                  }
                },
              ),
              // ---------------------------------

              IconButton(
                icon: const Icon(Icons.logout, color: kTextDark),
                onPressed: () => controller.logout(),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () => Get.to(() => CartPage()),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.shopping_cart_outlined, color: kTextDark),
                    ),
                    Obx(() => controller.cart.isNotEmpty
                        ? Positioned(
                            right: -5, top: -5,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(color: kPinkPrimary, shape: BoxShape.circle),
                              child: Text('${controller.cart.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          )
                        : const SizedBox()),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- SEARCH BAR ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            controller.searchText.value = value;
          },
          decoration: const InputDecoration(
            hintText: "Cari nasi goreng, ayam...",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // --- PROMO BANNER ---
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [kPinkPrimary, kPinkPrimary.withValues(alpha: 0.7)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20, bottom: -20,
              child: Icon(Icons.fastfood, size: 120, color: Colors.white.withValues(alpha: 0.2)),
            ),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Diskon 50%", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Khusus Pengguna Baru", style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KATEGORI LIST ---
  Widget _buildCategoryList() {
    final categories = ["Semua", "Makanan", "Minuman", "Snack", "Pedas"];
    
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final categoryName = categories[index];
          
          return Obx(() {
            bool isActive = controller.selectedCategory.value == categoryName;
            
            return GestureDetector(
              onTap: () => controller.changeCategory(categoryName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? kPinkPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isActive ? null : Border.all(color: Colors.grey.shade200),
                  boxShadow: isActive 
                    ? [BoxShadow(color: kPinkPrimary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))] 
                    : [],
                ),
                child: Text(
                  categoryName,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // --- GRID PRODUK ---
  Widget _buildProductGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final displayProducts = controller.filteredProducts;

      if (displayProducts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Menu tidak ditemukan 😔", style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            if (constraints.maxWidth > 600) crossAxisCount = 3;
            if (constraints.maxWidth > 900) crossAxisCount = 4;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: displayProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: displayProducts[index]);
              },
            );
          },
        ),
      );
    });
  }
}