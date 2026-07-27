import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_search_controller.dart';
import '../models/location_model.dart';

class LocationSearchModal extends StatelessWidget {
  const LocationSearchModal({super.key});

  static const Color primaryPink = Color(0xFFE51D5A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertySearchController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Container(
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            autofocus: true,
            onChanged: controller.onLocationQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search location',
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: Obx(() {
                if (controller.locationQuery.value.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: () {
                      controller.onLocationQueryChanged('');
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final suggestions = controller.locationSuggestions;
        final isLoading = controller.isLocationsLoading.value;

        return ListView(
          padding: const EdgeInsets.only(top: 8),
          children: [
            // Nearby location option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.my_location, color: primaryPink, size: 20),
              ),
              title: const Text(
                'Nearby',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              onTap: () {
                controller.selectLocation(
                  LocationModel(
                    id: 1,
                    name: 'Nearby',
                    lat: 23.7661,
                    lng: 90.3588,
                    within: 10.0,
                  ),
                );
                Get.back();
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFEEEEEE)),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: CircularProgressIndicator(color: primaryPink, strokeWidth: 2.5),
                ),
              )
            else
              ...suggestions.map((loc) {
                final displayName = loc.nameBn != null && loc.nameBn!.isNotEmpty
                    ? '${loc.name} (${loc.nameBn})'
                    : loc.name;

                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryPink.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on_outlined, color: primaryPink, size: 20),
                      ),
                      title: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      onTap: () {
                        controller.selectLocation(loc);
                        Get.back();
                      },
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF0F0F0)),
                  ],
                );
              }),
          ],
        );
      }),
    );
  }
}
