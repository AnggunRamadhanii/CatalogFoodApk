import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../../controllers/product_controller.dart';

class WaitingConfirmationPage extends StatefulWidget {
  const WaitingConfirmationPage({super.key});

  @override
  State<WaitingConfirmationPage> createState() => _WaitingConfirmationPageState();
}

class _WaitingConfirmationPageState extends State<WaitingConfirmationPage> {
  
  final GlobalKey _globalKey = GlobalKey();

  
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isReviewSubmitted = false;

  
  Future<void> _downloadStruk(String orderId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFF800000))),
        barrierDismissible: false,
      );

      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      String namaFile = 'Struk_$orderId.png';
      File imgFile = File('${directory.path}/$namaFile');
      
      await imgFile.writeAsBytes(pngBytes);

      Get.back(); 

      Get.snackbar(
        'Unduhan Berhasil',
        'Struk telah disimpan di dokumen perangkat.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); 
      Get.snackbar(
        'Gagal Mengunduh',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  
  Future<void> _submitReview(ProductController controller, String firstProductId) async {
    try {
      
      await controller.addProductReview(
        productId: firstProductId,
        rating: _selectedRating,
        comment: _commentController.text,
      );

      setState(() {
        _isReviewSubmitted = true;
      });

      Get.snackbar("Terima Kasih", "Ulasan Anda berhasil dikirim!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal Mengirim", "Pastikan fungsi addProductReview tersedia di Controller. Error: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();

    const Color kMaroon = Color(0xFF800000);
    const Color kLightBg = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: kLightBg,
      body: SafeArea(
        child: Obx(() {
          final order = controller.currentActiveOrder.value;

          
          if (order == null) {
            return Center(
              child: Text("Memuat data pesanan...", style: GoogleFonts.poppins()),
            );
          }

          
          if (order.status == 'pending') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      color: kMaroon,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Menunggu Konfirmasi Kasir",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kMaroon,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Pesananmu (ID: ${order.id.substring(0, 8)}) sudah masuk. Jangan tutup halaman ini, kasir sedang memproses pesananmu...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }

          
          if (order.status == 'paid') {
            
            String firstProductId = order.items.isNotEmpty ? order.items.keys.first.toString() : "";

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle_rounded, color: Colors.green.shade500, size: 70),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Pembayaran Berhasil!",
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    "Pesananmu segera disiapkan.",
                    style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                
                RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text("STRUK PESANAN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade400, fontSize: 12)),
                        ),
                        const Divider(height: 24, thickness: 1, color: Color(0xFFF1F1F1)),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ID Transaksi", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                            Text(order.id.substring(0, 8).toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                            Text("LUNAS", style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1, color: Color(0xFFF1F1F1)),
                        
                        ...order.items.entries.map((entry) {
                          var prod = controller.products.firstWhereOrNull((p) => p.id.toString() == entry.key.toString());
                          int hargaSatuan = prod?.price ?? 0;
                          int kuantitas = entry.value;
                          int subTotal = hargaSatuan * kuantitas;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text("${prod?.name ?? 'Menu'} x$kuantitas", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                                Text("Rp $subTotal", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }),
                        
                        const Divider(height: 24, thickness: 1, color: Color(0xFFF1F1F1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              controller.formatRupiah(order.totalHarga), 
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: kMaroon)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)
                    ],
                  ),
                  child: _isReviewSubmitted
                      ? Center(
                          child: Column(
                            children: [
                              const Icon(Icons.stars_rounded, color: Colors.amber, size: 40),
                              const SizedBox(height: 8),
                              Text("Terima kasih atas ulasan Anda!", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: kMaroon)),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Yuk, Beri Rating Makanan!", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: kMaroon)),
                            Text("Berikan bintang dan masukan saran untuk menu ini.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 12),
                            
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedRating = index + 1),
                                  child: Icon(
                                    index < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: Colors.amber,
                                    size: 38,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 14),
                            
                            
                            TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: "Tulis komentar / ulasan di sini...",
                                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                                fillColor: const Color(0xFFF8F9FA),
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            
                            
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _submitReview(controller, firstProductId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kMaroon,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text("Kirim Ulasan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadStruk(order.id),
                    icon: const Icon(Icons.download_rounded, color: kMaroon),
                    label: Text('Download Bukti Pesanan', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: kMaroon)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: kMaroon, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMaroon,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      controller.currentActiveOrder.value = null;
                      Get.offAllNamed('/home');
                    },
                    child: Text("Kembali ke Beranda", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text("Status tidak diketahui."));
        }),
      ),
    );
  }
}