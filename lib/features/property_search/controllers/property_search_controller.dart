import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/base/base_controller.dart';
import '../models/location_model.dart';
import '../models/property_item_model.dart';
import '../models/search_filter_model.dart';
import '../models/search_meta_model.dart';
import '../services/property_search_service.dart';

enum PropertySearchState { initial, loading, empty, error, finished }

class PropertySearchController extends BaseController {
  final PropertySearchService _service = PropertySearchService();

  // Screen & Stream State
  final searchState = PropertySearchState.initial.obs;
  final properties = <PropertyItemModel>[].obs;
  final totalCount = 0.obs;
  final filterMeta = Rxn<Map<String, dynamic>>();
  final isStreamActive = false.obs;

  // Location Autocomplete State
  final locationQuery = ''.obs;
  final locationSuggestions = <LocationModel>[].obs;
  final isLocationsLoading = false.obs;
  final selectedLocation = Rxn<LocationModel>();

  // Filter Values
  final checkInDate = Rxn<DateTime>();
  final checkOutDate = Rxn<DateTime>();
  final adultsCount = 2.obs;
  final childCount = 0.obs;
  final infantCount = 0.obs;
  final minPrice = RxnDouble();
  final maxPrice = RxnDouble();
  final instantBookingOnly = false.obs;
  final minRating = RxnDouble();

  // Private stream client handle
  http.Client? _activeHttpClient;
  Timer? _debounceTimer;

  int get totalGuests => adultsCount.value + childCount.value + infantCount.value;

  String get dateRangeText {
    if (checkInDate.value == null || checkOutDate.value == null) {
      return 'Add dates';
    }
    final inDay = checkInDate.value!.day;
    final inMonth = _getMonthAbbr(checkInDate.value!.month);
    final outDay = checkOutDate.value!.day;
    final outMonth = _getMonthAbbr(checkOutDate.value!.month);

    if (checkInDate.value!.month == checkOutDate.value!.month) {
      return '$inDay - $outDay $inMonth';
    }
    return '$inDay $inMonth - $outDay $outMonth';
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1) % 12];
  }

  @override
  void onInit() {
    super.onInit();
    selectedLocation.value = null;
    locationQuery.value = '';

    // Set default dates (today to 2 days from now)
    final now = DateTime.now();
    checkInDate.value = now;
    checkOutDate.value = now.add(const Duration(days: 2));

    // Fetch initial location suggestions
    fetchPopularLocations('');
  }

  @override
  void onClose() {
    cancelActiveStream();
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Debounced location input handler
  void onLocationQueryChanged(String query) {
    locationQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      fetchPopularLocations(query);
    });
  }

  /// Fetch popular location suggestions from API
  Future<void> fetchPopularLocations(String query) async {
    try {
      isLocationsLoading.value = true;
      final results = await _service.fetchPopularLocations(query: query);
      locationSuggestions.value = results;
    } catch (e) {
      // Keep previous or empty suggestions gracefully
    } finally {
      isLocationsLoading.value = false;
    }
  }

  /// User selects a location from autocomplete suggestions
  void selectLocation(LocationModel location) {
    selectedLocation.value = location;
    locationQuery.value = location.name;
    locationSuggestions.clear();
    searchProperties();
  }

  /// User sets Check-In and Check-Out dates
  void setDates(DateTime from, DateTime to) {
    checkInDate.value = from;
    checkOutDate.value = to;
    searchProperties();
  }

  /// User sets guest counts
  void setGuests(int adults, int children, int infants) {
    adultsCount.value = adults;
    childCount.value = children;
    infantCount.value = infants;
    searchProperties();
  }

  /// User sets price range filter
  void setPriceRange(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;
    searchProperties();
  }

  /// Toggle instant booking filter
  void toggleInstantBooking() {
    instantBookingOnly.value = !instantBookingOnly.value;
    searchProperties();
  }

  /// Set minimum rating filter
  void setMinRating(double? rating) {
    if (minRating.value == rating) {
      minRating.value = null;
    } else {
      minRating.value = rating;
    }
    searchProperties();
  }

  /// Reset all filters to default
  void resetFilters() {
    minPrice.value = null;
    maxPrice.value = null;
    instantBookingOnly.value = false;
    minRating.value = null;
    searchProperties();
  }

  /// Cancels any currently active SSE stream connection
  void cancelActiveStream() {
    if (_activeHttpClient != null) {
      _activeHttpClient!.close();
      _activeHttpClient = null;
    }
    isStreamActive.value = false;
  }

  /// Initiates SSE search stream with current filter parameters
  void searchProperties() {
    // 1. Cancel previous stream if active
    cancelActiveStream();

    // 2. Reset list & total count, update state
    properties.clear();
    totalCount.value = 0;
    clearError();
    searchState.value = PropertySearchState.loading;
    isStreamActive.value = true;

    // 3. Build query parameters
    final filter = SearchFilterModel(
      location: selectedLocation.value,
      fromDate: checkInDate.value,
      toDate: checkOutDate.value,
      guest: totalGuests,
      child: childCount.value,
      infant: infantCount.value,
      minPrice: minPrice.value,
      maxPrice: maxPrice.value,
      instantBooking: instantBookingOnly.value ? true : null,
      minRating: minRating.value,
    );

    // 4. Open SSE line-by-line stream
    _activeHttpClient = _service.streamSearchResults(
      filter: filter,
      onEvent: (sseEvent) {
        switch (sseEvent.event) {
          case 'meta':
            _handleMetaEvent(sseEvent.data);
            break;
          case 'item':
            _handleItemEvent(sseEvent.data);
            break;
          case 'done':
            _handleDoneEvent();
            break;
          case 'error':
            _handleErrorEvent(sseEvent.data);
            break;
        }
      },
      onError: (error) {
        isStreamActive.value = false;
        if (properties.isEmpty) {
          setError(error.toString());
          searchState.value = PropertySearchState.error;
        } else {
          // If we already received cards, keep showing them
          searchState.value = PropertySearchState.finished;
        }
      },
      onDone: () {
        if (searchState.value == PropertySearchState.loading) {
          _handleDoneEvent();
        }
      },
    );
  }

  void _handleMetaEvent(dynamic data) {
    if (data is Map<String, dynamic>) {
      final meta = SearchMetaModel.fromJson(data);
      totalCount.value = meta.totalCount;
      filterMeta.value = meta.filterMeta;
    }
  }

  void _handleItemEvent(dynamic data) {
    if (data is Map<String, dynamic>) {
      final item = PropertyItemModel.fromJson(data);
      properties.add(item);
      // Immediately render card on arrival while maintaining loading/streaming state
      if (searchState.value == PropertySearchState.loading && properties.isNotEmpty) {
        // We stay in loading/streaming state so progress indicator can show
      }
    }
  }

  void _handleDoneEvent() {
    isStreamActive.value = false;
    if (properties.isEmpty) {
      searchState.value = PropertySearchState.empty;
    } else {
      searchState.value = PropertySearchState.finished;
    }
  }

  void _handleErrorEvent(dynamic data) {
    isStreamActive.value = false;
    final message = data is Map && data.containsKey('message')
        ? data['message'].toString()
        : 'Failed to fetch search results';
    if (properties.isEmpty) {
      setError(message);
      searchState.value = PropertySearchState.error;
    } else {
      searchState.value = PropertySearchState.finished;
    }
  }

  /// Retries search
  void retrySearch() {
    searchProperties();
  }
}
