import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/hotel_bill_model.dart';
import 'package:tourguideapp/models/restaurant_bill_model.dart';
import 'package:tourguideapp/core/services/notification_service.dart';

class UsedServicesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Thêm dịch vụ đã sử dụng vào danh sách
  Future<void> addUsedService({
    required String userId,
    required String serviceType,
    required String serviceName,
    required String serviceId,
    required DateTime usedDate,
    required double amount,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Kiểm tra xem service đã tồn tại chưa để tránh duplicate
      final existingService = await _firestore
          .collection('USED_SERVICES')
          .where('userId', isEqualTo: userId)
          .where('serviceType', isEqualTo: serviceType)
          .where('serviceId', isEqualTo: serviceId)
          .limit(1)
          .get();

      if (existingService.docs.isNotEmpty) {
        print('Service already exists, skipping duplicate: $serviceId');
        return;
      }

      await _firestore.collection('USED_SERVICES').add({
        'userId': userId,
        'serviceType': serviceType, // 'hotel', 'bus', 'eatery', etc.
        'serviceName': serviceName,
        'serviceId': serviceId,
        'usedDate': usedDate.toIso8601String(),
        'amount': amount,
        'status': status,
        'additionalData': additionalData ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Gửi thông báo cho user
      await _sendServiceNotification(
        userId: userId,
        serviceType: serviceType,
        serviceName: serviceName,
        serviceId: serviceId,
        amount: amount,
        additionalData: additionalData,
      );
    } catch (e) {
      print('Error adding used service: $e');
      throw Exception('Không thể thêm dịch vụ đã sử dụng: $e');
    }
  }

  // Gửi thông báo cho service
  Future<void> _sendServiceNotification({
    required String userId,
    required String serviceType,
    required String serviceName,
    required String serviceId,
    required double amount,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      String title = '';
      String body = '';

      switch (serviceType) {
        case 'hotel':
          title = 'Đặt phòng khách sạn thành công!';
          body = 'Bạn đã đặt phòng thành công với giá ${_formatCurrency(amount)}. Kiểm tra email để biết thêm chi tiết.';
          break;
        case 'restaurant':
          title = 'Đặt bàn nhà hàng thành công!';
          body = 'Bạn đã đặt bàn thành công với giá ${_formatCurrency(amount)}. Vui lòng đến đúng giờ!';
          break;
        case 'delivery':
          title = 'Đơn giao hàng đã được tạo!';
          body = 'Đơn giao hàng của bạn đã được tạo với giá ${_formatCurrency(amount)}. Chúng tôi sẽ cập nhật trạng thái sớm nhất.';
          break;
        case 'bus':
          title = 'Đặt vé xe buýt thành công!';
          body = 'Bạn đã đặt vé xe buýt thành công với giá ${_formatCurrency(amount)}. Vui lòng đến bến xe đúng giờ!';
          break;
        case 'car_rental':
          title = 'Thuê xe thành công!';
          body = 'Bạn đã thuê xe thành công với giá ${_formatCurrency(amount)}. Vui lòng đến địa điểm nhận xe đúng giờ!';
          break;
        case 'motorbike_rental':
          title = 'Thuê xe máy thành công!';
          body = 'Bạn đã thuê xe máy thành công với giá ${_formatCurrency(amount)}. Vui lòng đến địa điểm nhận xe đúng giờ!';
          break;
        default:
          title = 'Dịch vụ mới!';
          body = 'Bạn đã sử dụng dịch vụ ${serviceName} với giá ${_formatCurrency(amount)}.';
      }

      await _notificationService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        serviceType: serviceType,
        serviceId: serviceId,
        serviceName: serviceName,
        additionalData: additionalData,
      );
    } catch (e) {
      print('Error sending service notification: $e');
    }
  }

  // Format tiền tệ
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} VNĐ';
  }

  // Thêm hotel booking vào used services
  Future<void> addHotelBookingToUsedServices(HotelBillModel booking) async {
    try {
      await addUsedService(
        userId: booking.userId,
        serviceType: 'hotel',
        serviceName: 'Đặt phòng khách sạn', // Tên dịch vụ chung
        serviceId: booking.billId,
        usedDate: DateTime.parse(booking.checkInDate),
        amount: booking.total,
        status: booking.status,
        additionalData: {
          'checkInDate': booking.checkInDate,
          'checkOutDate': booking.checkOutDate,
          'numberOfRooms': booking.numberOfRooms,
          'roomIds': booking.roomIds,
          'voucherId': booking.voucherId,
          'travelPointsUsed': booking.travelPointsUsed,
        },
      );
    } catch (e) {
      print('Error adding hotel booking to used services: $e');
      throw Exception('Không thể thêm đặt phòng vào dịch vụ đã sử dụng: $e');
    }
  }

  // Thêm restaurant booking vào used services
  Future<void> addRestaurantBookingToUsedServices(
      RestaurantBillModel booking) async {
    try {
      await addUsedService(
        userId: booking.userId,
        serviceType: 'restaurant',
        serviceName: 'Đặt bàn nhà hàng', // Tên dịch vụ chung
        serviceId: booking.billId,
        usedDate: booking.checkInDate,
        amount: booking.totalPrice,
        status: booking.status,
        additionalData: {
          'checkInDate': booking.checkInDate.toIso8601String(),
          'checkInTime':
              '${booking.checkInTime.hour}:${booking.checkInTime.minute.toString().padLeft(2, '0')}',
          'numberOfPeople': booking.numberOfPeople,
          'tableId': booking.tableId,
          'restaurantId': booking.restaurantId,
          'customerName': booking.customerName,
          'customerPhone': booking.customerPhone,
          'notes': booking.notes,
        },
      );
    } catch (e) {
      print('Error adding restaurant booking to used services: $e');
      throw Exception('Không thể thêm đặt bàn vào dịch vụ đã sử dụng: $e');
    }
  }

  // Thêm delivery order vào used services
  Future<void> addDeliveryOrderToUsedServices({
    required String userId,
    required String orderId,
    required String deliveryBrandName,
    required String selectedVehicle,
    required String pickupLocation,
    required String deliveryLocation,
    required String recipientName,
    required String recipientPhone,
    required String senderName,
    required String senderPhone,
    required String requirements,
    required double amount,
    required List<String> packagePhotos,
    required String status,
  }) async {
    try {
      await addUsedService(
        userId: userId,
        serviceType: 'delivery',
        serviceName: 'Dịch vụ giao hàng', // Sẽ được translate trong UI
        serviceId: orderId,
        usedDate: DateTime.now(),
        amount: amount,
        status: status,
        additionalData: {
          'deliveryBrandName': deliveryBrandName,
          'selectedVehicle': selectedVehicle,
          'pickupLocation': pickupLocation,
          'deliveryLocation': deliveryLocation,
          'recipientName': recipientName,
          'recipientPhone': recipientPhone,
          'senderName': senderName,
          'senderPhone': senderPhone,
          'requirements': requirements,
          'packagePhotos': packagePhotos,
          'orderDate': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error adding delivery order to used services: $e');
      throw Exception('Không thể thêm đơn giao hàng vào dịch vụ đã sử dụng: $e');
    }
  }

  // Thêm bus booking vào used services
  Future<void> addBusBookingToUsedServices({
    required String userId,
    required String orderId,
    required String fromLocation,
    required String toLocation,
    required DateTime departureDate,
    DateTime? returnDate,
    required String passengerName,
    required String passengerEmail,
    required String passengerPhone,
    required List<String> departureSelectedSeats,
    required List<String> returnSelectedSeats,
    required String departurePickupStation,
    required String departureDropStation,
    String? returnPickupStation,
    String? returnDropStation,
    required double amount,
    required String status,
  }) async {
    try {
      // Tính thông tin tuyến đường
      final routeInfo = _getRouteInfo(fromLocation, toLocation);
      
      await addUsedService(
        userId: userId,
        serviceType: 'bus',
        serviceName: 'Mua vé xe', // Sẽ được translate trong UI
        serviceId: orderId,
        usedDate: departureDate,
        amount: amount,
        status: status,
        additionalData: {
          'fromLocation': fromLocation,
          'toLocation': toLocation,
          'departureDate': departureDate.toIso8601String(),
          'returnDate': returnDate?.toIso8601String(),
          'passengerName': passengerName,
          'passengerEmail': passengerEmail,
          'passengerPhone': passengerPhone,
          'departureSelectedSeats': departureSelectedSeats,
          'returnSelectedSeats': returnSelectedSeats,
          'departurePickupStation': departurePickupStation,
          'departureDropStation': departureDropStation,
          'returnPickupStation': returnPickupStation,
          'returnDropStation': returnDropStation,
          'orderDate': DateTime.now().toIso8601String(),
          'totalSeats': departureSelectedSeats.length + returnSelectedSeats.length,
          'isRoundTrip': returnDate != null,
          'busCompany': 'Phương Trang - Futa Bus Lines',
          'busType': 'Limousine',
          'estimatedDuration': routeInfo['duration'],
          'departureTime': routeInfo['departureTime'],
          'arrivalTime': routeInfo['arrivalTime'],
          'pricePerSeat': routeInfo['pricePerSeat'],
        },
      );
      
      print('Bus booking added to used services: $orderId');
    } catch (e) {
      print('Error adding bus booking to used services: $e');
      throw Exception('Không thể thêm đặt vé xe buýt vào dịch vụ đã sử dụng: $e');
    }
  }

  // Thêm car rental vào used services
  Future<void> addCarRentalToUsedServices({
    required String userId,
    required String rentalId,
    required String carModel,
    required String carBrand,
    required DateTime pickupDate,
    required DateTime returnDate,
    required String pickupLocation,
    required String returnLocation,
    required double amount,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await addUsedService(
        userId: userId,
        serviceType: 'car_rental',
        serviceName: 'Thuê xe ô tô',
        serviceId: rentalId,
        usedDate: pickupDate,
        amount: amount,
        status: status,
        additionalData: {
          'carModel': carModel,
          'carBrand': carBrand,
          'pickupDate': pickupDate.toIso8601String(),
          'returnDate': returnDate.toIso8601String(),
          'pickupLocation': pickupLocation,
          'returnLocation': returnLocation,
          'rentalDays': returnDate.difference(pickupDate).inDays,
          ...?additionalData,
        },
      );
    } catch (e) {
      print('Error adding car rental to used services: $e');
      throw Exception('Không thể thêm thuê xe vào dịch vụ đã sử dụng: $e');
    }
  }

  // Thêm motorbike rental vào used services
  Future<void> addMotorbikeRentalToUsedServices({
    required String userId,
    required String rentalId,
    required String motorbikeModel,
    required String motorbikeBrand,
    required DateTime pickupDate,
    required DateTime returnDate,
    required String pickupLocation,
    required String returnLocation,
    required double amount,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await addUsedService(
        userId: userId,
        serviceType: 'motorbike_rental',
        serviceName: 'Thuê xe máy',
        serviceId: rentalId,
        usedDate: pickupDate,
        amount: amount,
        status: status,
        additionalData: {
          'motorbikeModel': motorbikeModel,
          'motorbikeBrand': motorbikeBrand,
          'pickupDate': pickupDate.toIso8601String(),
          'returnDate': returnDate.toIso8601String(),
          'pickupLocation': pickupLocation,
          'returnLocation': returnLocation,
          'rentalDays': returnDate.difference(pickupDate).inDays,
          ...?additionalData,
        },
      );
    } catch (e) {
      print('Error adding motorbike rental to used services: $e');
      throw Exception('Không thể thêm thuê xe máy vào dịch vụ đã sử dụng: $e');
    }
  }

  // Phương thức để lấy thông tin tuyến đường
  Map<String, dynamic> _getRouteInfo(String fromLocation, String toLocation) {
    final routeInfo = {
      'Ho Chi Minh City': {
        'Dak Lak': {
          'departureTime': '22:00',
          'arrivalTime': '06:05',
          'duration': '8 giờ 5 phút',
          'pricePerSeat': 285000,
        },
        'Da Lat': {
          'departureTime': '20:00',
          'arrivalTime': '04:30',
          'duration': '8 giờ 30 phút',
          'pricePerSeat': 320000,
        },
        'Nha Trang': {
          'departureTime': '21:00',
          'arrivalTime': '05:00',
          'duration': '8 giờ',
          'pricePerSeat': 280000,
        },
      },
      'Dak Lak': {
        'Ho Chi Minh City': {
          'departureTime': '20:00',
          'arrivalTime': '04:05',
          'duration': '8 giờ 5 phút',
          'pricePerSeat': 285000,
        },
      },
      'Da Lat': {
        'Ho Chi Minh City': {
          'departureTime': '18:00',
          'arrivalTime': '02:30',
          'duration': '8 giờ 30 phút',
          'pricePerSeat': 320000,
        },
      },
      'Nha Trang': {
        'Ho Chi Minh City': {
          'departureTime': '19:00',
          'arrivalTime': '03:00',
          'duration': '8 giờ',
          'pricePerSeat': 280000,
        },
      },
    };

    final fromInfo = routeInfo[fromLocation];
    if (fromInfo != null && fromInfo[toLocation] != null) {
      return fromInfo[toLocation]!;
    }

    // Thông tin mặc định
    return {
      'departureTime': '22:00',
      'arrivalTime': '06:05',
      'duration': '8 giờ 5 phút',
      'pricePerSeat': 285000,
    };
  }

  // Lấy danh sách dịch vụ đã sử dụng của user
  Future<List<Map<String, dynamic>>> getUsedServicesByUserId(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('USED_SERVICES')
          .where('userId', isEqualTo: userId)
          .orderBy('usedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error fetching used services: $e');
      return [];
    }
  }

  // Lấy danh sách dịch vụ đã sử dụng theo loại
  Future<List<Map<String, dynamic>>> getUsedServicesByType(
      String userId, String serviceType) async {
    try {
      final snapshot = await _firestore
          .collection('USED_SERVICES')
          .where('userId', isEqualTo: userId)
          .where('serviceType', isEqualTo: serviceType)
          .orderBy('usedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error fetching used services by type: $e');
      return [];
    }
  }

  // Lấy dịch vụ đã sử dụng theo userId, serviceType, serviceId
  Future<Map<String, dynamic>?> getUsedServiceByTypeAndId(
      String userId, String serviceType, String serviceId) async {
    try {
      final snapshot = await _firestore
          .collection('USED_SERVICES')
          .where('userId', isEqualTo: userId)
          .where('serviceType', isEqualTo: serviceType)
          .where('serviceId', isEqualTo: serviceId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return {
          'id': snapshot.docs.first.id,
          ...snapshot.docs.first.data(),
        };
      }
      return null;
    } catch (e) {
      print('Error fetching used service by type and id: $e');
      return null;
    }
  }

  // Cập nhật trạng thái dịch vụ đã sử dụng
  Future<void> updateUsedServiceStatus(String serviceId, String status) async {
    try {
      await _firestore
          .collection('USED_SERVICES')
          .doc(serviceId)
          .update({'status': status});
    } catch (e) {
      print('Error updating used service status: $e');
      throw Exception('Không thể cập nhật trạng thái: $e');
    }
  }

  // Xóa dịch vụ đã sử dụng theo id
  Future<void> deleteUsedServiceById(String serviceId) async {
    try {
      await _firestore.collection('USED_SERVICES').doc(serviceId).delete();
    } catch (e) {
      print('Error deleting used service: $e');
      throw Exception('Không thể xóa dịch vụ đã sử dụng: $e');
    }
  }
}
