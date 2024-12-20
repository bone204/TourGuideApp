import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/delivery_interactive_row.dart';
import 'package:tourguideapp/widgets/image_picker.dart';

class DeliveryDetailScreen extends StatefulWidget {
  DeliveryDetailScreen({super.key});

  @override
  _DeliveryDetailScreenState createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  final GlobalKey _contentKey = GlobalKey();
  double _contentHeight = 0;
  final TextEditingController _noteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _contentHeight = renderBox.size.height;
        });
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
                        AppLocalizations.of(context).translate('Delivery Detail'),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withOpacity(0.25),
                      blurRadius: 4.r,
                      offset: const Offset(0, 2),
                    ),
                  ]
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildDeliveryLocations(),
                      SizedBox(height: 24.h),
                      const Divider(
                        thickness: 1,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: 24.h),
                      DeliveryInteractiveRow(
                        imageUrl: 'assets/img/ic_delivery_brand.png',
                        title: "Lalamove",
                        subtitle: "Delivery between November 16 - November 20",
                        trailingIcon: Icons.chevron_right,
                        onTap: () => {},
                      ),
                      SizedBox(height: 24.h),
                      const Divider(
                        thickness: 1,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: 24.h),
                      DeliveryInteractiveRow(
                        imageUrl: 'assets/img/ic_delivery_vehicle_type.png',
                        title: "Motorbike",
                        subtitle: "Maximum weight: 30 kg (50x40x50 cm)",
                        trailingIcon: Icons.chevron_right,
                        onTap: () => {},
                      ),
                    ]
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              ImagePickerWidget(
                title: AppLocalizations.of(context).translate("Package Photos"),
                isRequired: true,
                onImagePicked: (String imagePath) {
                  // TODO: Xử lý khi ảnh được chọn
                  print('Selected image path: $imagePath');
                },
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).translate("Requirements"),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    " (*)",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              CustomExpandableTextField(
                hintText: AppLocalizations.of(context).translate("Enter note for delivery"),
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildDeliveryLocations() {
    return Column(
      key: _contentKey,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(Icons.location_pin, color: AppColors.primaryColor, size: 24.sp),
                if (_contentHeight > 0)
                  SizedBox(
                    width: 1.w,
                    height: _contentHeight - 48.sp,
                    child: CustomPaint(
                      painter: DashedLinePainter(color: AppColors.primaryColor),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Trần Trung Thông",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black
                        )
                      ),
                      Text(
                        "0971 072 923",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Bcons Sala, Phan Boi Chau Street, Di An City, Binh Duong Province",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.black,
                    ),
                    softWrap: true,
                    maxLines: null,
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_pin, color: AppColors.orange, size: 24.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nguyễn Văn A",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black
                        )
                      ),
                      Text(
                        "0123 456 789",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.grey
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "123 Nguyen Van B Street, District 1, Ho Chi Minh City",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.black,
                    ),
                    softWrap: true,
                    maxLines: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom Painter để vẽ đường nét đứt
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashHeight = 3;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}