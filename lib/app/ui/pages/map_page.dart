import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../../controllers/map_controller.dart'; 
class MapPage extends StatelessWidget {
  MapPage({super.key});
  
  final LocationController controller = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = Theme.of(context).cardColor;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value && controller.currentPosition.value == null) {
              return Container(
                color: bgColor, 
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color.fromARGB(255, 166, 14, 34)),
                      SizedBox(height: 10),
                      Text("Mencari satelit GPS...", style: TextStyle(color: Colors.grey))
                    ],
                  ),
                ),
              );
            }

            final userPos = controller.currentPosition.value ?? controller.canteenLocation;

            return FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: userPos,
                initialZoom: 16.5,
                minZoom: 5,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.catalogfood',
                ),

                Obx(() {
                  final currentLoc = controller.currentPosition.value;
                  final routePts = controller.routePoints;

                  if (currentLoc == null) {
                    return PolylineLayer(polylines: <Polyline>[]);
                  }

                  return PolylineLayer(
                    polylines: [
                      if (routePts.isNotEmpty)
                        Polyline(
                          points: routePts.toList(),
                          strokeWidth: 5.0,
                          color: const Color.fromARGB(255, 166, 14, 34), 
                        )
                      else
                        Polyline(
                          points: [
                            currentLoc,
                            controller.canteenLocation,
                          ],
                          strokeWidth: 4.0,
                          color: Colors.grey, 
                        ),
                    ],
                  );
                }),

                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: controller.canteenLocation,
                      color: Colors.green.withValues(alpha: 0.15),
                      borderStrokeWidth: 2,
                      borderColor: Colors.green,
                      radius: 50, 
                    ),
                  ],
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: controller.canteenLocation,
                      width: 90,
                      height: 90,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: cardColor, 
                              shape: BoxShape.circle,
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                            ),
                            child: const Icon(Icons.storefront, color: Colors.red, size: 30),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cardColor, // MENGGUNAKAN WARNA ADAPTIF
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Text(
                              "Kantin", 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: textColor) // Teks adaptif
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (controller.currentPosition.value != null)
                      Marker(
                        point: controller.currentPosition.value!,
                        width: 70,
                        height: 70,
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 166, 14, 34), 
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 166, 14, 34),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),

          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardColor, 
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: Icon(Icons.arrow_back, color: textColor), 
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), 
                    blurRadius: 20, 
                    offset: const Offset(0, -5)
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rute ke Kantin",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor), 
                      ),
                      InkWell(
                        onTap: () {
                          if (controller.currentPosition.value != null) {
                            controller.mapController.move(controller.currentPosition.value!, 17);
                          } else {
                            Get.snackbar("Info", "Sedang mencari sinyal...");
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[100], 
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.my_location, color: Color.fromARGB(255, 166, 14, 34)),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 166, 14, 34).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color.fromARGB(255, 166, 14, 34).withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: bgColor, 
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_walk, color: Color.fromARGB(255, 166, 14, 34), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text(
                                controller.distanceInfo.value,
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                  color: textColor // Teks adaptif (sebelumnya kTextDark)
                                ),
                              )),
                              const SizedBox(height: 4),
                              const Text("Ikuti garis di peta", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Pastikan GPS aktif untuk akurasi terbaik",
                      style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}