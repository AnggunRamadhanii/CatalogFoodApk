import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catalogfood/app/controllers/product_controller.dart';
import 'package:catalogfood/app/ui/widgets/auth_components.dart';

class CartPage extends StatelessWidget {
  CartPage({super.key});

  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteBg,
      appBar: AppBar(
        title: const Text("Keranjang Saya", style: TextStyle(color: kTextDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.cart.isEmpty) {
                return const Center(child: Text("Keranjang kosong"));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.cart.length,
                itemBuilder: (context, index) {
                  final item = controller.cart[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1), 
                          blurRadius: 5
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(controller.formatRupiah(item.price), style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => controller.toggleProduct(item),
                        )
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1), 
                  blurRadius: 10, 
                  offset: const Offset(0, -5)
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Pembayaran:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Obx(() => Text(
                      controller.formatRupiah(controller.grandTotal),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPinkPrimary),
                    )),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => controller.processPayment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPinkPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("BAYAR SEKARANG (API)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}