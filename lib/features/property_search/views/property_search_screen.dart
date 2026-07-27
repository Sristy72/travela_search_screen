import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_search_controller.dart';
import '../widgets/date_range_picker_sheet.dart';
import '../widgets/filter_bar_widget.dart';
import '../widgets/guest_picker_sheet.dart';
import '../widgets/location_search_modal.dart';
import '../widgets/property_card_widget.dart';
import '../widgets/shimmer_loading_widget.dart';

class PropertySearchScreen extends StatelessWidget {
  const PropertySearchScreen({super.key});

  static const Color primaryPink = Color(0xFFE51D5A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PropertySearchController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Search Header Bar
            _buildSearchHeader(context, controller),
            const SizedBox(height: 8),

            // Obx body dependent on initial state vs active search
            Expanded(
              child: Obx(() {
                final state = controller.searchState.value;
                final properties = controller.properties;

                if (state == PropertySearchState.initial && properties.isEmpty) {
                  return _buildInitialSearchState(controller);
                }

                return Column(
                  children: [
                    // Horizontal Filter Pills Row
                    const FilterBarWidget(),
                    const SizedBox(height: 8),

                    // Live Stream Progress & Total Count Banner
                    _buildStreamStatusBanner(controller),

                    // Main Content Area (Cards / Loader / Empty / Error)
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (state == PropertySearchState.loading && properties.isEmpty) {
                            return const ShimmerLoadingWidget();
                          }

                          if (state == PropertySearchState.error && properties.isEmpty) {
                            return _buildErrorState(controller);
                          }

                          if (state == PropertySearchState.empty) {
                            return _buildEmptyState(controller);
                          }

                          // Render properties stream cards in real time as they land
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: properties.length,
                            itemBuilder: (context, index) {
                              final property = properties[index];
                              final days = controller.checkOutDate.value != null && controller.checkInDate.value != null
                                  ? controller.checkOutDate.value!.difference(controller.checkInDate.value!).inDays
                                  : 2;

                              return PropertyCardWidget(
                                key: ValueKey('prop_${property.id}'),
                                property: property,
                                totalDays: days > 0 ? days : 1,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, PropertySearchController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
            onPressed: () {
              if (Get.key.currentState?.canPop() ?? false) {
                Get.back();
              }
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.to(() => const LocationSearchModal());
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final locationName = controller.selectedLocation.value?.name ?? 'Search location';
                    return Text(
                      locationName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: controller.selectedLocation.value != null ? Colors.black87 : Colors.black45,
                      ),
                    );
                  }),
                  const SizedBox(height: 2),
                  Obx(() {
                    final dates = controller.dateRangeText;
                    final guests = '${controller.totalGuests} Guests';
                    return Text(
                      '$dates • $guests',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Date / Guest Quick Modals Trigger
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: Colors.black87, size: 20),
            onPressed: () {
              Get.to(() => const DateRangePickerSheet());
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87, size: 22),
            onPressed: () {
              Get.bottomSheet(const GuestPickerSheet());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreamStatusBanner(PropertySearchController controller) {
    return Obx(() {
      final isStreaming = controller.isStreamActive.value;
      final total = controller.totalCount.value;
      final currentCount = controller.properties.length;

      if (!isStreaming && total == 0 && controller.searchState.value == PropertySearchState.initial) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (total > 0) ...[
                  Text(
                    '$total stays ',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (isStreaming)
                    Text(
                      '($currentCount loaded...)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ] else if (isStreaming) ...[
                  const Text(
                    'Searching stays...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            if (isStreaming)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryPink,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildInitialSearchState(PropertySearchController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Tap the search bar to find hotels, apartments, and luxury stays.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(PropertySearchController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No properties found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search location, dates, or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => controller.resetFilters(),
              child: const Text('Reset Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(PropertySearchController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Unable to load property search results.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPink,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => controller.retrySearch(),
            ),
          ],
        ),
      ),
    );
  }
}
