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
  final adultsCount = 0.obs;
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
    checkInDate.value = null;
    checkOutDate.value = null;
    searchState.value = PropertySearchState.initial;

    // Fetch initial location suggestions
    fetchPopularLocations('');
  }

  @override
  void onClose() {
    cancelActiveStream();
    _debounceTimer?.cancel();
    super.onClose();
  }

  static final List<LocationModel> defaultFallbackLocations = [
    LocationModel(id: 1, name: 'Bashundhara Resedential Area', lat: 23.8103, lng: 90.4312),
    LocationModel(id: 2, name: 'Dhanmondi', lat: 23.7461, lng: 90.3742),
    LocationModel(id: 3, name: 'Mohammadpur', lat: 23.7658, lng: 90.3582),
    LocationModel(id: 4, name: 'Green City, Mohammadpur', lat: 23.7670, lng: 90.3590),
    LocationModel(id: 5, name: 'Mirpur', lat: 23.8068, lng: 90.3687),
    LocationModel(id: 6, name: 'Mirpur 10', lat: 23.8069, lng: 90.3688),
    LocationModel(id: 7, name: 'Mirpur-13, Dhaka, Bangladesh', lat: 23.8130, lng: 90.3750),
    LocationModel(id: 8, name: 'Mirpur-1, Dhaka', lat: 23.7950, lng: 90.3530),
    LocationModel(id: 9, name: 'Mirpur-10, Dhaka', lat: 23.8069, lng: 90.3688),
    LocationModel(id: 10, name: 'Mirpur-1', lat: 23.7950, lng: 90.3530),
    LocationModel(id: 11, name: 'Mirpur - 60 Feet', lat: 23.7880, lng: 90.3650),
    LocationModel(id: 12, name: 'Mirpur Dohs, Dhaka', lat: 23.8290, lng: 90.3700),
    LocationModel(id: 13, name: 'Mirpur 12, Dhaka, Bangladesh', lat: 23.8240, lng: 90.3650),
    LocationModel(id: 14, name: 'Mirpur 14, Dhaka, Bangladesh', lat: 23.8080, lng: 90.3860),
    LocationModel(id: 15, name: 'Mirpur - 60 Fit', lat: 23.7880, lng: 90.3650),
    LocationModel(id: 16, name: 'Mirpur 11, Dhaka, Bangladesh', lat: 23.8150, lng: 90.3660),
    LocationModel(id: 17, name: 'Mirpur 11', lat: 23.8150, lng: 90.3660),
    LocationModel(id: 18, name: 'Dhanmondi West', lat: 23.7450, lng: 90.3690),
    LocationModel(id: 19, name: 'Dhanmondi North', lat: 23.7550, lng: 90.3780),
    LocationModel(id: 20, name: 'Gulshan, Dhaka', lat: 23.7925, lng: 90.4167),
    LocationModel(id: 21, name: 'Dhaka', lat: 23.8103, lng: 90.4125),
    LocationModel(id: 22, name: 'Bashundhara Block C', lat: 23.8120, lng: 90.4330),
    LocationModel(id: 23, name: 'Panthapath', lat: 23.7510, lng: 90.3870),
    LocationModel(id: 24, name: 'Aftab Nagar', lat: 23.7680, lng: 90.4300),
  ];

  /// Debounced location input handler
  void onLocationQueryChanged(String query) {
    locationQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      fetchPopularLocations(query);
    });
  }

  /// Fetch popular location suggestions
  Future<void> fetchPopularLocations(String query) async {
    try {
      isLocationsLoading.value = true;
      final results = await _service.fetchPopularLocations(query: query);
      if (results.isNotEmpty) {
        locationSuggestions.value = results;
      } else {
        _applyFallbackLocations(query);
      }
    } catch (e) {
      _applyFallbackLocations(query);
    } finally {
      isLocationsLoading.value = false;
    }
  }

  void _applyFallbackLocations(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      locationSuggestions.value = defaultFallbackLocations;
    } else {
      locationSuggestions.value = defaultFallbackLocations
          .where((loc) => loc.name.toLowerCase().contains(q))
          .toList();
    }
  }

  /// User selects a location from autocomplete suggestions
  void selectLocation(LocationModel location) {
    selectedLocation.value = location;
    locationQuery.value = location.name;
  }

  /// Resets controller state back to initial 'Start your search' screen
  void resetToInitialState() {
    cancelActiveStream();
    selectedLocation.value = null;
    locationQuery.value = '';
    checkInDate.value = null;
    checkOutDate.value = null;
    adultsCount.value = 0;
    childCount.value = 0;
    infantCount.value = 0;
    minPrice.value = null;
    maxPrice.value = null;
    instantBookingOnly.value = false;
    minRating.value = null;
    searchState.value = PropertySearchState.initial;
    properties.clear();
    totalCount.value = 0;
    nextPageUrl.value = null;
    _applyFallbackLocations('');
    fetchPopularLocations('');
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

  // Pagination State
  final paginationMeta = Rxn<Map<String, dynamic>>();
  final nextPageUrl = RxnString();
  final isPageLoading = false.obs;

  void _handleMetaEvent(dynamic data) {
    if (data is Map<String, dynamic>) {
      final meta = SearchMetaModel.fromJson(data);
      totalCount.value = meta.totalCount;
      filterMeta.value = meta.filterMeta;
      paginationMeta.value = meta.pagination;
      if (meta.pagination != null && meta.pagination!['next'] != null) {
        nextPageUrl.value = meta.pagination!['next'].toString();
      }
    }
  }

  /// Load next page of results using pagination.next URL
  Future<void> loadMoreProperties() async {
    final nextUrl = nextPageUrl.value;
    if (nextUrl == null || nextUrl.isEmpty || isPageLoading.value) return;

    try {
      isPageLoading.value = true;
      final newProperties = await _service.fetchNextPage(nextUrl);
      if (newProperties.isNotEmpty) {
        properties.addAll(newProperties);
      }
      nextPageUrl.value = null; // Clear to prevent duplicated fetches
    } finally {
      isPageLoading.value = false;
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
