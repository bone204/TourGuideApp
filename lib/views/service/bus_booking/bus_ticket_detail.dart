import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/blocs/bus_booking/bus_booking_bloc.dart';
import 'package:tourguideapp/blocs/bus_booking/bus_booking_event.dart';
import 'package:tourguideapp/blocs/bus_booking/bus_booking_state.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/bus_sation_picker.dart';
import 'package:tourguideapp/widgets/bus_seat_layout.dart';
import 'package:tourguideapp/widgets/bus_station_list.dart';
import 'package:tourguideapp/widgets/checkbox_row.dart';
import 'package:tourguideapp/widgets/custom_radio_options.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/seat_widget.dart';

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

class _BusTicketDetailState extends State<BusTicketDetail> with SingleTickerProviderStateMixin {
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

  final double seatPrice = 50000; // Price per seat in VND

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

  int _selectedOption = 1;

  BusStation? selectedBusStation; // Biến để lưu trữ bến xe được chọn

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
    // Add more BusStation instances as needed
  ];

  void toggleSeatSelection(int row, int col, bool isUpper, bool isDeparture) {
    setState(() {
      final seatLayout = isDeparture
          ? (isUpper ? departureUpperDeckLayout : departureLowerDeckLayout)
          : (isUpper ? returnUpperDeckLayout : returnLowerDeckLayout);
      final selectedSeats = isDeparture ? departureSelectedSeats : returnSelectedSeats;

      if (seatLayout[row][col] == SeatStatus.available) {
        seatLayout[row][col] = SeatStatus.selected;
        selectedSeats.add(SeatPosition(row, col, isUpper));
      } else if (seatLayout[row][col] == SeatStatus.selected) {
        seatLayout[row][col] = SeatStatus.available;
        selectedSeats.removeWhere(
          (seat) => seat.row == row && seat.col == col && seat.isUpper == isUpper
        );
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
        subtitle: '${_getDayAbbreviation(departureDate, context)}, ${departureDate.day}/${departureDate.month}/${departureDate.year}',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
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
                            color: _currentStep >= index ? AppColors.primaryColor : Colors.transparent,
                            border: Border.all(
                              color: _currentStep >= index ? AppColors.primaryColor : Colors.grey,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: _currentStep >= index ? Colors.white : Colors.grey,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
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
                            color: _currentStep > index ? AppColors.primaryColor : Colors.grey,
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
                _buildConfirmationPage(),
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                          AppLocalizations.of(context).translate("Previous"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0)
                    SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStep == 3 ? () {
                        // Handle confirmation
                      } : _nextStep,
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
                        _currentStep == 3 ? AppLocalizations.of(context).translate("Confirm") : AppLocalizations.of(context).translate("Next"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
              _buildSeatSelectionTab(true),  // Departure tab
              if (hasReturnDate) _buildSeatSelectionTab(false),  // Return tab
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
              upperDeckLayout: isDeparture ? departureUpperDeckLayout : returnUpperDeckLayout,
              lowerDeckLayout: isDeparture ? departureLowerDeckLayout : returnLowerDeckLayout,
              onSeatTap: (row, col, isUpper) => toggleSeatSelection(row, col, isUpper, isDeparture),
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
    final totalSeats = departureSelectedSeats.length + returnSelectedSeats.length;
    final totalPrice = (departureSelectedSeats.length + returnSelectedSeats.length) * seatPrice;

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
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)} VND',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                  AppLocalizations.of(context).translate("Passenger Information"),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _fullNameController,
                  hintText: AppLocalizations.of(context).translate("Enter your full name"),
                  label: AppLocalizations.of(context).translate("Full Name"),
                  isEditing: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate("Please enter your full name");
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _emailController,
                  hintText: AppLocalizations.of(context).translate("Enter your email"),
                  label: AppLocalizations.of(context).translate("Email"),
                  isEditing: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate("Please enter your email");
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _phoneNumberController,
                  hintText: AppLocalizations.of(context).translate("Enter your phone number"),
                  label: AppLocalizations.of(context).translate("Phone Number"),
                  isEditing: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate("Please enter your phone number");
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40.h),
                Center(
                  child: Text(
                    AppLocalizations.of(context).translate("TERMS AND CONDITIONS"),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '(*) Quý khách vui lòng có mặt tại bến xuất phát của xe trước ít nhất 30 phút giờ xe khởi hành, mang theo thông báo đã thanh toán vé thành công có chứa mã vé được gửi từ hệ thống TRAVELINE. Vui lòng liên hệ Trung tâm tổng đài ',
                        style: TextStyle(color: AppColors.black, fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.5),
                      ),
                      TextSpan(
                        text: '1900 6067',
                        style: TextStyle(color: AppColors.orange, fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.5),
                      ),
                      TextSpan(
                        text: ' để được hỗ trợ.',
                        style: TextStyle(color: AppColors.black, fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '(*) Nếu quý khách có nhu cầu trung chuyển, vui lòng liên hệ Tổng đài trung chuyển ',
                        style: TextStyle(color: AppColors.black, fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.5),
                      ),
                      TextSpan(
                        text: '1900 6918',
                        style: TextStyle(color: AppColors.orange, fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.5),
                      ),
                      TextSpan(
                        text: ' trước khi đặt vé. Chúng tôi không đón/trung chuyển tại những điểm xe trung chuyển không thể tới được.',
                        style: TextStyle(color: AppColors.black, fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                CheckboxRow(
                  title: AppLocalizations.of(context).translate("I confirm all data provided is accurate and truthful. I have read and agree to "),
                  link: AppLocalizations.of(context).translate("Traveline's Privacy Policy."),
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
    // Khởi tạo selectedBusStation với giá trị mặc định nếu nó là null
    if (selectedBusStation == null) {
      selectedBusStation = getDefaultBusStation();
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate("Pick-up/Drop Information"),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4.h),
            Text(
              AppLocalizations.of(context).translate("Departure trip - ${_getDayAbbreviation(departureDate, context)}, ${departureDate.day}/${departureDate.month}/${departureDate.year}"),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 40.h),
            Text(
              AppLocalizations.of(context).translate("BUS STATION/COMPANY OFFICE"),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20.h),
            RadioOptionsWidget(
              titles: [
                AppLocalizations.of(context).translate("Bus Station/\nCompany Office"),
                AppLocalizations.of(context).translate("Shuttle Service"),
              ],
              selectedOption: _selectedOption,
              onOptionChanged: (value) {
                setState(() {
                  _selectedOption = value ?? 1;
                });
              },
            ),
            SizedBox(height: 20.h),
            BusStationPicker(
              initialSelectedStation: selectedBusStation ?? getDefaultBusStation(),
              onStationSelected: (station) {
                setState(() {
                  selectedBusStation = station;
                });
              },
            ),
            SizedBox(height: 20.h),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Quý khách vui lòng có mặt tại Bến xe/Văn phòng ',
                    style: TextStyle(color: AppColors.black, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                  TextSpan(
                    text: selectedBusStation?.name ?? getDefaultBusStation().name,
                    style: TextStyle(color: AppColors.black, fontSize: 14.sp, fontWeight: FontWeight.bold, height: 1.5),
                  ),
                  TextSpan(
                    text: ' trước 21:30 ngày ${departureDate.day}/${departureDate.month}/${departureDate.year} ',
                    style: TextStyle(color: AppColors.orange, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                  TextSpan(
                    text: 'để được trung chuyển hoặc kiểm tra thông tin trước khi lên xe.',
                    style: TextStyle(color: AppColors.black, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirmation'),
            // Add your confirmation widgets
          ],
        ),
      ),
    );
  }
}

// Cập nhật class SeatPosition
class SeatPosition {
  final int row;
  final int col;
  final bool isUpper;

  SeatPosition(this.row, this.col, this.isUpper);
}

Widget _buildTextField({required TextEditingController controller, required String label, required String hintText, required bool isEditing, required Function(String?) validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
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