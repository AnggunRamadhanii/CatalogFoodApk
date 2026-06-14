import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/product_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final ProductController controller = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());

    
    const Color kMaroon = Color(0xFF800000);
    const Color kDeepMaroon = Color(0xFF5A0000);
    const Color kLightBg = Color(0xFFF8F9FA); 

    return DefaultTabController(
      length: 4, 
      child: Scaffold(
        backgroundColor: kLightBg,
        appBar: AppBar(
          title: Text(
            "KANTIN ADMIN DASHBOARD", 
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              letterSpacing: 1.1
            )
          ),
          centerTitle: true,
          backgroundColor: kMaroon,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: kDeepMaroon.withAlpha(150),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.offAllNamed('/login'),
          ),
          bottom: TabBar(
  indicatorColor: Colors.white,
  indicatorWeight: 3,
  isScrollable: true, 
  
  
  labelColor: Colors.white, 
  unselectedLabelColor: Colors.white.withAlpha(160), 
  
  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
  unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
  tabs: const [
    Tab(text: "Semua"),
    Tab(text: "Pending"),
    Tab(text: "Paid"),
    Tab(text: "Ulasan & Rating"),
  ],
),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: controller.getAdminPendingOrdersStream(), 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kMaroon));
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Terjadi kesalahan koneksi database:\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }

            final rawOrders = snapshot.data ?? [];

            
            final semuaOrders = rawOrders;

final pendingOrders = rawOrders.where((o) {
  final String statusDb = (o['status'] ?? '').toString().toLowerCase();
  return statusDb == 'pending' || statusDb == 'waiting';
}).toList();
final paidOrders = rawOrders.where((o) {
  final String statusDb = (o['status'] ?? '').toString().toLowerCase();
  return statusDb == 'paid' || statusDb == 'selesai';
}).toList();
            return TabBarView(
              children: [
                
                _buildOrderList(semuaOrders, controller, kMaroon, kDeepMaroon, kLightBg),
                
                
                _buildOrderList(pendingOrders, controller, kMaroon, kDeepMaroon, kLightBg),
                
                
                _buildOrderList(paidOrders, controller, kMaroon, kDeepMaroon, kLightBg),
                
                
                _buildReviewList(controller, kMaroon, kDeepMaroon, kLightBg),
              ],
            );
          },
        ),
      ),
    );
  }

  
  Widget _buildOrderList(List<Map<String, dynamic>> orders, ProductController controller, Color kMaroon, Color kDeepMaroon, Color kLightBg) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_rounded, size: 70, color: Colors.grey.withAlpha(100)),
            const SizedBox(height: 12),
            Text(
              "Tidak Ada Pesanan", 
              style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final String orderId = order['id'] ?? '-';
        final int totalHarga = order['total_harga'] ?? 0;
        final Map<String, dynamic> items = order['items'] ?? {};
        final String status = (order['status'] ?? 'pending').toString().toUpperCase();

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                offset: const Offset(2, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, color: Color(0xFF800000), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "ID: ${orderId.length > 8 ? orderId.substring(0, 8) : orderId}", 
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: kDeepMaroon)
                        ),
                      ],
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == "PAID" || status == "SELESAI" ? Colors.green.shade50 : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: status == "PAID" || status == "SELESAI" ? Colors.green.shade300 : Colors.amber.shade300, 
                          width: 1
                        ),
                      ),
                      child: Text(
                        status, 
                        style: GoogleFonts.poppins(
                          color: status == "PAID" || status == "SELESAI" ? Colors.green.shade800 : Colors.amber.shade800, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 11
                        )
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1, color: Color(0xFFF1F1F1)),
                
                Text("ITEMS", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 6),
                
                ...items.entries.map((entry) {
                  var prod = controller.products.firstWhereOrNull((p) => p.id.toString() == entry.key.toString());
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: kLightBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            prod?.name ?? 'Menu #${entry.key}',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          "x${entry.value}",
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: kMaroon),
                        ),
                      ],
                    ),
                  );
                }),
                
                const Divider(height: 24, thickness: 1, color: Color(0xFFF1F1F1)),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TOTAL BAYAR", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                        Text(
                          controller.formatRupiah(totalHarga),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: kMaroon),
                        ),
                      ],
                    ),
                    
                    
                    if (status == "PENDING")
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(colors: [Color(0xFF800000), Color(0xFF5A0000)]),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, 
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF800000))),
                            );
                            
                            await controller.markOrderAsPaid(orderId);
                            Get.back(); 
                            
                            Get.snackbar(
                              "Konfirmasi Berhasil", 
                              "Pesanan selesai diproses.",
                              backgroundColor: Colors.white,
                              colorText: kMaroon,
                              icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                            );
                          },
                          child: Text("Terima Bayar", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  
  Widget _buildReviewList(ProductController controller, Color kMaroon, Color kDeepMaroon, Color kLightBg) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: controller.getAdminReviewsStream(), 
      builder: (context, reviewSnapshot) {
        if (reviewSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: kMaroon));
        }
        
        if (reviewSnapshot.hasError) {
          return Center(
            child: Text("Gagal memuat ulasan: ${reviewSnapshot.error}", style: GoogleFonts.poppins(color: Colors.red)),
          );
        }

        final reviews = reviewSnapshot.data ?? [];
        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_outline_rounded, size: 70, color: Colors.grey.withAlpha(100)),
                const SizedBox(height: 12),
                Text(
                  "Belum Ada Ulasan Masuk", 
                  style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: reviews.length,
          itemBuilder: (context, idx) {
            final rev = reviews[idx];
            final int bintang = rev['rating'] ?? 5;
            final String komentar = rev['comment'] ?? '-';
            final String prodId = (rev['product_id'] ?? '').toString();
            
            
            var prod = controller.products.firstWhereOrNull((p) => p.id.toString() == prodId);
            String namaMakanan = prod != null ? prod.name : "Menu #$prodId";

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 6,
                    offset: const Offset(1, 3),
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            namaMakanan, 
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: kDeepMaroon),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        Row(
                          children: List.generate(5, (b) => Icon(
                            b < bintang ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 18,
                          )),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kLightBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        komentar.isEmpty || komentar == "-" ? "Hanya memberikan rating bintang." : '"$komentar"',
                        style: GoogleFonts.poppins(
                          fontSize: 13, 
                          color: Colors.grey.shade700, 
                          fontStyle: komentar.isEmpty ? FontStyle.normal : FontStyle.italic
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}