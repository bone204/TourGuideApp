import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/delivery_interactive_row.dart';
import 'package:tourguideapp/widgets/delivery_option_item.dart';
import 'package:tourguideapp/widgets/image_picker.dart';

class DeliveryDetailScreen extends StatefulWidget {
  const DeliveryDetailScreen({super.key});

  @override
  _DeliveryDetailScreenState createState() => _DeliveryDetailScreenState();
}

// Định nghĩa class cho delivery brand bên ngoài State class
class DeliveryBrand {
  final String id;
  final String name;
  final String image;
  final String description;

  const DeliveryBrand({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });
}

class VehicleType {
  final String id;
  final String name;
  final String image;
  final String description;

  const VehicleType({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
  });
}


class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  final GlobalKey _contentKey = GlobalKey();
  double _contentHeight = 0;
  final TextEditingController _noteController = TextEditingController();
  String selectedBrandId = 'lalamove';
  String selectedVehicleId = 'motorbike';

  // Danh sách các brands
  final List<DeliveryBrand> deliveryBrands = const [
    DeliveryBrand(
      id: 'jt',
      name: 'J&T Express',
      image: 'assets/img/Logo_J&TExpress.png',
      description: 'JT Express offers fast and reliable delivery services across Vietnam and beyond with advanced technology',
    ),
    DeliveryBrand(
      id: 'lalamove',
      name: 'Lalamove', 
      image: 'assets/img/Logo_Lalamove.png',
      description: 'Lalamove provides on-demand, same-day delivery with flexible and affordable logistics solutions',
    ),
    DeliveryBrand(
      id: 'ghtk',
      name: 'GHTK',
      image: 'assets/img/Logo_GHTK.png',
      description: 'GHTK offers cost-effective, timely delivery solutions with wide coverage across Vietnam',
    ),
    DeliveryBrand(
      id: 'nhattin',
      name: 'Nhat Tin Express',
      image: 'assets/img/Logo_NhatTin.png',
      description: 'Nhat Tin Express delivers fast, safe, and professional logistics services nationwide',
    ),
  ];

  final List<VehicleType> vehicleTypes = const [
    VehicleType(
      id: 'motorbike',
      name: 'Motorbike',
      image: 'assets/img/ic_motorbike.png',
      description: 'Maximum cargo capacity of 30 kilograms\nMaximun dimensions of 0.5 x 0.4 x 0.5 meters',
    ),
    VehicleType(
      id: 'van500',
      name: 'Van 500kg',
      image: 'assets/img/ic_truck.png',
      description: 'Maximum cargo capacity of 500 kilograms\nMaximun dimensions of 1.7 x 1.2 x 1.2 meters',
    ),
    VehicleType(
      id: 'van750',
      name: 'Van 500kg',
      image: 'assets/img/ic_truck.png',
      description: 'Maximum cargo capacity of 750 kilograms\nMaximun dimensions of 2.1 x 1.3 x 1.3 meters',
    ),
    VehicleType(
      id: 'van1000',
      name: 'Van 1000kg',
      image: 'assets/img/ic_truck.png',
      description: 'Maximum cargo capacity of 1000 kilograms\nMaximun dimensions of 2.1 x 1.3 x 1.3 meters',
    ),
  ];

  // Lấy brand đang được chọn
  DeliveryBrand get selectedBrand => 
    deliveryBrands.firstWhere((brand) => brand.id == selectedBrandId);

    // Lấy vehicle type đang được chọn
  VehicleType get selectedVehicle => 
    vehicleTypes.firstWhere((types) => types.id == selectedVehicleId);

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

  void _showDeliveryBrandSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.black54),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Brand',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: deliveryBrands.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final brand = deliveryBrands[index];
                          return DeliveryOptionItem(
                            option: DeliveryOption(
                              id: brand.id,
                              name: brand.name,
                              image: brand.image,
                              description: brand.description,
                            ),
                            isSelected: selectedBrandId == brand.id,
                            onTap: () {
                              setState(() {
                                selectedBrandId = brand.id;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleTypeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.black54),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Vehicles',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: vehicleTypes.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final types = vehicleTypes[index];
                          return DeliveryOptionItem(
                            option: DeliveryOption(
                              id: types.id,
                              name: types.name,
                              image: types.image,
                              description: types.description,
                            ),
                            isSelected: selectedVehicleId == types.id,
                            onTap: () {
                              setState(() {
                                selectedVehicleId = types.id;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                        title: selectedBrand.name,
                        subtitle: "Delivery between November 16 - November 20",
                        trailingIcon: Icons.chevron_right,
                        isSelected: true,
                        onTap: _showDeliveryBrandSelector,
                      ),
                      SizedBox(height: 24.h),
                      const Divider(
                        thickness: 1,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: 24.h),
                      DeliveryInteractiveRow(
                        imageUrl: 'assets/img/ic_delivery_vehicle_type.png',
                        title: selectedVehicle.name,
                        subtitle: "Maximum weight: 30 kg (50x40x50 cm)",
                        trailingIcon: Icons.chevron_right,
                        isSelected: true,
                        onTap: _showVehicleTypeSelector,
                      ),
                    ],
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