import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/property_search_controller.dart';

class DateRangePickerSheet extends StatefulWidget {
  const DateRangePickerSheet({super.key});

  static const Color primaryPink = Color(0xFFE51D5A);

  @override
  State<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<DateRangePickerSheet> {
  late DateTime _displayedMonth;
  DateTime? _selectedFrom;
  DateTime? _selectedTo;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<PropertySearchController>();
    _selectedFrom = controller.checkInDate.value ?? DateTime.now();
    _selectedTo = controller.checkOutDate.value ?? DateTime.now().add(const Duration(days: 2));
    _displayedMonth = DateTime(_selectedFrom!.year, _selectedFrom!.month, 1);
  }

  int get _calculatedDays {
    if (_selectedFrom == null || _selectedTo == null) return 0;
    return _selectedTo!.difference(_selectedFrom!).inDays;
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      if (_selectedFrom == null || (_selectedFrom != null && _selectedTo != null)) {
        _selectedFrom = date;
        _selectedTo = null;
      } else if (_selectedFrom != null && _selectedTo == null) {
        if (date.isBefore(_selectedFrom!)) {
          _selectedFrom = date;
        } else if (date.isAtSameMomentAs(_selectedFrom!)) {
          _selectedTo = date.add(const Duration(days: 1));
        } else {
          _selectedTo = date;
        }
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime date) {
    if (_selectedFrom == null || _selectedTo == null) return false;
    return date.isAfter(_selectedFrom!) && date.isBefore(_selectedTo!);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertySearchController>();
    final monthName = DateFormat('MMMM yyyy').format(_displayedMonth);

    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final firstDayOfWeek = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
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
      body: Column(
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
                  const SizedBox(height: 16),

                  // Month Header & Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        monthName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              setState(() {
                                _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Calendar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: firstDayOfWeek + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < firstDayOfWeek) {
                        return const SizedBox.shrink();
                      }
                      final dayNumber = index - firstDayOfWeek + 1;
                      final date = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);

                      final isFrom = _selectedFrom != null && _isSameDay(date, _selectedFrom!);
                      final isTo = _selectedTo != null && _isSameDay(date, _selectedTo!);
                      final inRange = _isInRange(date);

                      final isSelected = isFrom || isTo;

                      return GestureDetector(
                        onTap: () => _onDaySelected(date),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? DateRangePickerSheet.primaryPink
                                : (inRange ? DateRangePickerSheet.primaryPink.withOpacity(0.15) : Colors.transparent),
                            border: isFrom || isTo
                                ? Border.all(color: DateRangePickerSheet.primaryPink, width: 2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : (date.weekday == DateTime.sunday ? DateRangePickerSheet.primaryPink : Colors.black87),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Check In
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Check In', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          _selectedFrom != null ? DateFormat('d MMM').format(_selectedFrom!) : 'Check In',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),

                    // Day counter box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_calculatedDays',
                            style: const TextStyle(
                              color: DateRangePickerSheet.primaryPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            'Days',
                            style: TextStyle(
                              color: DateRangePickerSheet.primaryPink,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Check Out
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Check Out', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          _selectedTo != null ? DateFormat('d MMM').format(_selectedTo!) : 'Check Out',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
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
                      backgroundColor: DateRangePickerSheet.primaryPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_selectedFrom != null && _selectedTo != null) {
                        controller.setDates(_selectedFrom!, _selectedTo!);
                        Get.back();
                      }
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
      ),
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
