class BusBookingState {
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final bool isLoadingUserData;
  final String? error;
  final String fromLocation;
  final String toLocation;
  final Map<String, String> fromLocationDetails;
  final Map<String, String> toLocationDetails;

  BusBookingState({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.isLoadingUserData = false,
    this.error,
    this.fromLocation = '',
    this.toLocation = '',
    this.fromLocationDetails = const {},
    this.toLocationDetails = const {},
  });

  BusBookingState copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? isLoadingUserData,
    String? error,
    String? fromLocation,
    String? toLocation,
    Map<String, String>? fromLocationDetails,
    Map<String, String>? toLocationDetails,
  }) {
    return BusBookingState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoadingUserData: isLoadingUserData ?? this.isLoadingUserData,
      error: error,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      fromLocationDetails: fromLocationDetails ?? this.fromLocationDetails,
      toLocationDetails: toLocationDetails ?? this.toLocationDetails,
    );
  }

  @override
  String toString() {
    return 'BusBookingState(fullName: $fullName, email: $email, phoneNumber: $phoneNumber, isLoadingUserData: $isLoadingUserData, error: $error)';
  }
} 