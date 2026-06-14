import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; 
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:catalogfood/app/controllers/product_controller.dart'; 
import 'package:catalogfood/app/controllers/order_controller.dart'; 

class DetailStrukPage extends StatelessWidget {
  final Map<String, dynamic> pesanan;

  
  final GlobalKey _globalKey = GlobalKey();

  DetailStrukPage({super.key, required this.pesanan});

  
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
      String namaFile = 'Struk_${pesanan['id'] ?? 'Pesanan'}.png';
      File imgFile = File('${directory.path}/$namaFile');
      
      
      await imgFile.writeAsBytes(pngBytes);

      
      Get.back();

      
      Get.snackbar(
        'Unduhan Berhasil',
        'Struk telah disimpan di: ${imgFile.path}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
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

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    
    final ReviewController reviewController = Get.put(ReviewController());
    Map<String, dynamic> items = pesanan['items'] ?? {};
    const Color kMaroon = Color(0xFF800000); 

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Struk Pesanan', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 50),
                          const SizedBox(height: 10),
                          Text(
                            'Pesanan Berhasil',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            pesanan['id'] ?? 'TRX-UNKNOWN',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(thickness: 2, color: Colors.grey),
                    ),

                    
                    Text(
                      'Rincian Pesanan',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: kMaroon),
                    ),
                    const SizedBox(height: 10),

                    ...items.entries.map((entry) {
                      String idProduk = entry.key;
                      int kuantitas = entry.value;

                      var produk = productController.products.firstWhereOrNull(
                        (p) => p.id.toString() == idProduk
                      );

                      String namaMenu = produk != null ? produk.name : 'Item Tidak Diketahui';
                      int hargaSatuan = produk != null ? produk.price : 0;
                      int subTotal = hargaSatuan * kuantitas;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${kuantitas}x', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(namaMenu, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                  Text('@ Rp $hargaSatuan', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                  
                                  
                                  GestureDetector(
                                    onTap: () {
                                      _tampilkanDialogRating(context, pesanan['id'] ?? 'UNKNOWN_ID', idProduk, namaMenu);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star_border, size: 16, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Beri Penilaian',
                                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.amber.shade800, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text('Rp $subTotal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }), 

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(),
                    ),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          'Rp ${pesanan['total_harga'] ?? 0}', 
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: kMaroon)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _downloadStruk,
                icon: const Icon(Icons.download, color: Colors.white),
                label: Text(
                  'Download Struk',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMaroon,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  void _tampilkanDialogRating(BuildContext context, String orderId, String productId, String namaMenu) {
    final ReviewController reviewController = Get.find<ReviewController>();
    double inputRating = 5.0; 
    final TextEditingController commentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Nilai $namaMenu', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                inputRating = rating;
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis ulasan masukan rasa makanan di sini...',
                hintStyle: GoogleFonts.poppins(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800000)),
            onPressed: reviewController.isLoading.value 
              ? null 
              : () {
                  reviewController.kirimReview(
                    orderId: orderId,
                    productId: productId,
                    rating: inputRating.toInt(),
                    comment: commentController.text,
                  );
                },
            child: reviewController.isLoading.value
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Kirim', style: GoogleFonts.poppins(color: Colors.white)),
          )),
        ],
      ),
    );
  }
}