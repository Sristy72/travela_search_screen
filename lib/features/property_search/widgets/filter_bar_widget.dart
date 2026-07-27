import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_search_controller.dart';
import 'price_filter_dialog.dart';

class FilterBarWidget extends StatelessWidget {
  const FilterBarWidget({super.key});

  static const Color primaryPink = Color(0xFFE51D5A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertySearchController>();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Filter Icon pill
          _FilterPill(
            icon: Icons.tune,
            label: 'Filter',
            isSelected: controller.minPrice.value != null ||
                controller.instantBookingOnly.value ||
                controller.minRating.value != null,
            onTap: () {
              Get.bottomSheet(const PriceFilterSheet());
            },
          ),
          const SizedBox(width: 8),

          // Price pill
          Obx(() {
            final min = controller.minPrice.value;
            final max = controller.maxPrice.value;
            String label = 'Price';
            bool selected = false;
            if (min != null || max != null) {
              label = 'BDT ${min?.toInt() ?? 0} - ${max?.toInt() ?? '10k+'}';
              selected = true;
            }
            return _FilterPill(
              label: label,
              isSelected: selected,
              onTap: () {
                Get.bottomSheet(const PriceFilterSheet());
              },
            );
          }),
          const SizedBox(width: 8),

          // Instant Booking pill
          Obx(() {
            final selected = controller.instantBookingOnly.value;
            return _FilterPill(
              label: 'Instant Booking',
              isSelected: selected,
              onTap: controller.toggleInstantBooking,
            );
          }),
          const SizedBox(width: 8),

          // Rating 4.7+ pill
          Obx(() {
            final isSelected = controller.minRating.value == 4.7;
            return _FilterPill(
              label: '4.7+',
              isSelected: isSelected,
              icon: Icons.star,
              onTap: () => controller.setMinRating(4.7),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FilterBarWidget.primaryPink.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? FilterBarWidget.primaryPink : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? FilterBarWidget.primaryPink : Colors.black87,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? FilterBarWidget.primaryPink : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
