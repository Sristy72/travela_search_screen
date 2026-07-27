import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_search_controller.dart';

class PriceFilterSheet extends StatelessWidget {
  const PriceFilterSheet({super.key});

  static const Color primaryPink = Color(0xFFE51D5A);
  static const double minLimit = 500;
  static const double maxLimit = 20000;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertySearchController>();
    final start = (controller.minPrice.value ?? minLimit).clamp(minLimit, maxLimit);
    final end = (controller.maxPrice.value ?? maxLimit).clamp(minLimit, maxLimit);
    final currentRange = RangeValues(start, end).obs;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Range',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BDT ${currentRange.value.start.round()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PriceFilterSheet.primaryPink),
                  ),
                  Text(
                    'BDT ${currentRange.value.end.round()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PriceFilterSheet.primaryPink),
                  ),
                ],
              )),
          const SizedBox(height: 16),

          Obx(() => RangeSlider(
                values: currentRange.value,
                min: minLimit,
                max: maxLimit,
                divisions: 39,
                activeColor: PriceFilterSheet.primaryPink,
                inactiveColor: Colors.grey.shade300,
                labels: RangeLabels(
                  'BDT ${currentRange.value.start.round()}',
                  'BDT ${currentRange.value.end.round()}',
                ),
                onChanged: (values) {
                  currentRange.value = values;
                },
              )),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    controller.setPriceRange(null, null);
                    Get.back();
                  },
                  child: const Text('Reset', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PriceFilterSheet.primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    controller.setPriceRange(currentRange.value.start, currentRange.value.end);
                    Get.back();
                  },
                  child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
