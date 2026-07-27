import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../property_search/controllers/property_search_controller.dart';
import '../property_search/views/property_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<PropertySearchController>()) {
      Get.put(PropertySearchController());
    }
    return const PropertySearchScreen();
  }
}
