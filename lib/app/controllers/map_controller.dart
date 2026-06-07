import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationController extends GetxController {
  final MapController mapController = MapController(); 
  
  var currentPosition = Rxn<LatLng>();
  var isLoading = true.obs;
  var distanceInfo = "Mencari lokasi...".obs;

  StreamSubscription<Position>? _positionStreamSubscription;

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