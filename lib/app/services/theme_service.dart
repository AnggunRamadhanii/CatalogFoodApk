import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxController {
  final String _key = "isDarkMode";
  late SharedPreferences _prefs;
  RxBool isDarkMode = false.obs;

  Future<ThemeService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    isDarkMode.value = _prefs.getBool(_key) ?? false;
  }

  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void switchTheme() {
    isDarkMode.value = !isDarkMode.value;
    _prefs.setBool(_key, isDarkMode.value);
    Get.changeThemeMode(theme);
  }
}