import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/hotel_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/models/room_availability_model.dart';
import 'package:tourguideapp/core/services/hotel_service.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/views/service/hotel/hotel_detail_screen.dart';

class HotelListScreen extends StatefulWidget {
  final Map<String, dynamic>? searchParams;

  const HotelListScreen({super.key, this.searchParams});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  final HotelService _hotelService = HotelService();
  List<CooperationModel> hotels = [];
  List<CooperationModel> filteredHotels = [];
  Map<String, List<RoomAvailabilityModel>> hotelAvailability = {};
  bool isLoading = true;
  String? selectedProvince;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int? numberOfGuests;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Lấy thông tin tìm kiếm từ searchParams
      selectedProvince = widget.searchParams?['province'] as String?;
      checkInDate = widget.searchParams?['checkInDate'] as DateTime?;
      checkOutDate = widget.searchParams?['checkOutDate'] as DateTime?;
      numberOfGuests = widget.searchParams?['guests'] as int?;

      if (selectedProvince != null && selectedProvince!.isNotEmpty) {
        // Lọc theo tỉnh từ database
        hotels = await _hotelService.getHotelsByProvince(selectedProvince!);
      } else {
        // Nếu không có tỉnh, sử dụng dữ liệu mẫu
        hotels = _getSampleHotels();
      }

      // Kiểm tra phòng trống cho từng khách sạn
      await _checkHotelsAvailability();

      // Lọc theo budget nếu có
      if (widget.searchParams != null) {
        double minBudget = widget.searchParams!['minBudget'] as double? ?? 0;
        double maxBudget =
            widget.searchParams!['maxBudget'] as double? ?? double.infinity;

        filteredHotels = hotels.where((hotel) {
          // Kiểm tra xem khách sạn có phòng trống không
          final availability = hotelAvailability[hotel.cooperationId];
          if (availability == null || availability.isEmpty) return false;

          // Kiểm tra có phòng nào phù hợp với budget không
          bool hasAffordableRoom = availability.any((room) {
            return room.price >= minBudget && room.price <= maxBudget;
          });

          return hasAffordableRoom;
        }).toList();
      } else {
        // Chỉ hiển thị khách sạn có phòng trống
        filteredHotels = hotels.where((hotel) {
          final availability = hotelAvailability[hotel.cooperationId];
          return availability != null && availability.isNotEmpty;
        }).toList();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading hotels: $e');
      setState(() {
        isLoading = false;
        filteredHotels = _getSampleHotels();
      });
    }
  }

  Future<void> _checkHotelsAvailability() async {
    if (checkInDate == null || checkOutDate == null) return;

    for (final hotel in hotels) {
      try {
        final availability = await _hotelService.checkRoomAvailability(
          hotelId: hotel.cooperationId,
          checkInDate: checkInDate!,
          checkOutDate: checkOutDate!,
        );

        hotelAvailability[hotel.cooperationId] = availability;
      } catch (e) {
        print(
            'Error checking availability for hotel ${hotel.cooperationId}: $e');
        hotelAvailability[hotel.cooperationId] = [];
      }
    }
  }

  // Dữ liệu mẫu cho khách sạn
  List<CooperationModel> _getSampleHotels() {
    return [
      CooperationModel(
        cooperationId: 'H00001',
        name: 'Rex Hotel Saigon',
        type: 'hotel',
        numberOfObjects: 0,
        numberOfObjectTypes: 0,
        latitude: 0,
        longitude: 0,
        bossName: 'Nguyen Van A',
        bossPhone: '0901234567',
        bossEmail: 'rex@hotel.com',
        address: '141 Nguyễn Huệ, Bến Nghé, Quận 1, TP.HCM',
        district: 'Quận 1',
        city: 'Hồ Chí Minh',
        province: 'TP.HCM',
        photo: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400',
        extension: '',
        introduction: 'Khách sạn 5 sao trung tâm Sài Gòn.',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 120,
        revenue: 150000000,
        averageRating: 4.5,
      ),
      CooperationModel(
        cooperationId: 'H00002',
        name: 'Caravelle Saigon',
        type: 'hotel',
        numberOfObjects: 0,
        numberOfObjectTypes: 0,
        latitude: 0,
        longitude: 0,
        bossName: 'Tran Thi B',
        bossPhone: '0912345678',
        bossEmail: 'caravelle@hotel.com',
        address: '19 Lam Sơn, Bến Nghé, Quận 1, TP.HCM',
        district: 'Quận 1',
        city: 'Hồ Chí Minh',
        province: 'TP.HCM',
        photo: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400',
        extension: '',
        introduction: 'Khách sạn sang trọng với hồ bơi ngoài trời.',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 98,
        revenue: 120000000,
        averageRating: 4.0,
      ),
      CooperationModel(
        cooperationId: 'H00003',
        name: 'InterContinental Saigon',
        type: 'hotel',
        numberOfObjects: 0,
        numberOfObjectTypes: 0,
        latitude: 0,
        longitude: 0,
        bossName: 'Le Van C',
        bossPhone: '0923456789',
        bossEmail: 'icsaigon@hotel.com',
        address: 'Corner of Hai Ba Trung St. & Le Duan Blvd, District 1, TP.HCM',
        district: 'Quận 1',
        city: 'Hồ Chí Minh',
        province: 'TP.HCM',
        photo: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400',
        extension: '',
        introduction: 'Khách sạn quốc tế, dịch vụ đẳng cấp.',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 150,
        revenue: 200000000,
        averageRating: 5.0,
      ),
      CooperationModel(
        cooperationId: 'H00004',
        name: 'Hanoi Pearl Hotel',
        type: 'hotel',
        numberOfObjects: 0,
        numberOfObjectTypes: 0,
        latitude: 0,
        longitude: 0,
        bossName: 'Pham Thi D',
        bossPhone: '0934567890',
        bossEmail: 'pearl@hotel.com',
        address: '6 Bao Khanh Lane, Hoan Kiem, Hà Nội',
        district: 'Hoàn Kiếm',
        city: 'Hà Nội',
        province: 'Hà Nội',
        photo: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400',
        extension: '',
        introduction: 'Khách sạn boutique giữa lòng Hà Nội.',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 80,
        revenue: 90000000,
        averageRating: 4.2,
      ),
      CooperationModel(
        cooperationId: 'H00005',
        name: 'Da Nang Golden Bay',
        type: 'resort',
        numberOfObjects: 0,
        numberOfObjectTypes: 0,
        latitude: 0,
        longitude: 0,
        bossName: 'Nguyen Van E',
        bossPhone: '0945678901',
        bossEmail: 'goldenbay@resort.com',
        address: '01 Le Van Duyet, Son Tra, Đà Nẵng',
        district: 'Sơn Trà',
        city: 'Đà Nẵng',
        province: 'Đà Nẵng',
        photo: 'https://images.unsplash.com/photo-1465156799763-2c087c332922?w=400',
        extension: '',
        introduction: 'Resort 5 sao với hồ bơi dát vàng.',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 60,
        revenue: 110000000,
        averageRating: 4.7,
      ),
      CooperationModel(
        cooperationId: 'H00006',
        name: 'Nha Trang Beach Hotel',
        type: 'hotel',
        numberOfObjects: 0,
        numberOfObjectTypes: 0,
        latitude: 0,
        longitude: 0,
        bossName: 'Tran Van F',
        bossPhone: '0956789012',
        bossEmail: 'beach@nhatranghotel.com',
        address: '42 Tran Phu, Nha Trang, Khánh Hòa',
        district: 'Nha Trang',
        city: 'Khánh Hòa',
        province: 'Khánh Hòa',
        photo: 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=400',
        extension: '',
        introduction: 'Khách sạn sát biển, view tuyệt đẹp.',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 70,
        revenue: 85000000,
        averageRating: 4.3,
      ),
      CooperationModel(
        cooperationId: 'H00007',
        name: 'Hue Riverside Resort',
        type: 'resort',
        numberOfObjects: 0,
        numberOfObjectTypes: 0,
        latitude: 0,
        longitude: 0,
        bossName: 'Le Thi G',
        bossPhone: '0967890123',
        bossEmail: 'riverside@hueresort.com',
        address: '588 Bui Thi Xuan, Hue',
        district: 'Huế',
        city: 'Thừa Thiên Huế',
        province: 'Thừa Thiên Huế',
        photo: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=400',
        extension: '',
        introduction: 'Resort ven sông, không gian yên tĩnh.',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 55,
        revenue: 70000000,
        averageRating: 4.1,
      ),
      CooperationModel(
        cooperationId: 'H00008',
        name: 'Sapa Mountain View',
        type: 'hotel',
        numberOfObjects: 0,
        numberOfObjectTypes: 0,
        latitude: 0,
        longitude: 0,
        bossName: 'Pham Van H',
        bossPhone: '0978901234',
        bossEmail: 'mountain@sapahotel.com',
        address: '10 Fansipan, Sapa, Lào Cai',
        district: 'Sa Pa',
        city: 'Lào Cai',
        province: 'Lào Cai',
        photo: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400',
        extension: '',
        introduction: 'Khách sạn view núi, không khí trong lành.',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 40,
        revenue: 60000000,
        averageRating: 4.0,
      ),
    ];
  }

  // Lấy giá phòng rẻ nhất cho khách sạn
  double _getMinRoomPrice(String hotelId) {
    final availability = hotelAvailability[hotelId];
    if (availability == null || availability.isEmpty) return 0;

    return availability
        .map((room) => room.price)
        .reduce((a, b) => a < b ? a : b);
  }

  // Lấy số phòng trống cho khách sạn
  int _getTotalAvailableRooms(String hotelId) {
    final availability = hotelAvailability[hotelId];
    if (availability == null || availability.isEmpty) return 0;

    return availability
        .map((room) => room.availableRooms)
        .reduce((a, b) => a + b);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onBackPressed: () {
          Navigator.of(context).pop();
        },
        title: AppLocalizations.of(context).translate("Hotel List"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredHotels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hotel, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Không tìm thấy khách sạn phù hợp',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (checkInDate != null && checkOutDate != null) ...[
                        SizedBox(height: 8),
                        Text(
                          'Từ ${DateFormat('dd/MM/yyyy').format(checkInDate!)} đến ${DateFormat('dd/MM/yyyy').format(checkOutDate!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Thông tin tìm kiếm
                    if (checkInDate != null && checkOutDate != null)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        margin: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue[700], size: 20.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Tìm kiếm từ ${DateFormat('dd/MM/yyyy').format(checkInDate!)} đến ${DateFormat('dd/MM/yyyy').format(checkOutDate!)} (${checkOutDate!.difference(checkInDate!).inDays} đêm)',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Danh sách khách sạn
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          itemCount: filteredHotels.length,
                          itemBuilder: (context, index) {
                            final hotel = filteredHotels[index];
                            final minPrice = _getMinRoomPrice(hotel.cooperationId);
                            final availableRooms = _getTotalAvailableRooms(hotel.cooperationId);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: HotelCard(
                                hotel: hotel,
                                minPrice: minPrice,
                                availableRooms: availableRooms,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HotelDetailScreen(hotel: hotel),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
