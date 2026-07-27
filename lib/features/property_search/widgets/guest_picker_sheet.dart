import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_search_controller.dart';

class GuestPickerSheet extends StatelessWidget {
  const GuestPickerSheet({super.key});

  static const Color primaryPink = Color(0xFFE51D5A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertySearchController>();
    final adults = controller.adultsCount.value.obs;
    final children = controller.childCount.value.obs;
    final infants = controller.infantCount.value.obs;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Guest Size',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Adults Counter Row
          Obx(() => _GuestCounterRow(
                title: 'Adults',
                subtitle: 'Ages 13 or above',
                count: adults.value,
                minCount: 1,
                onDecrement: () => adults.value--,
                onIncrement: () => adults.value++,
              )),
          const Divider(height: 32, color: Color(0xFFF0F0F0)),

          // Children Counter Row
          Obx(() => _GuestCounterRow(
                title: 'Child',
                subtitle: 'Ages 2-12',
                count: children.value,
                minCount: 0,
                onDecrement: () => children.value--,
                onIncrement: () => children.value++,
              )),
          const Divider(height: 32, color: Color(0xFFF0F0F0)),

          // Infants Counter Row
          Obx(() => _GuestCounterRow(
                title: 'Infants',
                subtitle: 'Under 2',
                count: infants.value,
                minCount: 0,
                onDecrement: () => infants.value--,
                onIncrement: () => infants.value++,
              )),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GuestPickerSheet.primaryPink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      controller.setGuests(adults.value, children.value, infants.value);
                      Get.back();
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuestCounterRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final int minCount;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _GuestCounterRow({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.minCount,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            _CounterButton(
              icon: Icons.remove,
              enabled: count > minCount,
              onPressed: onDecrement,
              isDark: false,
            ),
            Container(
              width: 36,
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _CounterButton(
              icon: Icons.add,
              enabled: true,
              onPressed: onIncrement,
              isDark: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final bool isDark;

  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? Colors.black87 : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? (isDark ? Colors.white : Colors.black87) : Colors.grey.shade400,
        ),
      ),
    );
  }
}
