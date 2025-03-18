class BusBookingState {
  final String fromLocation;
  final Map<String, dynamic> fromLocationDetails;
  final String toLocation;
  final Map<String, dynamic> toLocationDetails;
  final bool isSearching;
  final List<dynamic> searchResults;
  final String? error;

  BusBookingState({
    this.fromLocation = '',
    this.fromLocationDetails = const {},
    this.toLocation = '',
    this.toLocationDetails = const {},
    this.isSearching = false,
    this.searchResults = const [],
    this.error,
  });

  BusBookingState copyWith({
    String? fromLocation,
    Map<String, dynamic>? fromLocationDetails,
    String? toLocation,
    Map<String, dynamic>? toLocationDetails,
    bool? isSearching,
    List<dynamic>? searchResults,
    String? error,
  }) {
    return BusBookingState(
      fromLocation: fromLocation ?? this.fromLocation,
      fromLocationDetails: fromLocationDetails ?? this.fromLocationDetails,
      toLocation: toLocation ?? this.toLocation,
      toLocationDetails: toLocationDetails ?? this.toLocationDetails,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
      error: error,
    );
  }
} 