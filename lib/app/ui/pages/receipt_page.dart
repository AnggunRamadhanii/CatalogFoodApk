import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:catalogfood/app/controllers/product_controller.dart'; 

class ReceiptPage extends StatefulWidget {
  final Map<String, dynamic> pesanan;

  const ReceiptPage({super.key, required this.pesanan});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final GlobalKey _globalKey = GlobalKey();
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isReviewSubmitted = false;

  
  Future<void> _downloadStruk() async {
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
      String namaFile = 'Struk_${widget.pesanan['id'] ?? 'Pesanan'}.png';
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
      Get.snackbar("Gagal Mengirim", "Terjadi kesalahan: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    Map<String, dynamic> items = widget.pesanan['items'] ?? {};
    const Color kMaroon = Color(0xFF800000); 
    String firstProductId = items.isNotEmpty ? items.keys.first.toString() : "";

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), 
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 70),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Pembayaran Berhasil!',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ),
              Center(
                child: Text(
                  'Pesananmu segera disiapkan.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 25),

              
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'STRUK PESANAN',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade500, letterSpacing: 1.2),
                        ),
                      ),
                      const Divider(height: 25, thickness: 1),
                      
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ID Transaksi', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                          Text(widget.pesanan['id'] ?? 'TRX-1781', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                          Text('LUNAS', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                        ],
                      ),
                      const Divider(height: 25, thickness: 1),

                      
                      ...items.entries.map((entry) {
                        String idProduk = entry.key;
                        int kuantitas = entry.value;
                        var produk = productController.products.firstWhereOrNull((p) => p.id.toString() == idProduk);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${produk?.name ?? 'Makanan'} x$kuantitas', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text('Rp ${((produk?.price ?? 0) * kuantitas)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }),
                      
                      const Divider(height: 25, thickness: 1),
                      
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Rp ${widget.pesanan['total_harga'] ?? 0}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: kMaroon)),
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
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
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
                          Text("Berikan bintang dan masukan untuk menu ini.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 10),
                          
                          
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
                          const SizedBox(height: 12),
                          
                          
                          TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: "Tulis komentar di sini (opsional)...",
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
                              onPressed: () => _submitReview(productController, firstProductId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kMaroon,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text("Kirim Ulasan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _downloadStruk,
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
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMaroon,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Kembali ke Beranda', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}