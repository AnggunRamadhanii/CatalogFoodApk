import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX untuk koneksi API

class FoodBanner extends StatefulWidget {
  const FoodBanner({super.key});

  @override
  State<FoodBanner> createState() => _FoodBannerState();
}

class _FoodBannerState extends State<FoodBanner> {
  int _currentIndex = 0;
  Timer? _timer;
  bool _isLoading = true; 

  final List<String> _bannerImages = [];
  final List<String> _bannerTitles = []; 

  @override
  void initState() {
    super.initState();
    _fetchImagesFromApi(); 
  }

  Future<void> _fetchImagesFromApi() async {
    final connect = GetConnect();
    
    try {
      for (int i = 0; i < 5; i++) {
        final response = await connect.get('https://www.themealdb.com/api/json/v1/1/random.php');
        if (response.statusCode == 200) {
          final data = response.body;
          if (data != null && data['meals'] != null) {
            final meal = data['meals'][0];
            final imageUrl = meal['strMealThumb'];
            final title = meal['strMeal'];

            if (imageUrl != null) {
              setState(() {
                _bannerImages.add(imageUrl);
                _bannerTitles.add(title);
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal ambil gambar: $e");
      if (_bannerImages.isEmpty) {
        _bannerImages.add('https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80');
        _bannerTitles.add('Menu Spesial');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _startAutoPlay(); 
      }
    }
  }

  void _startAutoPlay() {
    if (_bannerImages.isEmpty) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _bannerImages.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _bannerImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    if (_bannerImages.isEmpty) return const SizedBox(); // Hide jika gagal total

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 180, 
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), 
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000), 
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.network(
                _bannerImages[_currentIndex],
                key: ValueKey<String>(_bannerImages[_currentIndex]), 
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (ctx, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                  );
                },
                errorBuilder: (ctx, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Rekomendasi Chef 🔥",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Teks ini juga mengambil dari API
                  Text(
                    _bannerTitles.isNotEmpty ? _bannerTitles[_currentIndex] : "Menu Lezat",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}