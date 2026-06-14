import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '/app/controllers/profile_controller.dart'; 

import '/app/services/theme_service.dart'; 
import 'package:catalogfood/app/controllers/product_controller.dart';
import 'detail_struk_page.dart'; 

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    
    
    final themeService = Get.find<ThemeService>(); 
    
    const Color kMaroon = Color(0xFF800000);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMaroon,
        foregroundColor: Colors.white, 
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            "Pengaturan Akun", 
            style: GoogleFonts.poppins(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: kMaroon,
            )
          ),
          const SizedBox(height: 16),
          
          
          Obx(() => Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: ListTile(
                  leading: Icon(
                    themeService.isDarkMode.value ? Icons.dark_mode : Icons.light_mode, 
                    color: kMaroon
                  ),
                  title: Text(
                    'Mode Gelap',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  trailing: Switch(
                    value: themeService.isDarkMode.value,
                    activeColor: kMaroon, 
                    
                    onChanged: (value) => themeService.switchTheme(), 
                  ),
                ),
              )),

          Obx(() => controller.isLoadingProfile.value 
            ? const Center(child: CircularProgressIndicator(color: kMaroon))
            : TextField(
                controller: controller.usernameController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person_outline, color: kMaroon),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: kMaroon, width: 2),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey.withOpacity(0.05),
                ),
              )
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              onPressed: controller.updateUsername,
              child: Text(
                'SIMPAN PERUBAHAN', 
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                )
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(thickness: 1, color: Colors.black12),
          ),

          Text(
            "Riwayat Pesanan", 
            style: GoogleFonts.poppins(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: kMaroon,
            )
          ),
          const SizedBox(height: 16),
          
          Obx(() {
            if (controller.isLoadingOrders.value) {
              return const Center(child: CircularProgressIndicator(color: kMaroon));
            }

            if (controller.orderHistory.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'Belum ada riwayat pesanan.', 
                    style: GoogleFonts.poppins(color: Colors.grey, fontStyle: FontStyle.italic)
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: controller.orderHistory.length,
              itemBuilder: (context, index) {
                final pesanan = controller.orderHistory[index];
                
                
                String judulPesanan = 'Pesanan Tidak Diketahui';
                
                
                Map<String, dynamic> items = pesanan['items'] ?? {};
                
                if (items.isNotEmpty) {
                  
                  String idProdukPertama = items.keys.first.toString();
                  
                  
                  
                   var produkDitemukan = Get.find<ProductController>().products.firstWhereOrNull(
                   (p) => p.id.toString() == idProdukPertama
        );
                  if (produkDitemukan != null) {
                    judulPesanan = produkDitemukan.name; 
                    
                    
                    if (items.length > 1) {
                      judulPesanan += " & ${items.length - 1} item lainnya";
                    }
                  }
                }
                

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: ListTile(
                    onTap: () {
                      Get.to(() => DetailStrukPage(pesanan: pesanan));
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kMaroon.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long, color: kMaroon),
                    ),
                    title: Text(
                      
                      judulPesanan, 
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      pesanan['status'] ?? 'Menunggu',
                      style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13),
                    ),
                    trailing: Text(
                      'Rp ${pesanan['total_harga'] ?? 0}', 
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kMaroon, fontSize: 14)
                    ),

                    
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}