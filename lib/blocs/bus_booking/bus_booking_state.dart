class BusBookingState {
  final String fromLocation;
  final String toLocation;
  final Map<String, String> fromLocationDetails;
  final Map<String, String> toLocationDetails;
  final bool isSearching;
  final List<dynamic> searchResults;
  final String? error;

  BusBookingState({
    this.fromLocation = '',
    this.toLocation = '',
    this.fromLocationDetails = const {},
    this.toLocationDetails = const {},
    this.isSearching = false,
    this.searchResults = const [],
    this.error,
  });

  BusBookingState copyWith({
    String? fromLocation,
    String? toLocation,
    Map<String, String>? fromLocationDetails,
    Map<String, String>? toLocationDetails,
    bool? isSearching,
    List<dynamic>? searchResults,
    String? error,
  }) {
    return BusBookingState(
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      fromLocationDetails: fromLocationDetails ?? this.fromLocationDetails,
      toLocationDetails: toLocationDetails ?? this.toLocationDetails,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
      error: error,
    );
  }
} 