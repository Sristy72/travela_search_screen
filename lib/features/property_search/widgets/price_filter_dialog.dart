import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_search_controller.dart';

class PriceFilterSheet extends StatefulWidget {
  const PriceFilterSheet({super.key});

  static const Color primaryPink = Color(0xFFE51D5A);

  @override
  State<PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<PriceFilterSheet> {
  late RangeValues _currentRange;
  final double _min = 500;
  final double _max = 20000;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<PropertySearchController>();
    final start = controller.minPrice.value ?? _min;
    final end = controller.maxPrice.value ?? _max;
    _currentRange = RangeValues(
      start.clamp(_min, _max),
      end.clamp(_min, _max),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertySearchController>();

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BDT ${_currentRange.start.round()}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PriceFilterSheet.primaryPink),
              ),
              Text(
                'BDT ${_currentRange.end.round()}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PriceFilterSheet.primaryPink),
              ),
            ],
          ),
          const SizedBox(height: 16),

          RangeSlider(
            values: _currentRange,
            min: _min,
            max: _max,
            divisions: 39,
            activeColor: PriceFilterSheet.primaryPink,
            inactiveColor: Colors.grey.shade300,
            labels: RangeLabels(
              'BDT ${_currentRange.start.round()}',
              'BDT ${_currentRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _currentRange = values;
              });
            },
          ),
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
                    controller.setPriceRange(_currentRange.start, _currentRange.end);
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
