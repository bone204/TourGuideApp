import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';

class AddDestinationScreen extends StatefulWidget {
  final String routeTitle;
  final List<DestinationModel> currentDestinations;
  final String provinceName;

  const AddDestinationScreen({
    Key? key,
    required this.routeTitle,
    required this.currentDestinations,
    required this.provinceName,
  }) : super(key: key);

  @override
  State<AddDestinationScreen> createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
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
                          'Add Destination',
                          style: TextStyle(
                            color: AppColors.black,
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomSearchBar(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                hintText: 'Search destinations...',
              ),
            ),
            Expanded(
              child: Consumer<DestinationsViewModel>(
                builder: (context, viewModel, child) {
                  final availableDestinations = viewModel.destinations
                      .where((d) => 
                          d.province == widget.provinceName && 
                          !widget.currentDestinations.any((cd) => cd.destinationId == d.destinationId) &&
                          d.destinationName.toLowerCase().contains(searchQuery.toLowerCase()))
                      .toList();

                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (availableDestinations.isEmpty) {
                    return Center(
                      child: Text(
                        searchQuery.isEmpty 
                            ? 'No available destinations' 
                            : 'No destinations found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 161.w / 190.h,
                      mainAxisSpacing: 20.h,
                      crossAxisSpacing: 0,
                    ),
                    itemCount: availableDestinations.length,
                    itemBuilder: (context, index) {
                      final destination = availableDestinations[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, destination);
                        },
                        child: FavouriteCard(
                          data: FavouriteCardData(
                            imageUrl: destination.photo.isNotEmpty 
                                ? destination.photo[0] 
                                : 'assets/images/default.jpg',
                            placeName: destination.destinationName,
                            description: destination.province,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 