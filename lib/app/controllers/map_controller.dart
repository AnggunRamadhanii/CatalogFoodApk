import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'dart:convert'; 

class LocationController extends GetxController {
  final MapController mapController = MapController(); 
  
  var currentPosition = Rxn<LatLng>();
  var isLoading = true.obs;
  var distanceInfo = "Mencari lokasi...".obs;

  StreamSubscription<Position>? _positionStreamSubscription;
  var routePoints = <LatLng>[].obs;

 Future<void> fetchRouteToCanteen() async {
    if (currentPosition.value == null) {
      Get.snackbar("Info Rute", "Gagal mengambil rute: Koordinat posisi kamu masih kosong");
      return;
    }
    
    try {
      final start = currentPosition.value!;
      final end = canteenLocation;
      
      final String osrmUrl = 'https://router.project-osrm.org/route/v1/foot/'
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
          '?geometries=geojson&overview=full';
      
      String finalUrl = osrmUrl;
      if (GetPlatform.isWeb) {
        finalUrl = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(osrmUrl)}';
      }
      
      final response = await Dio().get(finalUrl);
      
      if (response.statusCode == 200) {
        var data = response.data;
        
        if (data is String) {
          data = jsonDecode(data);
        }

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
          
          routePoints.value = coordinates.map((c) => LatLng(c[1], c[0])).toList();
          
          Get.snackbar(
            "Info Rute", 
            "Berhasil memuat rute jalan raya belok-belok!",
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        } else {
          Get.snackbar("Info Rute", "API merespon, tapi tidak ditemukan jalan kaki ke arah kantin");
        }
      }
    } catch (e) {
      Get.snackbar(
        "Gagal Memuat Rute", 
        "Detail Error: $e",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 7),
      );
    }
  }

  final LatLng canteenLocation = const LatLng(-7.921529, 112.597288); 

  @override
  void onInit() {
    super.onInit();
    initLocationService();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> initLocationService() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("GPS Mati", "Mohon nyalakan GPS Anda.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, 
      );
      updateUserLocation(position);
    } catch (e) {
      // ignore
    }

    startLiveTracking();
  }

  void startLiveTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      updateUserLocation(position);
      checkGeofence(position);
    });
  }

  void updateUserLocation(Position position) {
    currentPosition.value = LatLng(position.latitude, position.longitude);
    isLoading.value = false;

    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude, position.longitude,
      canteenLocation.latitude, canteenLocation.longitude,
    );

    if (distanceInMeters > 1000) {
      distanceInfo.value = "${(distanceInMeters / 1000).toStringAsFixed(1)} km dari Kantin";
    } else {
      distanceInfo.value = "${distanceInMeters.toStringAsFixed(0)} meter dari Kantin";
    }
  }

  void checkGeofence(Position position) {
    double distance = Geolocator.distanceBetween(
      position.latitude, position.longitude,
      canteenLocation.latitude, canteenLocation.longitude,
    );

    if (distance < 50) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          "Sampai!", 
          "Anda sudah dekat dengan kantin.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}