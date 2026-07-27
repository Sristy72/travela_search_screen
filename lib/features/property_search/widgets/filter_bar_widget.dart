import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_search_controller.dart';
import 'date_range_picker_sheet.dart';
import 'guest_picker_sheet.dart';
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

          // Date selecting option pill
          Obx(() {
            final hasDates = controller.checkInDate.value != null && controller.checkOutDate.value != null;
            final label = hasDates ? controller.dateRangeText : 'Dates';
            return _FilterPill(
              icon: Icons.calendar_month_outlined,
              label: label,
              isSelected: hasDates,
              onTap: () {
                Get.to(() => const DateRangePickerSheet());
              },
            );
          }),
          const SizedBox(width: 8),

          // Guest selecting option pill
          Obx(() {
            final guests = controller.totalGuests;
            final hasGuests = guests > 0;
            final label = hasGuests ? '$guests Guests' : 'Guests';
            return _FilterPill(
              icon: Icons.person_outline,
              label: label,
              isSelected: hasGuests,
              onTap: () {
                Get.bottomSheet(const GuestPickerSheet());
              },
            );
          }),
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
