import 'package:flutter/material.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusStationList extends StatefulWidget {
  final BusStation? initialSelectedStation;

  const BusStationList({Key? key, this.initialSelectedStation}) : super(key: key);

  @override
  _BusStationListState createState() => _BusStationListState();
}

class _BusStationListState extends State<BusStationList> {
  int? selectedOption;
  final TextEditingController _searchController = TextEditingController();
  List<BusStation> filteredStations = [];

  // Thêm hàm chuyển đổi text có dấu thành không dấu
  String _removeDiacritics(String str) {
    var vietnamese = 'aAeEoOuUiIdDyYáàạảãâấầậẩẫăắằặẳẵéèẹẻẽêếềệểễóòọỏõôốồộổỗơớờợởỡúùụủũưứừựửữíìịỉĩýỳỵỷỹđĐ';
    var latin = 'aAeEoOuUiIdDyYaaaaaaaaaaaaaaaaaeeeeeeeeeeeoooooooooooooooooouuuuuuuuuuuiiiiiyyyyydD';
    for (int i = 0; i < vietnamese.length; i++) {
      str = str.replaceAll(vietnamese[i], latin[i]);
    }
    return str;
  }

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
      name: 'Văn phòng Traveline Quận 1',
      address: '272 Đề Thám, Phường Phạm Ngũ Lão, Quận 1, TP.HCM',
    ),
    BusStation(
      id: 4,
      name: 'Văn phòng Traveline Quận 5',
      address: '168 Trần Hưng Đạo, Phường 7, Quận 5, TP.HCM',
    ),
    BusStation(
      id: 5,
      name: 'Văn phòng Traveline Tân Bình',
      address: '91 Cộng Hòa, Phường 4, Tân Bình, TP.HCM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedOption = widget.initialSelectedStation?.id ?? busStations.first.id;
    filteredStations = busStations;
  }

  void _filterStations(String query) {
    setState(() {
      String normalizedQuery = _removeDiacritics(query.toLowerCase());
      filteredStations = busStations
          .where((station) =>
              _removeDiacritics(station.name.toLowerCase()).contains(normalizedQuery) ||
              _removeDiacritics(station.address.toLowerCase()).contains(normalizedQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: "Bus Station List",
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: "Search bus stations...",
              onChanged: _filterStations,
              margin: EdgeInsets.symmetric(vertical: 16.h),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: filteredStations.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) => RadioListTile<int>(
                value: filteredStations[index].id,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                  Navigator.pop(context, filteredStations[index]);
                },
                title: Text(
                  filteredStations[index].name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  filteredStations[index].address,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  side: BorderSide(color: AppColors.primaryColor, width: 1.5.w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BusStation {
  final int id;
  final String name;
  final String address;

  BusStation({
    required this.id,
    required this.name,
    required this.address,
  });
}

