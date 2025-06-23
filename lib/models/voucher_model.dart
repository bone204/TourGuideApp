class VoucherModel {
  final String voucherId;
  final String billingMin;
  final int number;
  final String timeStart;
  final int value;
  final int voucherTerm;
  final int usedCount;
  final bool isActive;

  VoucherModel({
    required this.voucherId,
    required this.billingMin,
    required this.number,
    required this.timeStart,
    required this.value,
    required this.voucherTerm,
    this.usedCount = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'voucherId': voucherId,
      'billingMin': billingMin,
      'number': number,
      'timeStart': timeStart,
      'value': value,
      'voucherTerm': voucherTerm,
      'usedCount': usedCount,
      'isActive': isActive,
    };
  }

  factory VoucherModel.fromMap(Map<String, dynamic> map) {
    return VoucherModel(
      voucherId: map['voucherId'] ?? '',
      billingMin: map['billingMin'] ?? '',
      number: map['number'] ?? 0,
      timeStart: map['timeStart'] ?? '',
      value: map['value'] ?? 0,
      voucherTerm: map['voucherTerm'] ?? 0,
      usedCount: map['usedCount'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  // Tính số lượng voucher còn lại
  int get remainingCount => number - usedCount;

  // Tính phần trăm đã sử dụng
  double get usedPercentage => number > 0 ? (usedCount / number) * 100 : 0;

  // Kiểm tra voucher có thể sử dụng không
  bool canUse(double totalAmount) {
    if (!isActive) return false;
    if (remainingCount <= 0) return false;

    final minAmount = double.tryParse(billingMin) ?? 0;
    return totalAmount >= minAmount;
  }

  // Tính thời gian còn lại (giờ)
  int getRemainingHours() {
    try {
      final startDate = DateTime.parse(timeStart);
      final endDate = startDate.add(Duration(hours: voucherTerm));
      final now = DateTime.now();

      if (now.isAfter(endDate)) return 0;

      return endDate.difference(now).inHours;
    } catch (e) {
      return 0;
    }
  }

  // Tính số tiền được giảm
  double calculateDiscount(double totalAmount) {
    return (totalAmount * value) / 100;
  }

  // Tạo voucher mẫu
  static List<VoucherModel> getSampleVouchers() {
    return [
      VoucherModel(
        voucherId: 'VCH001',
        billingMin: '500000',
        number: 4,
        timeStart: '2025-06-24T00:00:00.000Z',
        value: 10,
        voucherTerm: 24,
        usedCount: 1,
      ),
      VoucherModel(
        voucherId: 'VCH002',
        billingMin: '1000000',
        number: 2,
        timeStart: '2025-06-25T00:00:00.000Z',
        value: 15,
        voucherTerm: 48,
        usedCount: 0,
      ),
      VoucherModel(
        voucherId: 'VCH003',
        billingMin: '300000',
        number: 6,
        timeStart: '2025-06-23T00:00:00.000Z',
        value: 5,
        voucherTerm: 12,
        usedCount: 3,
      ),
    ];
  }
}
