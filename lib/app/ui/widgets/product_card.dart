import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Pastikan import ini mengarah ke controller yang benar
import '../../controllers/product_controller.dart'; 

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();

    return GestureDetector(
      onTap: () => controller.toggleProduct(product),
      child: Obx(() {
        bool isSelected = product.isSelected.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: Colors.green, width: 3)
                : Border.all(color: Colors.transparent, width: 0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), 
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[100],
                        child: Image.asset(
                          product.imagePath, 
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => 
                              const Center(child: Icon(Icons.fastfood, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.formatRupiah(product.price),
                          style: const TextStyle(
                            color: Color(0xFFFF69B4), // Pink
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4)
                      ],
                    ),
                    child: const Icon(
                      Icons.check, 
                      size: 16, 
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}