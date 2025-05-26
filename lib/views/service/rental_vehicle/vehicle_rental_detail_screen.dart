import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/views/service/rental_vehicle/vehicle_rental_bill.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/info_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleRentalDetail extends StatefulWidget {
  final String model;
  final String imagePath;
  final DateTime startDate;
  final DateTime endDate;
  final String rentOption;
  final String pickupLocation;
  final double price;
  final String vehicleId;
  final String vehicleRegisterId;
  final double hour4Price;
  final double hour8Price;
  final double dayPrice;

  const VehicleRentalDetail({
    Key? key,
    required this.model,
    required this.imagePath,
    required this.startDate,
    required this.endDate,
    required this.rentOption,
    required this.pickupLocation,
    required this.price,
    required this.vehicleId,
    required this.vehicleRegisterId,
    required this.hour4Price,
    required this.hour8Price,
    required this.dayPrice,
  }) : super(key: key);

  @override
  State<VehicleRentalDetail> createState() => _VehicleRentalDetailState();
}

class _VehicleRentalDetailState extends State<VehicleRentalDetail> {
  String _getDayAbbreviation(DateTime date, BuildContext context) {
    List<String> daysVi = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    List<String> daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    String languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode == 'vi') {
      return daysVi[date.weekday % 7];
    } else {
      return daysEn[date.weekday % 7];
    }
  }

  String _getDurationText(BuildContext context, Duration duration) {
    String languageCode = Localizations.localeOf(context).languageCode;

    if (widget.rentOption == 'Hourly') {
      int hours = duration.inHours;
      if (languageCode == 'vi') {
        return "$hours ${hours == 1 ? 'giờ' : 'giờ'}";
      } else {
        return "$hours ${hours == 1 ? 'hour' : 'hours'}";
      }
    } else {
      int days = duration.inDays + 1;
      if (languageCode == 'vi') {
        return "$days ${days == 1 ? 'ngày' : 'ngày'}";
      } else {
        return "$days ${days == 1 ? 'day' : 'days'}";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                        AppLocalizations.of(context).translate(widget.model),
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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<RentalVehicleViewModel>(
              builder: (context, viewModel, child) {
                print('VehicleID in RentalDetail: ${widget.vehicleId}');
                return FutureBuilder<String>(
                  future: viewModel.getVehiclePhoto(widget.vehicleId),
                  builder: (context, snapshot) {
                    print('Photo URL: ${snapshot.data}');
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final imageUrl =
                        snapshot.data ?? 'assets/img/car_default.png';
                    return Center(
                      child: ClipRRect(
                        child: imageUrl.startsWith('assets/')
                            ? Image.asset(
                                imageUrl,
                                height: 140.h,
                                width: 260.w,
                                fit: BoxFit.fill,
                              )
                            : Image.network(
                                imageUrl,
                                height: 140.h,
                                width: 260.w,
                                fit: BoxFit.fill,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return Image.asset(
                                    'assets/img/car_default.png',
                                    height: 140.h,
                                    width: 260.w,
                                    fit: BoxFit.fill,
                                  );
                                },
                              ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).translate("Specs"),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12.h),
            SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              child: Consumer<RentalVehicleViewModel>(
                builder: (context, viewModel, child) {
                  final locale = Localizations.localeOf(context).languageCode;
                  return FutureBuilder<Map<String, dynamic>>(
                    future:
                        viewModel.getVehicleDetails(widget.vehicleId, locale),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final details = snapshot.data ??
                          {
                            'fuelType': '',
                            'transmission': '',
                            'maxSpeed': '',
                          };

                      return Row(
                        children: [
                          _buildInteractiveRow(
                            context,
                            AppLocalizations.of(context).translate("Fuel Type"),
                            details['fuelType'] ?? '',
                          ),
                          SizedBox(width: 16.w),
                          _buildInteractiveRow(
                            context,
                            AppLocalizations.of(context)
                                .translate("Transmission"),
                            details['transmission'] ?? '',
                          ),
                          SizedBox(width: 16.w),
                          _buildInteractiveRow(
                            context,
                            AppLocalizations.of(context).translate("Max Speed"),
                            details['maxSpeed'] ?? '',
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 26.h),
            InfoTextField(
              size: 335,
              labelText: AppLocalizations.of(context).translate("Location"),
              text: widget.pickupLocation,
              icon: Icons.location_on_outlined,
            ),
            SizedBox(height: 26.h),
            Row(
              children: [
                InfoTextField(
                  size: 186,
                  labelText:
                      AppLocalizations.of(context).translate("Start Date"),
                  text:
                      "${_getDayAbbreviation(widget.startDate, context)}, ${widget.startDate.day.toString().padLeft(2, '0')}/${widget.startDate.month.toString().padLeft(2, '0')}/${widget.startDate.year}",
                  icon: Icons.calendar_month,
                ),
                SizedBox(width: 11.h),
                InfoTextField(
                  size: 137,
                  labelText: AppLocalizations.of(context).translate("Duration"),
                  text: _getDurationText(
                      context, widget.endDate.difference(widget.startDate)),
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
            SizedBox(height: 26.h),
            Row(
              children: [
                InfoTextField(
                  size: 186,
                  labelText: AppLocalizations.of(context).translate("End Date"),
                  text:
                      "${_getDayAbbreviation(widget.endDate, context)}, ${widget.endDate.day.toString().padLeft(2, '0')}/${widget.endDate.month.toString().padLeft(2, '0')}/${widget.endDate.year}",
                  icon: Icons.calendar_month,
                ),
                SizedBox(width: 11.h),
                InfoTextField(
                  size: 137,
                  labelText:
                      AppLocalizations.of(context).translate("Pick-up Time"),
                  text: "08:00 AM",
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
            SizedBox(height: 26.h),
            ElevatedButton(
                onPressed: () async {
                  try {
                    final auth = FirebaseAuth.instance;
                    final currentUser = auth.currentUser;

                    if (currentUser != null) {
                      final userDoc = await FirebaseFirestore.instance
                          .collection('USER')
                          .where('uid', isEqualTo: currentUser.uid)
                          .get();

                      if (userDoc.docs.isNotEmpty) {
                        final userId = userDoc.docs.first['userId'];

                        // Tạo bill ban đầu
                        final billId =
                            await Provider.of<RentalVehicleViewModel>(context,
                                    listen: false)
                                .createInitialBill(
                          userId: userId,
                          vehicleRegisterId: widget.vehicleRegisterId,
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          rentOption: widget.rentOption,
                          total: widget.price,
                        );

                        if (mounted) {
                          // Chuyển đến màn hình thanh toán với billId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleRentalBill(
                                billId: billId,
                                model: widget.model,
                                vehicleId: widget.vehicleId,
                                vehicleRegisterId: widget.vehicleRegisterId,
                                startDate: widget.startDate,
                                endDate: widget.endDate,
                                rentOption: widget.rentOption,
                                price: widget.price,
                                pickupLocation: widget.pickupLocation,
                              ),
                            ),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print('Error creating bill: $e');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text(AppLocalizations.of(context).translate("Confirm"),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ))),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveRow(
      BuildContext context, String title, String detail) {
    return Container(
      width: 155.w,
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0ff00000).withOpacity(0.25),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 110.w,
            child: Text(
              detail,
              style: TextStyle(fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
