import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/hotel_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/models/room_availability_model.dart';
import 'package:tourguideapp/core/services/hotel_service.dart';
import 'package:tourguideapp/views/service/hotel/room_list_screen.dart';
import 'package:intl/intl.dart';

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
        bossName: '',
        bossPhone: '',
        bossEmail: '',
        address: '141 Nguyễn Huệ, Bến Nghé, Quận 1, TP.HCM',
        district: '',
        city: '',
        province: 'TP.HCM',
        photo:
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400',
        extension: '',
        introduction: '',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 0,
        revenue: 0,
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
        bossName: '',
        bossPhone: '',
        bossEmail: '',
        address: '19 Lam Sơn, Bến Nghé, Quận 1, TP.HCM',
        district: '',
        city: '',
        province: 'TP.HCM',
        photo:
            'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400',
        extension: '',
        introduction: '',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 0,
        revenue: 0,
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
        bossName: '',
        bossPhone: '',
        bossEmail: '',
        address:
            'Corner of Hai Ba Trung St. & Le Duan Blvd, District 1, TP.HCM',
        district: '',
        city: '',
        province: 'TP.HCM',
        photo:
            'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400',
        extension: '',
        introduction: '',
        contractDate: '',
        contractTerm: '',
        bankAccountNumber: '',
        bankAccountName: '',
        bankName: '',
        bookingTimes: 0,
        revenue: 0,
        averageRating: 5.0,
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

  void _navigateToRoomList(CooperationModel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomListScreen(hotel: hotel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 40.h,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomIconButton(
                        icon: Icons.chevron_left,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        AppLocalizations.of(context).translate('Hotel List'),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 161.w /
                                220.h, // Tăng chiều cao để hiển thị thêm thông tin
                            mainAxisSpacing: 20.h,
                            crossAxisSpacing: 0,
                          ),
                          itemCount: filteredHotels.length,
                          itemBuilder: (context, index) {
                            final hotel = filteredHotels[index];
                            final minPrice =
                                _getMinRoomPrice(hotel.cooperationId);
                            final availableRooms =
                                _getTotalAvailableRooms(hotel.cooperationId);

                            return GestureDetector(
                              onTap: () => _navigateToRoomList(hotel),
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey[300]!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Ảnh khách sạn
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12.r),
                                        topRight: Radius.circular(12.r),
                                      ),
                                      child: Image.network(
                                        hotel.photo,
                                        height: 120.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // Thông tin khách sạn
                                    Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hotel.name,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              Icon(Icons.star,
                                                  size: 14.sp,
                                                  color: Colors.amber),
                                              SizedBox(width: 4.w),
                                              Text(
                                                hotel.averageRating.toString(),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8.h),
                                          // Thông tin phòng trống
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.bed,
                                                    size: 12.sp,
                                                    color: Colors.green[700]),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  '$availableRooms phòng trống',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: Colors.green[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          // Giá phòng
                                          Text(
                                            'Từ ${NumberFormat('#,###', 'vi_VN').format(minPrice.toInt())} ₫',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
