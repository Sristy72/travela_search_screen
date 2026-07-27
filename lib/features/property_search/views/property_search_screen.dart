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

  void _handleBackToLocationSearch(PropertySearchController controller) {
    controller.resetToInitialState();
    Get.to(() => const LocationSearchModal());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PropertySearchController());

    return Obx(() {
      final isViewingResults = controller.selectedLocation.value != null;

      return PopScope(
        canPop: !isViewingResults,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (isViewingResults) {
            _handleBackToLocationSearch(controller);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Top Search Header Bar (Pill Search Bar when Initial, or Detailed Header)
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
                        // Horizontal Filter Pills Row (including Date and Guest options)
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

                              // Render properties stream cards in real time with pull-to-refresh & pagination
                              return RefreshIndicator(
                                color: primaryPink,
                                onRefresh: () async {
                                  controller.searchProperties();
                                },
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (ScrollNotification scrollInfo) {
                                    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                                      controller.loadMoreProperties();
                                    }
                                    return false;
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: properties.length + (controller.isPageLoading.value ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == properties.length) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          child: Center(
                                            child: CircularProgressIndicator(color: primaryPink, strokeWidth: 2.5),
                                          ),
                                        );
                                      }

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
                                  ),
                                ),
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
        ),
      );
    });
  }

  Widget _buildSearchHeader(BuildContext context, PropertySearchController controller) {
    return Obx(() {
      final isInitialState = controller.searchState.value == PropertySearchState.initial &&
          controller.selectedLocation.value == null;

      if (isInitialState) {
        return _buildStartYourSearchBar(context, controller);
      }

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
                _handleBackToLocationSearch(controller);
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
                      final guests = controller.totalGuests > 0 ? '${controller.totalGuests} Guests' : 'Add guests';
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
          ],
        ),
      );
    });
  }

  /// Rounded Pill Search Bar ("Start your search") matching the screenshot
  Widget _buildStartYourSearchBar(BuildContext context, PropertySearchController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () {
            Get.to(() => const LocationSearchModal());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.search,
                  color: Colors.black87,
                  size: 26,
                ),
                SizedBox(width: 12),
                Text(
                  'Start your search',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Destinations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final locations = controller.locationSuggestions.isNotEmpty
                ? controller.locationSuggestions
                : PropertySearchController.defaultFallbackLocations;

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: locations.take(6).length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final loc = locations[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on_outlined, color: primaryPink, size: 20),
                  ),
                  title: Text(
                    loc.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Explore stays around ${loc.name}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: () {
                    controller.selectLocation(loc);
                    Get.to(() => const DateRangePickerSheet());
                  },
                );
              },
            );
          }),
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
