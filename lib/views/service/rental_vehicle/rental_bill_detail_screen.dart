import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentalBillDetailScreen extends StatefulWidget {
  final String model;
  final String vehicleId;
  final String vehicleRegisterId;
  final String startDate;
  final String endDate;
  final String rentOption;
  final double price;

  const RentalBillDetailScreen({
    super.key,
    required this.model,
    required this.vehicleId,
    required this.vehicleRegisterId,
    required this.startDate,
    required this.endDate,
    required this.rentOption,
    required this.price,
  });

  @override
  State<RentalBillDetailScreen> createState() => _RentalBillDetailScreenState();
}

class _RentalBillDetailScreenState extends State<RentalBillDetailScreen> {
  String? customerName;
  String? customerPhone;
  String? ownerName;
  String? ownerPhone;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      
      // Lấy thông tin khách hàng
      final userDoc = await firestore
          .collection('USER')
          .where('uid', isEqualTo: auth.currentUser?.uid)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          customerName = userDoc.docs.first['fullName'];
          customerPhone = userDoc.docs.first['phoneNumber'];
        });
      }

      // Lấy thông tin chủ xe
      final vehicleDoc = await firestore
          .collection('RENTAL_VEHICLE')
          .doc(widget.vehicleRegisterId)
          .get();

      if (vehicleDoc.exists) {
        final contractId = vehicleDoc.data()?['contractId'];
        if (contractId != null) {
          final contractDoc = await firestore
              .collection('CONTRACT')
              .doc(contractId)
              .get();

          if (contractDoc.exists) {
            final ownerId = contractDoc.data()?['userId'];
            if (ownerId != null) {
              final ownerDoc = await firestore
                  .collection('USER')
                  .where('userId', isEqualTo: ownerId)
                  .get();

              if (ownerDoc.docs.isNotEmpty) {
                setState(() {
                  ownerName = ownerDoc.docs.first['fullName'];
                  ownerPhone = ownerDoc.docs.first['phoneNumber'];
                });
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error loading user details: $e');
    }
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          AppLocalizations.of(context).translate("Customer:"),
          customerName ?? AppLocalizations.of(context).translate('Loading...'),
        ),
        SizedBox(height: 18.h),
        _buildInfoRow(
          AppLocalizations.of(context).translate("Phone Number:"),
          customerPhone ?? AppLocalizations.of(context).translate('Loading...'),
        ),
        SizedBox(height: 18.h),
        _buildInfoRow(
          AppLocalizations.of(context).translate("Owner:"),
          ownerName ?? AppLocalizations.of(context).translate('Loading...'),
        ),
        SizedBox(height: 18.h),
        _buildInfoRow(
          AppLocalizations.of(context).translate("Phone Number:"),
          ownerPhone ?? AppLocalizations.of(context).translate('Loading...'),
        ),
      ],
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Text(
                        AppLocalizations.of(context).translate('Rental Information'),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
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
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child: Column(
              children: [
                _buildVehicleInfo(context),
                SizedBox(height: 16.h),
                const Divider(thickness: 1, color: AppColors.grey),
                SizedBox(height: 16.h),
                _buildUserInfo(context),
                SizedBox(height: 16.h),
                const Divider(thickness: 1, color: AppColors.grey),
                SizedBox(height: 16.h),
                _buildRentalInfo(context),
                SizedBox(height: 16.h),
                const Divider(thickness: 1, color: AppColors.grey),
                SizedBox(height: 16.h),
                _buildPriceInfo(context),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('Payment Completed'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context) {
    return Row(
      children: [
        Consumer<RentalVehicleViewModel>(
          builder: (context, viewModel, child) {
            return FutureBuilder<String>(
              future: viewModel.getVehiclePhoto(widget.vehicleId),
              builder: (context, snapshot) {
                final imagePath = snapshot.data ?? 'assets/img/icon-cx3.png';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: SizedBox(
                    width: 184.w,
                    height: 144.h,
                    child: imagePath.startsWith('assets/')
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Image.network(
                            imagePath,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                  ),
                );
              },
            );
          },
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.model,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "${AppLocalizations.of(context).formatPrice(widget.price)} ₫",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRentalInfo(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          AppLocalizations.of(context).translate("Selected:"),
          "1"
        ),
        SizedBox(height: 18.h),
        _buildInfoRow(
          widget.rentOption == 'Hourly' 
            ? AppLocalizations.of(context).translate("Hours:") 
            : AppLocalizations.of(context).translate("Days:"),
          widget.rentOption == 'Hourly'
              ? "${DateTime.parse(widget.endDate).difference(DateTime.parse(widget.startDate)).inHours}"
              : "${DateTime.parse(widget.endDate).difference(DateTime.parse(widget.startDate)).inDays + 1}",
        ),
      ],
    );
  }

  Widget _buildPriceInfo(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          AppLocalizations.of(context).translate("Price:"),
          "${AppLocalizations.of(context).formatPrice(widget.price)} ₫",
        ),
        SizedBox(height: 16.h),
        _buildInfoRow(
          AppLocalizations.of(context).translate("Total:"),
          "${AppLocalizations.of(context).formatPrice(widget.price)} ₫",
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 