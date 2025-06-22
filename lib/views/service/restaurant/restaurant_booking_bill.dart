import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/models/table_availability_model.dart';
import 'package:tourguideapp/models/restaurant_bill_model.dart';
import 'package:tourguideapp/core/services/restaurant_service.dart';
import 'package:intl/intl.dart';

class RestaurantBookingBillScreen extends StatefulWidget {
  final CooperationModel restaurant;
  final TableAvailabilityModel table;
  final DateTime checkInDate;
  final TimeOfDay checkInTime;
  final int numberOfPeople;

  const RestaurantBookingBillScreen({
    super.key,
    required this.restaurant,
    required this.table,
    required this.checkInDate,
    required this.checkInTime,
    required this.numberOfPeople,
  });

  @override
  State<RestaurantBookingBillScreen> createState() =>
      _RestaurantBookingBillScreenState();
}

class _RestaurantBookingBillScreenState
    extends State<RestaurantBookingBillScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final currencyFormat = NumberFormat('#,###', 'vi_VN');
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    // TODO: Pre-fill with user data if available
    _customerNameController.text = 'Nguyễn Hữu Trường';
    _customerPhoneController.text = '0914259475';
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    if (_customerNameController.text.isEmpty ||
        _customerPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate("Please enter complete information")),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Gọi API đặt bàn
      final isSuccess = await _restaurantService.bookTable(
        restaurantId: widget.restaurant.cooperationId,
        tableId: widget.table.tableId,
        checkInDate: widget.checkInDate,
        checkInTime: widget.checkInTime,
        numberOfPeople: widget.numberOfPeople,
      );

      if (isSuccess) {
        // Tạo bill trong Firestore
        final bill = RestaurantBillModel(
          billId: '', // sẽ generate khi lưu
          userId: 'current_user_id', 
          restaurantId: widget.restaurant.cooperationId,
          tableId: widget.table.tableId,
          customerName: _customerNameController.text,
          customerPhone: _customerPhoneController.text,
          checkInDate: widget.checkInDate,
          checkInTime: widget.checkInTime,
          numberOfPeople: widget.numberOfPeople,
          totalPrice: widget.table.price,
          status: 'pending',
          createdDate: DateTime.now(),
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        await _restaurantService.createRestaurantBooking(bill);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate("Table booking successful!")),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate("Table booking failed. Please try again.")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).translate("Error")}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
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
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
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
                          AppLocalizations.of(context)
                              .translate('Booking Information'),
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
        body: SingleChildScrollView(
          child: Container(
            color: AppColors.white,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.h, right: 20.w, left: 20.w, top: 20.h),
              child: Column(children: [
                // Restaurant image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    widget.restaurant.photo,
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16.h),

                // Restaurant info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.restaurant.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.restaurant.averageRating.floor()
                              ? Icons.star
                              : (index < widget.restaurant.averageRating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 16.sp,
                        );
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.restaurant.address,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 16.h),
                const Divider(thickness: 1, color: AppColors.grey),
                SizedBox(height: 16.h),

                // Table info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).translate("Table:"),
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text(widget.table.tableName,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).translate("Location:"),
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text(widget.table.location,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).translate("Capacity:"),
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text('${widget.table.capacity} ' + AppLocalizations.of(context).translate('people'),
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).translate("Price:"),
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text('${currencyFormat.format(widget.table.price)} ' + AppLocalizations.of(context).translate('currency'),
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),

                SizedBox(height: 16.h),
                const Divider(thickness: 1, color: AppColors.grey),
                SizedBox(height: 16.h),

                // Booking details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).translate("Date:"),
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text(
                        "${widget.checkInDate.day.toString().padLeft(2, '0')}/${widget.checkInDate.month.toString().padLeft(2, '0')}/${widget.checkInDate.year}",
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).translate("Time:"),
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text(
                        "${widget.checkInTime.hour.toString().padLeft(2, '0')}:${widget.checkInTime.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).translate("Number of people:"),
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text('${widget.numberOfPeople} ' + AppLocalizations.of(context).translate('people'),
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),

                SizedBox(height: 24.h),

                // Customer info
                TextField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate("Customer name"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _customerPhoneController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate("Phone number"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate("Note (optional)"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  maxLines: 3,
                ),

                SizedBox(height: 24.h),
                ElevatedButton(
                    onPressed: _isBooking ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: _isBooking
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppLocalizations.of(context).translate("Confirm"),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ))),
              ]),
            ),
          ),
        ));
  }
}
