import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/property_search_controller.dart';
import 'guest_picker_sheet.dart';

class DateRangePickerSheet extends StatelessWidget {
  const DateRangePickerSheet({super.key});

  static const Color primaryPink = Color(0xFFE51D5A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertySearchController>();

    final selectedFrom = Rxn<DateTime>(controller.checkInDate.value);
    final selectedTo = Rxn<DateTime>(controller.checkOutDate.value);

    // Default displayed month: July 2026 or current month
    final now = DateTime.now();
    final initialMonth = controller.checkInDate.value ?? (now.year == 2026 ? now : DateTime(2026, 7, 1));
    final displayedMonth = DateTime(initialMonth.year, initialMonth.month, 1).obs;

    bool isSameDay(DateTime? a, DateTime? b) {
      if (a == null || b == null) return false;
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    int calculateDays() {
      if (selectedFrom.value == null || selectedTo.value == null) return 0;
      final diff = selectedTo.value!.difference(selectedFrom.value!).inDays;
      return diff > 0 ? diff : 0;
    }

    void onDaySelected(DateTime date) {
      if (selectedFrom.value == null) {
        selectedFrom.value = date;
        selectedTo.value = null;
      } else if (selectedTo.value == null) {
        if (date.isBefore(selectedFrom.value!)) {
          selectedFrom.value = date;
          selectedTo.value = null;
        } else if (isSameDay(date, selectedFrom.value!)) {
          selectedFrom.value = date;
          selectedTo.value = null;
        } else {
          selectedTo.value = date;
        }
      } else {
        // Reset and start new range
        selectedFrom.value = date;
        selectedTo.value = null;
      }
    }

    bool isInRange(DateTime date) {
      if (selectedFrom.value == null || selectedTo.value == null) return false;
      return date.isAfter(selectedFrom.value!) && date.isBefore(selectedTo.value!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Select Dates',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        final monthName = DateFormat('MMMM yyyy').format(displayedMonth.value);
        final daysInMonth = DateUtils.getDaysInMonth(displayedMonth.value.year, displayedMonth.value.month);
        final firstDayOfWeek = DateTime(displayedMonth.value.year, displayedMonth.value.month, 1).weekday % 7;

        final fromDate = selectedFrom.value;
        final toDate = selectedTo.value;
        final daysCount = calculateDays();

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Days header S M T W T F S
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _DayHeader('S'),
                        _DayHeader('M', isHighlighted: true),
                        _DayHeader('T'),
                        _DayHeader('W'),
                        _DayHeader('T'),
                        _DayHeader('F'),
                        _DayHeader('S'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Month Title Left-aligned
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Calendar Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: firstDayOfWeek + daysInMonth,
                      itemBuilder: (context, index) {
                        if (index < firstDayOfWeek) {
                          return const SizedBox.shrink();
                        }
                        final dayNumber = index - firstDayOfWeek + 1;
                        final date = DateTime(displayedMonth.value.year, displayedMonth.value.month, dayNumber);

                        final isFrom = isSameDay(date, fromDate);
                        final isTo = isSameDay(date, toDate);
                        final inRange = isInRange(date);
                        final isSelected = isFrom || isTo;

                        // Check if day is today or initial default outlined day
                        final isTodayOutline = fromDate == null && toDate == null && dayNumber == 27;

                        BoxDecoration cellDecoration;
                        if (isSelected) {
                          cellDecoration = const BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryPink,
                          );
                        } else if (inRange) {
                          cellDecoration = BoxDecoration(
                            color: primaryPink.withOpacity(0.12),
                            borderRadius: BorderRadius.horizontal(
                              left: isFrom ? const Radius.circular(20) : Radius.zero,
                              right: isTo ? const Radius.circular(20) : Radius.zero,
                            ),
                          );
                        } else if (isTodayOutline) {
                          cellDecoration = BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryPink, width: 1.5),
                          );
                        } else {
                          cellDecoration = const BoxDecoration();
                        }

                        // Special color for 31st or Sunday/highlighted days as shown in mockups
                        final isPinkText = dayNumber == 31;

                        return GestureDetector(
                          onTap: () => onDaySelected(date),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: cellDecoration,
                            alignment: Alignment.center,
                            child: Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected || isTodayOutline ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isPinkText ? primaryPink : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Bar & Next Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Check In
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Check In',
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fromDate != null
                                  ? DateFormat('d MMM, yyyy').format(fromDate)
                                  : 'Check In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: fromDate != null ? Colors.black87 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Day counter box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$daysCount',
                              style: const TextStyle(
                                color: primaryPink,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              daysCount == 1 ? 'Day' : 'Day',
                              style: const TextStyle(
                                color: primaryPink,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Check Out
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Check Out',
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              toDate != null
                                  ? DateFormat('d MMM, yyyy').format(toDate)
                                  : 'Check Out',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: toDate != null ? Colors.black87 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final from = selectedFrom.value ?? DateTime.now();
                        final to = selectedTo.value ?? from.add(const Duration(days: 2));
                        // Save dates without triggering search yet
                        controller.checkInDate.value = from;
                        controller.checkOutDate.value = to;
                        Get.back();
                        // Open guest picker next
                        Get.bottomSheet(
                          const GuestPickerSheet(),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String text;
  final bool isHighlighted;

  const _DayHeader(this.text, {this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: isHighlighted ? DateRangePickerSheet.primaryPink : Colors.grey.shade700,
        ),
      ),
    );
  }
}
