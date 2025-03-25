import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/bus_seat_layout.dart';
import 'package:tourguideapp/widgets/seat_widget.dart';

class BusTicketDetail extends StatefulWidget {
  final DateTime arrivalDate;
  final DateTime? returnDate;
  final String fromLocation;
  final String toLocation;

  const BusTicketDetail({
    Key? key,
    required this.arrivalDate,
    this.returnDate,
    required this.fromLocation,
    required this.toLocation,
  }) : super(key: key);

  @override
  _BusTicketDetailState createState() => _BusTicketDetailState();
}

class _BusTicketDetailState extends State<BusTicketDetail> with SingleTickerProviderStateMixin {
  late DateTime arrivalDate;
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

  @override
  void initState() {
    super.initState();
    arrivalDate = widget.arrivalDate;
    returnDate = widget.returnDate;
    fromLocation = widget.fromLocation;
    toLocation = widget.toLocation;
    
    _tabController = TabController(
      length: hasReturnDate ? 2 : 1,
      vsync: this,
    );
    
    _pageController = PageController();
    _scrollController = ScrollController();
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
        subtitle: '${_getDayAbbreviation(arrivalDate, context)}, ${arrivalDate.day}/${arrivalDate.month}/${arrivalDate.year}',
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
                _buildPaymentPage(),
                _buildConfirmationPage(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
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
                  '${_getDayAbbreviation(arrivalDate, context)}, ${arrivalDate.day}/${arrivalDate.month}',
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
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passenger Information'),
            // Add your passenger info widgets
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment'),
            // Add your payment widgets
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
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