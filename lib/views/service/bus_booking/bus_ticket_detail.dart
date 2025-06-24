import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/bus_booking/bus_booking_bloc.dart/bus_booking_bloc.dart';
import 'package:tourguideapp/views/service/bus_booking/bus_booking_bloc.dart/bus_booking_event.dart';
import 'package:tourguideapp/views/service/bus_booking/bus_booking_bloc.dart/bus_booking_state.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/bus_station_picker.dart';
import 'package:tourguideapp/widgets/bus_seat_layout.dart';
import 'package:tourguideapp/widgets/bus_station_list.dart';
import 'package:tourguideapp/widgets/checkbox_row.dart';
import 'package:tourguideapp/widgets/custom_radio_options.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/seat_widget.dart';
import 'package:tourguideapp/widgets/bank_option_selector.dart';
import 'package:tourguideapp/core/services/momo_service.dart';
import 'package:tourguideapp/core/services/used_services_service.dart';
import 'package:tourguideapp/widgets/app_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/viewmodels/profile_viewmodel.dart';
import 'package:tourguideapp/models/voucher_model.dart';
import 'package:tourguideapp/views/service/voucher/voucher_selection_screen.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/core/services/wallet_service.dart';

class BusTicketDetail extends StatefulWidget {
  final DateTime departureDate;
  final DateTime? returnDate;
  final String fromLocation;
  final String toLocation;

  const BusTicketDetail({
    Key? key,
    required this.departureDate,
    this.returnDate,
    required this.fromLocation,
    required this.toLocation,
  }) : super(key: key);

  @override
  _BusTicketDetailState createState() => _BusTicketDetailState();
}

class _BusTicketDetailState extends State<BusTicketDetail>
    with SingleTickerProviderStateMixin {
  late DateTime departureDate;
  late DateTime? returnDate;
  late String fromLocation;
  late String toLocation;
  late TabController _tabController;
  bool get hasReturnDate => returnDate != null;

  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  int _currentStep = 0;
  final List<bool> _stepCompleted = [false, false, false, false];

  // Tính giá vé dựa trên tuyến đường
  double get seatPrice {
    final routeInfo = {
      'Ho Chi Minh City': {
        'Dak Lak': 285000,
        'Da Lat': 320000,
        'Nha Trang': 280000,
      },
      'Dak Lak': {
        'Ho Chi Minh City': 285000,
      },
      'Da Lat': {
        'Ho Chi Minh City': 320000,
      },
      'Nha Trang': {
        'Ho Chi Minh City': 280000,
      },
    };

    final fromInfo = routeInfo[fromLocation];
    if (fromInfo != null && fromInfo[toLocation] != null) {
      return fromInfo[toLocation]!.toDouble();
    }

    return 285000.0; // Giá mặc định
  }

  final UsedServicesService _usedServicesService = UsedServicesService();

  // Tạo layout cho 2 tầng xe cho cả chiều đi và về
  final List<List<SeatStatus>> departureUpperDeckLayout = List.generate(
    6, // 4 hàng trên tầng trên
    (row) => List.generate(6, (col) => SeatStatus.available),
  );

  final List<List<SeatStatus>> departureLowerDeckLayout = List.generate(
    6, // 4 hàng trên tầng dưới
    (row) => List.generate(6, (col) => SeatStatus.available),
  );

  final List<List<SeatStatus>> returnUpperDeckLayout = List.generate(
    6,
    (row) => List.generate(6, (col) => SeatStatus.available),
  );

  final List<List<SeatStatus>> returnLowerDeckLayout = List.generate(
    6,
    (row) => List.generate(6, (col) => SeatStatus.available),
  );

  List<SeatPosition> departureSelectedSeats = [];
  List<SeatPosition> returnSelectedSeats = [];

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String additionalMessages = '';

  bool _isCheckboxChecked = false;

  BusStation? selectedDepartureBusStation; // Bến xe cho chiều đi
  BusStation? selectedReturnBusStation; // Bến xe cho chiều về

  // Thêm các biến để lưu trữ thông tin điểm đón và trả
  BusStation? selectedDeparturePickupStation;
  BusStation? selectedDepartureDropStation;
  BusStation? selectedReturnPickupStation;
  BusStation? selectedReturnDropStation;

  // Các biến để lưu trữ tùy chọn dịch vụ đưa đón riêng biệt
  int _selectedDeparturePickupOption = 1;
  int _selectedDepartureDropOption = 1;
  int _selectedReturnPickupOption = 1;
  int _selectedReturnDropOption = 1;

  final List<BusStation> busStations = [
    BusStation(
      id: 1,
      name: 'Bến xe Miền Đông mới',
      address: '292 Đinh Bộ Lĩnh, Phường 26, Bình Thạnh, TP.HCM',
    ),
    BusStation(
      id: 2,
      name: 'Bến xe Miền Tây',
      address: '395 Kinh Dương Vương, An Lạc, Bình Tân, TP.HCM',
    ),
    BusStation(
      id: 3,
      name: 'Bến xe An Sương',
      address: 'QL22, An Sương, Hóc Môn, TP.HCM',
    ),
    BusStation(
      id: 4,
      name: 'Bến xe Buôn Ma Thuột',
      address: '123 Nguyễn Tất Thành, Tân Lợi, Buôn Ma Thuột, Đắk Lắk',
    ),
    BusStation(
      id: 5,
      name: 'Bến xe Đà Lạt',
      address: '1 Nguyễn Thị Minh Khai, Phường 1, Đà Lạt, Lâm Đồng',
    ),
    BusStation(
      id: 6,
      name: 'Bến xe Nha Trang',
      address: '23 Tháng 10, Vĩnh Hải, Nha Trang, Khánh Hòa',
    ),
  ];

  int travelPointToUse = 0;
  VoucherModel? selectedVoucher;
  final currencyFormat = NumberFormat('#,###', 'vi_VN');
  bool _isBookingSaved = false; // Biến để kiểm soát việc đã lưu chưa
  bool _isProcessingPayment = false; // Biến để kiểm soát trạng thái thanh toán
  String? selectedBank; // Phương thức thanh toán được chọn

  final List<Map<String, String>> bankOptions = [
    {'id': 'visa', 'image': 'assets/img/Logo_Visa.png'},
    {'id': 'mastercard', 'image': 'assets/img/Logo_Mastercard.png'},
    {'id': 'paypal', 'image': 'assets/img/Logo_PayPal.png'},
    {'id': 'momo', 'image': 'assets/img/Logo_Momo.png'},
    {'id': 'zalopay', 'image': 'assets/img/Logo_Zalopay.png'},
    {'id': 'shopee', 'image': 'assets/img/Logo_Shopee.png'},
  ];

  void toggleSeatSelection(int row, int col, bool isUpper, bool isDeparture) {
    setState(() {
      final seatLayout = isDeparture
          ? (isUpper ? departureUpperDeckLayout : departureLowerDeckLayout)
          : (isUpper ? returnUpperDeckLayout : returnLowerDeckLayout);
      final selectedSeats =
          isDeparture ? departureSelectedSeats : returnSelectedSeats;

      if (seatLayout[row][col] == SeatStatus.available) {
        seatLayout[row][col] = SeatStatus.selected;
        selectedSeats.add(SeatPosition(row, col, isUpper));
      } else if (seatLayout[row][col] == SeatStatus.selected) {
        seatLayout[row][col] = SeatStatus.available;
        selectedSeats.removeWhere((seat) =>
            seat.row == row && seat.col == col && seat.isUpper == isUpper);
      }
    });
  }

  String getSeatLabel(int row, int col, bool isUpper) {
    String rowLabel = isUpper ? 'B' : 'A';
    int seatNumber = row * 4 + col + 1;
    return '$rowLabel$seatNumber';
  }

  String _getStepTitle(int index, BuildContext context) {
    switch (index) {
      case 0:
        return AppLocalizations.of(context).translate("Choose Seats");
      case 1:
        return AppLocalizations.of(context).translate("Passenger Info");
      case 2:
        return AppLocalizations.of(context).translate("Pick-up/Drop");
      case 3:
        return AppLocalizations.of(context).translate("Payment");
      default:
        return "";
    }
  }

  // Phương thức trả về bến xe mặc định
  BusStation getDefaultBusStation() {
    return BusStation(
      id: 1,
      name: 'Bến xe Miền Đông mới',
      address: '292 Đinh Bộ Lĩnh, Phường 26, Bình Thạnh, TP.HCM',
    );
  }

  @override
  void initState() {
    super.initState();
    departureDate = widget.departureDate;
    returnDate = widget.returnDate;
    fromLocation = widget.fromLocation;
    toLocation = widget.toLocation;

    _tabController = TabController(
      length: hasReturnDate ? 2 : 1,
      vsync: this,
    );

    _pageController = PageController();
    _scrollController = ScrollController();

    // Khởi tạo giá trị mặc định cho bến xe chiều đi và về
    selectedDeparturePickupStation = getDefaultBusStation();
    selectedDepartureDropStation = getDefaultBusStation();
    selectedReturnPickupStation = getDefaultBusStation();
    selectedReturnDropStation = getDefaultBusStation();

    // Load user data thông qua bloc
    context.read<BusBookingBloc>().add(LoadUserData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _stepCompleted[_currentStep] = true;
        _currentStep++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );

        if (_currentStep == 2) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _stepCompleted[_currentStep] = false;
        _currentStep--;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );

        if (_currentStep == 1) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _getDayAbbreviation(DateTime date, BuildContext context) {
    List<String> daysVi = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    List<String> daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    String languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'vi'
        ? daysVi[date.weekday % 7]
        : daysEn[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: '$fromLocation - $toLocation',
        isColumnTitle: true,
        subtitle:
            '${_getDayAbbreviation(departureDate, context)}, ${departureDate.day}/${departureDate.month}/${departureDate.year}',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, profile, child) {
          final travelPoint = profile.travelPoint;
          final List<int> travelPointOptions = [];
          for (int i = 1000; i <= travelPoint; i += 1000) {
            travelPointOptions.add(i);
          }
          final totalDepartureSeats = departureSelectedSeats.length;
          final totalReturnSeats = returnSelectedSeats.length;
          final totalSeats = totalDepartureSeats + totalReturnSeats;
          final total = totalSeats * seatPrice;
          final totalAfterPoint =
              (total - travelPointToUse).clamp(0, total).toDouble();
          final totalAfterVoucher = selectedVoucher != null
              ? (totalAfterPoint -
                      selectedVoucher!.calculateDiscount(totalAfterPoint))
                  .clamp(0, totalAfterPoint)
                  .toDouble()
              : totalAfterPoint;
          return Column(
            children: [
              // Step indicators
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Row(
                          children: [
                            // Indicator button
                            Container(
                              width: 30.w,
                              height: 30.h,
                              decoration: BoxDecoration(
                                color: _currentStep >= index
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _currentStep >= index
                                      ? AppColors.primaryColor
                                      : Colors.grey,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: _currentStep >= index
                                        ? Colors.white
                                        : Colors.grey,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            // Title next to button
                            SizedBox(width: 8.w),
                            SizedBox(
                              child: Text(
                                _getStepTitle(index, context),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            // Connecting line
                            if (index < 3)
                              Container(
                                width: 60.w,
                                height: 1.h,
                                color: _currentStep > index
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                              ),
                            SizedBox(width: 20.w),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSeatPage(),
                    _buildPassengerInfoPage(),
                    _buildPickupDropPage(),
                    _buildConfirmationPageWithPoint(travelPointOptions, total,
                        totalAfterPoint, totalAfterVoucher),
                  ],
                ),
              ),

              // Navigation buttons
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _previousStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF007BFF),
                              side: const BorderSide(color: Color(0xFF007BFF)),
                              minimumSize: Size(double.infinity, 50.h),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("Previous"),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentStep == 3 ? null : _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50.h),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).translate("Next"),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSeatPage() {
    return Column(
      children: [
        if (hasReturnDate)
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3.h,
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                child: Text(
                  '${_getDayAbbreviation(departureDate, context)}, ${departureDate.day}/${departureDate.month}',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              Tab(
                child: Text(
                  '${_getDayAbbreviation(returnDate!, context)}, ${returnDate?.day}/${returnDate?.month}',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSeatSelectionTab(true), // Departure tab
              if (hasReturnDate) _buildSeatSelectionTab(false), // Return tab
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeatSelectionTab(bool isDeparture) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem(AppColors.grey, 'Reserved'),
                _buildLegendItem(AppColors.primaryColor, 'Available'),
                _buildLegendItem(AppColors.green, 'Selected'),
              ],
            ),
            SizedBox(height: 20.h),
            BusSeatLayout(
              upperDeckLayout: isDeparture
                  ? departureUpperDeckLayout
                  : returnUpperDeckLayout,
              lowerDeckLayout: isDeparture
                  ? departureLowerDeckLayout
                  : returnLowerDeckLayout,
              onSeatTap: (row, col, isUpper) =>
                  toggleSeatSelection(row, col, isUpper, isDeparture),
              getSeatLabel: getSeatLabel,
            ),
            SizedBox(height: 20.h),
            _buildBookingSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBookingSummary() {
    final totalSeats =
        departureSelectedSeats.length + returnSelectedSeats.length;
    final totalPrice =
        (departureSelectedSeats.length + returnSelectedSeats.length) *
            seatPrice;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vé chiều đi (${departureSelectedSeats.length})',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
            ),
          ),
          if (hasReturnDate) ...[
            SizedBox(height: 8.h),
            Text(
              'Vé chiều về (${returnSelectedSeats.length})',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng số vé: $totalSeats',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)} VND',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfoPage() {
    return BlocConsumer<BusBookingBloc, BusBookingState>(
      listener: (context, state) {
        print('Listener called'); // Debug print
      },
      builder: (context, state) {
        // Gán giá trị trực tiếp trong builder
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.fullName != null) {
            _fullNameController.text = state.fullName!;
          }
          if (state.email != null) {
            _emailController.text = state.email!;
          }
          if (state.phoneNumber != null) {
            _phoneNumberController.text = state.phoneNumber!;
          }
        });

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)
                      .translate("Passenger Information"),
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _fullNameController,
                  hintText: AppLocalizations.of(context)
                      .translate("Enter your full name"),
                  label: AppLocalizations.of(context).translate("Full Name"),
                  isEditing: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate("Please enter your full name");
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _emailController,
                  hintText: AppLocalizations.of(context)
                      .translate("Enter your email"),
                  label: AppLocalizations.of(context).translate("Email"),
                  isEditing: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate("Please enter your email");
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _phoneNumberController,
                  hintText: AppLocalizations.of(context)
                      .translate("Enter your phone number"),
                  label: AppLocalizations.of(context).translate("Phone Number"),
                  isEditing: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate("Please enter your phone number");
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40.h),
                Center(
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("TERMS AND CONDITIONS"),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '(*) Quý khách vui lòng có mặt tại bến xuất phát của xe trước ít nhất 30 phút giờ xe khởi hành, mang theo thông báo đã thanh toán vé thành công có chứa mã vé được gửi từ hệ thống TRAVELINE. Vui lòng liên hệ Trung tâm tổng đài ',
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                      TextSpan(
                        text: '1900 6067',
                        style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                      TextSpan(
                        text: ' để được hỗ trợ.',
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '(*) Nếu quý khách có nhu cầu trung chuyển, vui lòng liên hệ Tổng đài trung chuyển ',
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                      TextSpan(
                        text: '1900 6918',
                        style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                      TextSpan(
                        text:
                            ' trước khi đặt vé. Chúng tôi không đón/trung chuyển tại những điểm xe trung chuyển không thể tới được.',
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                CheckboxRow(
                  title: AppLocalizations.of(context).translate(
                      "I confirm all data provided is accurate and truthful. I have read and agree to "),
                  link: AppLocalizations.of(context)
                      .translate("Traveline's Privacy Policy."),
                  onTitleTap: _handleTitleTap,
                  value: _isCheckboxChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isCheckboxChecked = newValue ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTitleTap() {
    // Handle the tap on the link
    // For example, navigate to the privacy policy page
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
    // );
  }

  Widget _buildPickupDropPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần thông tin đón/trả cho chiều đi
            _buildTripSection(
              title: AppLocalizations.of(context)
                  .translate("Pick-up/Drop Information"),
              subtitle: AppLocalizations.of(context).translate(
                  "Departure trip - ${_getDayAbbreviation(departureDate, context)}, ${departureDate.day}/${departureDate.month}/${departureDate.year}"),
              date: departureDate,
              isDeparture: true,
            ),

            SizedBox(height: 40.h),

            // Phần thông tin đón/trả cho chiều về (nếu có)
            if (hasReturnDate)
              _buildTripSection(
                title: AppLocalizations.of(context)
                    .translate("Pick-up/Drop Information"),
                subtitle: AppLocalizations.of(context).translate(
                    "Return trip - ${_getDayAbbreviation(returnDate!, context)}, ${returnDate!.day}/${returnDate!.month}/${returnDate!.year}"),
                date: returnDate!,
                isDeparture: false,
              ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // Phương thức tạo mục thông tin pickup/drop cho một chuyến đi
  Widget _buildTripSection({
    required String title,
    required String subtitle,
    required DateTime date,
    required bool isDeparture,
  }) {
    // Xác định các biến tương ứng dựa trên chiều đi/về
    final pickupOption = isDeparture
        ? _selectedDeparturePickupOption
        : _selectedReturnPickupOption;
    final dropOption =
        isDeparture ? _selectedDepartureDropOption : _selectedReturnDropOption;
    final pickupStation = isDeparture
        ? selectedDeparturePickupStation
        : selectedReturnPickupStation;
    final dropStation =
        isDeparture ? selectedDepartureDropStation : selectedReturnDropStation;

    // Xác định các điểm đi và đến
    final fromLoc = isDeparture ? fromLocation : toLocation;
    final toLoc = isDeparture ? toLocation : fromLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 20.h),

        // Phần điểm đón (pickup)
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ĐIỂM ĐÓN - $fromLoc',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context)
                    .translate("BUS STATION/COMPANY OFFICE"),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16.h),
              RadioOptionsWidget(
                titles: [
                  AppLocalizations.of(context)
                      .translate("Bus Station/\nCompany Office"),
                  AppLocalizations.of(context).translate("Shuttle Service"),
                ],
                selectedOption: pickupOption,
                onOptionChanged: (value) {
                  setState(() {
                    if (isDeparture) {
                      _selectedDeparturePickupOption = value ?? 1;
                    } else {
                      _selectedReturnPickupOption = value ?? 1;
                    }
                  });
                },
              ),
              SizedBox(height: 16.h),
              BusStationPicker(
                initialSelectedStation: pickupStation ?? getDefaultBusStation(),
                onStationSelected: (station) {
                  setState(() {
                    if (isDeparture) {
                      selectedDeparturePickupStation = station;
                    } else {
                      selectedReturnPickupStation = station;
                    }
                  });
                },
              ),
              SizedBox(height: 16.h),
              _buildInstructionText(date, pickupStation, isPickup: true),
            ],
          ),
        ),

        SizedBox(height: 20.h),

        // Phần điểm trả (drop)
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ĐIỂM TRẢ - $toLoc',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context)
                    .translate("BUS STATION/COMPANY OFFICE"),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16.h),
              RadioOptionsWidget(
                titles: [
                  AppLocalizations.of(context)
                      .translate("Bus Station/\nCompany Office"),
                  AppLocalizations.of(context).translate("Shuttle Service"),
                ],
                selectedOption: dropOption,
                onOptionChanged: (value) {
                  setState(() {
                    if (isDeparture) {
                      _selectedDepartureDropOption = value ?? 1;
                    } else {
                      _selectedReturnDropOption = value ?? 1;
                    }
                  });
                },
              ),
              SizedBox(height: 16.h),
              BusStationPicker(
                initialSelectedStation: dropStation ?? getDefaultBusStation(),
                onStationSelected: (station) {
                  setState(() {
                    if (isDeparture) {
                      selectedDepartureDropStation = station;
                    } else {
                      selectedReturnDropStation = station;
                    }
                  });
                },
              ),
              SizedBox(height: 16.h),
              _buildInstructionText(date, dropStation, isPickup: false),
            ],
          ),
        ),
      ],
    );
  }

  // Phương thức tạo văn bản hướng dẫn tùy chỉnh cho pickup hoặc drop
  Widget _buildInstructionText(DateTime date, BusStation? station,
      {required bool isPickup}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: isPickup
                ? 'Quý khách vui lòng có mặt tại Bến xe/Văn phòng '
                : 'Quý khách sẽ được trả tại Bến xe/Văn phòng ',
            style: TextStyle(
                color: AppColors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                height: 1.5),
          ),
          TextSpan(
            text: station?.name ?? getDefaultBusStation().name,
            style: TextStyle(
                color: AppColors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                height: 1.5),
          ),
          TextSpan(
            text: isPickup
                ? ' trước 21:30 ngày ${date.day}/${date.month}/${date.year} '
                : '(thời gian dự kiến, có thể thay đổi tùy tình hình giao thông).',
            style: TextStyle(
                color: AppColors.orange,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationPageWithPoint(List<int> travelPointOptions,
      double total, double totalAfterPoint, double totalAfterVoucher) {
    return Consumer<ProfileViewModel>(
      builder: (context, profile, child) {
        final travelPoint = profile.travelPoint;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xác nhận thông tin đặt vé',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20.h),
                // Thông tin hành khách
                _buildConfirmationSection(
                  title: 'Thông tin hành khách',
                  content: [
                    'Họ tên: ${_fullNameController.text}',
                    'Email: ${_emailController.text}',
                    'Số điện thoại: ${_phoneNumberController.text}',
                  ],
                ),
                // Thông tin chuyến đi
                _buildConfirmationSection(
                  title: 'Thông tin chuyến đi',
                  content: [
                    'Chiều đi: $fromLocation - $toLocation',
                    'Ngày đi: ${departureDate.day}/${departureDate.month}/${departureDate.year}',
                    'Số ghế: ${departureSelectedSeats.length}',
                    'Điểm đón: ${selectedDeparturePickupStation?.name ?? ""}',
                    'Điểm trả: ${selectedDepartureDropStation?.name ?? ""}',
                    if (hasReturnDate) 'Chiều về: $toLocation - $fromLocation',
                    if (hasReturnDate)
                      'Ngày về: ${returnDate!.day}/${returnDate!.month}/${returnDate!.year}',
                    if (hasReturnDate) 'Số ghế: ${returnSelectedSeats.length}',
                    if (hasReturnDate)
                      'Điểm đón: ${selectedReturnPickupStation?.name ?? ""}',
                    if (hasReturnDate)
                      'Điểm trả: ${selectedReturnDropStation?.name ?? ""}',
                  ],
                ),
                // Sử dụng điểm thưởng
                if (travelPointOptions.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.orange.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Sử dụng điểm thưởng',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Điểm hiện có: ${currencyFormat.format(travelPoint)} điểm',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: DropdownButtonFormField<int>(
                            value: travelPointToUse,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              hintText: 'Chọn số điểm muốn sử dụng',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14.sp,
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel_outlined,
                                        color: Colors.grey, size: 16.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Không sử dụng điểm',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...travelPointOptions
                                  .map((points) => DropdownMenuItem(
                                        value: points,
                                        child: Text(
                                          '${currencyFormat.format(points)} điểm (-${currencyFormat.format(points)} ₫)',
                                          style: TextStyle(
                                            color: Colors.orange.shade800,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                travelPointToUse = value ?? 0;
                              });
                            },
                            dropdownColor: Colors.white,
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: Colors.orange),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        if (travelPointToUse > 0) ...[
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.savings,
                                    color: Colors.green, size: 16.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  'Tiết kiệm: ${currencyFormat.format(travelPointToUse)} ₫',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                // Chọn voucher
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Voucher',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700)),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push<VoucherModel>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VoucherSelectionScreen(
                                    totalAmount: totalAfterPoint,
                                    onVoucherSelected: (voucher) {
                                      setState(() {
                                        selectedVoucher = voucher;
                                      });
                                    },
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  selectedVoucher = result;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                selectedVoucher != null
                                    ? 'Thay đổi'
                                    : 'Chọn voucher',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      if (selectedVoucher != null) ...[
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_offer,
                                color: AppColors.primaryColor,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GIẢM ${selectedVoucher!.value}% HÓA ĐƠN',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'Tiết kiệm: ${currencyFormat.format(selectedVoucher!.calculateDiscount(totalAfterPoint))} ₫',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedVoucher = null;
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 20.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Chưa chọn voucher',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Thanh toán bằng ví tiền
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Thanh toán bằng ví tiền',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700)),
                          Switch(
                            value: false, // Mặc định không chọn
                            onChanged: profile.walletBalance >=
                                    totalAfterVoucher
                                ? (value) {
                                    // Xử lý khi chọn thanh toán bằng ví
                                    if (value) {
                                      showAppDialog(
                                        context: context,
                                        title: 'Xác nhận thanh toán',
                                        content:
                                            'Bạn có muốn thanh toán ${currencyFormat.format(totalAfterVoucher)} ₫ bằng ví tiền không?',
                                        icon: Icons.account_balance_wallet,
                                        iconColor: AppColors.primaryColor,
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              // Xử lý thanh toán bằng ví
                                              try {
                                                final userId = FirebaseAuth
                                                    .instance.currentUser?.uid;
                                                if (userId != null) {
                                                  final success =
                                                      await WalletService()
                                                          .deductFromWallet(
                                                              userId,
                                                              totalAfterVoucher);
                                                  if (success) {
                                                    // Cập nhật số dư
                                                    final newBalance =
                                                        await WalletService()
                                                            .getWalletBalance(
                                                                userId);
                                                    profile.updateWalletBalance(
                                                        newBalance);

                                                    // Lưu vào used services
                                                    await _saveBusBooking(
                                                        totalAfterVoucher);
                                                  } else {
                                                    throw Exception(
                                                        'Không đủ số dư trong ví');
                                                  }
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text('Lỗi: $e'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: Text('Xác nhận'),
                                          ),
                                        ],
                                      );
                                    }
                                  }
                                : null,
                            activeColor: AppColors.primaryColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Số dư ví: ${currencyFormat.format(profile.walletBalance)} ₫',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (profile.walletBalance < totalAfterVoucher) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'Số dư không đủ để thanh toán',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Tổng tiền
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng số vé:',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${departureSelectedSeats.length + returnSelectedSeats.length}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng tiền:',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${currencyFormat.format(total)} ₫',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      // Chi tiết giảm giá
                      if (selectedVoucher != null || travelPointToUse > 0) ...[
                        SizedBox(height: 12.h),
                        Divider(height: 1, color: Colors.grey.shade300),
                        SizedBox(height: 8.h),
                        // Voucher giảm giá
                        if (selectedVoucher != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Giảm ${selectedVoucher!.value}% voucher:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '-${currencyFormat.format(selectedVoucher!.calculateDiscount(totalAfterPoint))} ₫',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sau voucher:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '${currencyFormat.format(totalAfterVoucher)} ₫',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],
                        // Điểm thưởng
                        if (travelPointToUse > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Trừ điểm thưởng:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '-${currencyFormat.format(travelPointToUse)} ₫',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],
                        Divider(height: 1, color: Colors.grey.shade300),
                        SizedBox(height: 8.h),
                        // Tổng cuối cùng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng thanh toán:',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '${currencyFormat.format(totalAfterVoucher)} ₫',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Phương thức thanh toán
                Text(
                  AppLocalizations.of(context).translate("Payment Method"),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 16.h),

                // Hàng 1 - 3 phương thức đầu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: bankOptions
                      .sublist(0, 3)
                      .map((bank) => BankOptionSelector(
                            bankImageUrl: bank['image']!,
                            isSelected: selectedBank == bank['id'],
                            onTap: () {
                              setState(() {
                                selectedBank = bank['id'];
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 16.h),

                // Hàng 2 - 3 phương thức sau
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: bankOptions
                      .sublist(3, 6)
                      .map((bank) => BankOptionSelector(
                            bankImageUrl: bank['image']!,
                            isSelected: selectedBank == bank['id'],
                            onTap: () {
                              setState(() {
                                selectedBank = bank['id'];
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 32.h),

                // Nút xác nhận thanh toán
                ElevatedButton(
                  onPressed: !_isProcessingPayment
                      ? () async {
                          // Kiểm tra thông tin trước khi thanh toán
                          if (departureSelectedSeats.isEmpty &&
                              returnSelectedSeats.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)
                                    .translate(
                                        'Please select at least one seat')),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (_fullNameController.text.isEmpty ||
                              _emailController.text.isEmpty ||
                              _phoneNumberController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)
                                    .translate(
                                        'Please fill in all passenger information')),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (selectedBank == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)
                                    .translate(
                                        'Please select a payment method')),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (selectedBank == 'momo') {
                            await MomoService.processPayment(
                              merchantName: 'TTN',
                              appScheme: 'MOMO',
                              merchantCode: 'MOMO',
                              partnerCode: 'MOMO',
                              amount: totalAfterVoucher.toInt(),
                              orderId: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              orderLabel: 'Đặt vé xe buýt',
                              merchantNameLabel: 'HLGD',
                              fee: 0,
                              description: 'Thanh toán đặt vé xe buýt',
                              username:
                                  FirebaseAuth.instance.currentUser?.uid ?? '',
                              partner: 'merchant',
                              extra:
                                  '{"fromLocation":"$fromLocation","toLocation":"$toLocation"}',
                              isTestMode: true,
                              onSuccess: (response) async {
                                // Gọi _saveBusBooking để lưu booking
                                await _saveBusBooking(totalAfterVoucher);
                              },
                              onError: (response) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(AppLocalizations.of(context)
                                              .translate(
                                                  'MoMo payment failed:') +
                                          ' ${response.message}'),
                                      backgroundColor: Colors.red),
                                );
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)
                                    .translate(
                                        'This feature will be available soon!')),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProcessingPayment
                        ? Colors.grey
                        : AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: _isProcessingPayment
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Đang xử lý...',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          AppLocalizations.of(context)
                              .translate("Confirm Payment"),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Phương thức để hiển thị phần thông tin trong trang xác nhận
  Widget _buildConfirmationSection(
      {required String title, required List<String> content}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          ...content
              .map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  // Phương thức riêng để xử lý việc lưu bus booking
  Future<void> _saveBusBooking(double totalAfterVoucher) async {
    // Kiểm tra xem đã lưu chưa để tránh duplicate
    if (_isBookingSaved) {
      print('Bus booking already saved, skipping duplicate save');
      return;
    }

    // Kiểm tra xem đang xử lý thanh toán không để tránh duplicate
    if (_isProcessingPayment) {
      print('Payment is already being processed, skipping duplicate payment');
      return;
    }

    // Đánh dấu đang xử lý thanh toán
    _isProcessingPayment = true;

    try {
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _usedServicesService.addBusBookingToUsedServices(
        userId: currentUser.uid,
        orderId: orderId,
        fromLocation: fromLocation,
        toLocation: toLocation,
        departureDate: departureDate,
        returnDate: returnDate,
        passengerName: _fullNameController.text,
        passengerEmail: _emailController.text,
        passengerPhone: _phoneNumberController.text,
        departureSelectedSeats: departureSelectedSeats
            .map((e) => '${e.isUpper ? 'B' : 'A'}${e.row * 4 + e.col + 1}')
            .toList(),
        returnSelectedSeats: returnSelectedSeats
            .map((e) => '${e.isUpper ? 'B' : 'A'}${e.row * 4 + e.col + 1}')
            .toList(),
        departurePickupStation: selectedDeparturePickupStation?.name ?? '',
        departureDropStation: selectedDepartureDropStation?.name ?? '',
        returnPickupStation: selectedReturnPickupStation?.name,
        returnDropStation: selectedReturnDropStation?.name,
        amount: totalAfterVoucher,
        travelPointsUsed: travelPointToUse,
        status: 'confirmed',
      );

      // Trừ điểm thưởng
      if (travelPointToUse > 0) {
        await FirebaseFirestore.instance
            .collection('USER')
            .doc(currentUser.uid)
            .update({
          'travelPoint': FieldValue.increment(-travelPointToUse),
        });
      }

      // Cộng điểm thưởng
      final reward = totalAfterVoucher > 500000 ? 2000 : 1000;
      await FirebaseFirestore.instance
          .collection('USER')
          .doc(currentUser.uid)
          .update({
        'travelPoint': FieldValue.increment(reward),
      });

      // Đánh dấu đã lưu thành công
      _isBookingSaved = true;

      print('Bus booking saved to used services successfully: $orderId');

      if (mounted) {
        showAppDialog(
          context: context,
          title: AppLocalizations.of(context).translate('Notification'),
          content: AppLocalizations.of(context).translate(
              'Your bus booking has been confirmed. The service will be added to your used list.'),
          icon: Icons.check_circle,
          iconColor: Colors.green,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(AppLocalizations.of(context).translate('OK')),
            ),
          ],
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).translate('Error:') + ' $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset trạng thái xử lý thanh toán
      _isProcessingPayment = false;
    }
  }
}

// Cập nhật class SeatPosition
class SeatPosition {
  final int row;
  final int col;
  final bool isUpper;

  SeatPosition(this.row, this.col, this.isUpper);
}

Widget _buildTextField(
    {required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isEditing,
    required Function(String?) validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 4.w),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.orange,
            ),
          ),
        ],
      ),
      SizedBox(height: 4.h),
      CustomTextField(
        controller: controller,
        hintText: hintText,
      ),
    ],
  );
}
