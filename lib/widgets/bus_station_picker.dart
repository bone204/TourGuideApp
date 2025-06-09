import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/bus_station_list.dart';

class BusStationPicker extends StatefulWidget {
  final Function(BusStation) onStationSelected;
  final BusStation? initialSelectedStation;

  const BusStationPicker({Key? key, required this.onStationSelected, this.initialSelectedStation}) : super(key: key);

  @override
  State<BusStationPicker> createState() => _BusStationPickerState();
}

class _BusStationPickerState extends State<BusStationPicker> {
  BusStation? selectedStation;

  @override
  void initState() {
    super.initState();
    selectedStation = widget.initialSelectedStation ?? BusStation(
      id: 1,
      name: 'Bến xe Miền Đông mới',
      address: '292 Đinh Bộ Lĩnh, Phường 26, Bình Thạnh, TP.HCM',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<BusStation>(
          context,
          MaterialPageRoute(
            builder: (context) => BusStationList(
              initialSelectedStation: selectedStation,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            selectedStation = result;
          });
          widget.onStationSelected(result);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.black, width: 1.5.w),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.grey),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedStation!.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
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
