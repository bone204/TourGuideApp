import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/bus_ticket.dart';
import 'package:tourguideapp/widgets/category_selector.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/color/colors.dart';

class BusListScreen extends StatefulWidget {
  final DateTime arrivalDate;
  final DateTime? returnDate;
  final String fromLocation;
  final String toLocation;

  const BusListScreen({
    super.key,
    required this.arrivalDate,
    this.returnDate,
    required this.fromLocation,
    required this.toLocation,
  });

  @override
  _BusListScreenState createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> with SingleTickerProviderStateMixin {
  late DateTime arrivalDate;
  late DateTime? returnDate;
  late String fromLocation;
  late String toLocation;
  late TabController _tabController;
  bool get hasReturnDate => returnDate != null;

  String selectedCriteria = 'All';
  final List<String> criterias = ['All', 'Price', 'Time', 'Rating'];
  void onCriteriaSelected(String criteria) {
    setState(() {
      selectedCriteria = criteria;
    });
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Column(
          children: [
            if (hasReturnDate)
              Container(
                color: Colors.white,
                height: 60.h,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorWeight: 3.h,
                  indicatorColor: AppColors.primaryColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      child: FittedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('Arrival Date'),
                              style: TextStyle(fontSize: 24.sp),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${_getDayAbbreviation(arrivalDate, context)}, ${arrivalDate.day}/${arrivalDate.month}/${arrivalDate.year}',
                              style: TextStyle(fontSize: 32.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('Return Date'),
                              style: TextStyle(fontSize: 24.sp),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${_getDayAbbreviation(returnDate!, context)}, ${returnDate?.day}/${returnDate?.month}/${returnDate?.year}',
                              style: TextStyle(fontSize: 32.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: CategorySelector(
                selectedCategory: selectedCriteria,
                categories: criterias,
                onCategorySelected: onCriteriaSelected,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Departure Tab
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: BusTicket(
                        fromLocation: fromLocation, 
                        toLocation: toLocation, 
                        arrivalDate: arrivalDate,
                        returnDate: returnDate,
                      )
                    ),
                  ),
                  if (hasReturnDate)
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$toLocation → $fromLocation',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            DateTimePicker(
                              selectedDate: returnDate!,
                              onDateSelected: (date) {
                                setState(() {
                                  returnDate = date;
                                });
                              },
                              title: AppLocalizations.of(context).translate("Return Date"),
                              minDate: arrivalDate,
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}