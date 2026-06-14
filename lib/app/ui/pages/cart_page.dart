import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    const Color themeColor = Color.fromARGB(255, 3, 80, 16); 

    
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Keranjang Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
        
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        
        if (controller.cartItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Keranjang masih kosong nih!', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.cartItems.length,
          itemBuilder: (context, index) {
            String productId = controller.cartItems.keys.elementAt(index);
            int qty = controller.cartItems[productId]!;
            
            var product = controller.products.firstWhereOrNull((p) => p.id == productId);
            if (product == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, 
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), 
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      product.imagePath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 80, height: 80, color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name, 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor) 
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.formatRupiah(product.price * qty), 
                          style: const TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  
                  
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => controller.removeItem(product.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: themeColor),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.remove, color: themeColor, size: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "$qty", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor) 
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.addItem(product.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16), 
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
      
      bottomNavigationBar: Obx(() {
        if (controller.cartItems.isEmpty) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), 
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Harga", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text(
                      controller.formatRupiah(controller.grandTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: themeColor),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => controller.processPayment(),
                  child: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}