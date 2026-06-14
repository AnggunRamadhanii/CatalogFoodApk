import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catalogfood/app/ui/pages/profile_view.dart';
import 'package:catalogfood/app/controllers/product_controller.dart';
import 'package:catalogfood/app/ui/widgets/product_card.dart';
import 'package:catalogfood/app/ui/pages/cart_page.dart';
import 'package:catalogfood/app/ui/pages/map_page.dart'; 

const Color kTargetRed = Color(0xFF8A0014); 


class HomePage extends StatelessWidget {
  HomePage({super.key});
  
  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
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
                    _buildHeadline(context),
                    const SizedBox(height: 16),
                    _buildSearchRow(context),
                    const SizedBox(height: 24),
                    _buildCategoryList(context),
                    const SizedBox(height: 24),
                    _buildProductGrid(),
                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => const ProfileView());
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 22,
                
                backgroundColor: Theme.of(context).cardColor, 
                
                child: Icon(Icons.person_rounded, color: Theme.of(context).iconTheme.color, size: 24),
              ),
            ),
          ),
          
          Row(
            children: [
              Obx(() {
                int totalItem = controller.totalCartItems.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).iconTheme.color, size: 26), 
                      onPressed: () => Get.to(() => CartPage()),
                    ),
                    if (totalItem > 0) 
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: kTargetRed, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Center(
                            child: Text(
                              "$totalItem",
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.notifications_none_outlined, color: Theme.of(context).iconTheme.color, size: 26),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(BuildContext context) {
    
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RichText(
        text: TextSpan(
          text: "Choose\n",
          style: TextStyle(fontSize: 22, color: textColor, height: 1.2, fontWeight: FontWeight.w500),
          children: [
            TextSpan(
              text: "Your Favorite ",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
            ),
            const TextSpan(
              text: "Food",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kTargetRed), 
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, 
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                onChanged: (value) => controller.searchText.value = value,
                
                decoration: const InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Get.to(() => MapPage()),
            child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
            color: kTargetRed,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
            ),
           ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final categories = ["All", "Main Course", "Dessert", "Snack", "Drinks"];
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final categoryName = categories[index];
          return Obx(() {
            bool isActive = controller.selectedCategory.value == categoryName || 
                            (categoryName == "All" && controller.selectedCategory.value == "Semua");
            return GestureDetector(
              onTap: () {
                if (categoryName == "All") {
                  controller.changeCategory("Semua");
                } else {
                  controller.changeCategory(categoryName);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isActive ? kTargetRed : Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(20),
                  border: isActive ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      color: isActive ? Colors.white : textColor, 
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: kTargetRed));
      }

      final displayProducts = controller.filteredProducts;

      if (displayProducts.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Center(
            child: Text("Menu tidak ditemukan", style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), 
          itemCount: displayProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,         
            crossAxisSpacing: 16,      
            mainAxisSpacing: 16,       
            childAspectRatio: 0.72,    
          ),
          itemBuilder: (context, index) {
            final product = displayProducts[index];
            return GestureDetector(
              onTap: () => _showQuantityBottomSheet(context, product), 
              child: ProductCard(product: product),
            );
          },
        ),
      );
    });
  }

  void _showQuantityBottomSheet(BuildContext context, dynamic product) {
    final RxInt quantity = 1.obs; 
    
    
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.name ?? "Menu Makanan", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor), 
              ),
              const SizedBox(height: 6),
              Text(
                "Rp ${product.price ?? 0}", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTargetRed),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tentukan Jumlah Porsi:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () { if (quantity.value > 1) quantity.value--; },
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: kTargetRed, size: 28),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                        "${quantity.value}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor), 
                      )),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => quantity.value++,
                        icon: const Icon(Icons.add_circle_outline_rounded, color: kTargetRed, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kTargetRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    controller.addItem(product.id);
                    Get.back(); 
                    Get.snackbar(
                      "Berhasil", 
                      "${quantity.value}x ${product.name} dimasukkan ke keranjang",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: const Text("Tambah ke Keranjang", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}