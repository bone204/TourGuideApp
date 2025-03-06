import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/blocs/travel/travel_bloc.dart';
import 'package:tourguideapp/blocs/travel/travel_event.dart';
import 'package:tourguideapp/blocs/travel/travel_state.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';

class AddDestinationScreen extends StatefulWidget {
  final String provinceName;

  const AddDestinationScreen({
    Key? key,
    required this.provinceName,
  }) : super(key: key);

  @override
  State<AddDestinationScreen> createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TravelBloc>().add(LoadDestinations(widget.provinceName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('Add Destination'),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: CustomSearchBar(
              hintText: AppLocalizations.of(context).translate('Search destinations...'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<TravelBloc, TravelState>(
              builder: (context, state) {
                if (state is TravelLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DestinationsLoaded) {
                  final filteredDestinations = state.destinations
                      .where((d) => d.destinationName
                          .toLowerCase()
                          .contains(_searchQuery))
                      .toList();

                  if (filteredDestinations.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No destinations available'
                            : 'No results found',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 161.w / 185.h,
                      mainAxisSpacing: 20.h,
                    ),
                    itemCount: filteredDestinations.length,
                    itemBuilder: (context, index) {
                      final destination = filteredDestinations[index];
                      return FavouriteCard(
                        data: FavouriteCardData(
                          imageUrl: destination.photo.isNotEmpty
                              ? destination.photo[0]
                              : 'assets/img/default_destination.png',
                          placeName: destination.destinationName,
                          description: destination.province,
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:tourguideapp/color/colors.dart';
// import 'package:tourguideapp/localization/app_localizations.dart';
// import 'package:tourguideapp/models/destination_model.dart';
// import 'package:tourguideapp/widgets/custom_icon_button.dart';
// import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
// import 'package:provider/provider.dart';
// import 'package:tourguideapp/widgets/custom_search_bar.dart';
// import 'package:tourguideapp/widgets/favourite_card.dart';
// import 'package:tourguideapp/views/service/travel/destination_detail_add_page.dart';

// class AddDestinationScreen extends StatefulWidget {
//   final String routeTitle;
//   final List<DestinationModel> currentDestinations;
//   final String provinceName;
//   final Function(DestinationModel) onAddDestination;

//   const AddDestinationScreen({
//     Key? key,
//     required this.routeTitle,
//     required this.currentDestinations,
//     required this.provinceName,
//     required this.onAddDestination,
//   }) : super(key: key);

//   @override
//   State<AddDestinationScreen> createState() => _AddDestinationScreenState();
// }

// class _AddDestinationScreenState extends State<AddDestinationScreen> {
//   String searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(60.h),
//           child: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             automaticallyImplyLeading: false,
//             scrolledUnderElevation: 0,
//             shadowColor: Colors.transparent,
//             surfaceTintColor: Colors.transparent,
//             flexibleSpace: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 SizedBox(
//                   height: 40.h,
//                   child: Stack(
//                     children: [
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: CustomIconButton(
//                           icon: Icons.chevron_left,
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ),
//                       Center(
//                         child: Text(
//                           AppLocalizations.of(context).translate('Add Destination'),
//                           style: TextStyle(
//                             color: AppColors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20.sp,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               child: CustomSearchBar(
//                 onChanged: (value) {
//                   setState(() {
//                     searchQuery = value;
//                   });
//                 },
//                 hintText: AppLocalizations.of(context).translate('Search destinations...'),
//               ),
//             ),
//             Expanded(
//               child: Consumer<DestinationsViewModel>(
//                 builder: (context, viewModel, child) {
//                   final availableDestinations = viewModel.destinations
//                       .where((d) => 
//                           d.province == widget.provinceName && 
//                           !widget.currentDestinations.any((cd) => cd.destinationId == d.destinationId) &&
//                           d.destinationName.toLowerCase().contains(searchQuery.toLowerCase()))
//                       .toList();

//                   if (viewModel.isLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (availableDestinations.isEmpty) {
//                     return Center(
//                       child: Text(
//                         searchQuery.isEmpty 
//                             ? AppLocalizations.of(context).translate('No available destinations')
//                             : AppLocalizations.of(context).translate('No results found'),
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     );
//                   }

//                   return GridView.builder(
//                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 161.w / 190.h,
//                       mainAxisSpacing: 20.h,
//                       crossAxisSpacing: 0,
//                     ),
//                     itemCount: availableDestinations.length,
//                     itemBuilder: (context, index) {
//                       final destination = availableDestinations[index];
//                       return GestureDetector(
//                         onTap: () async {
//                           final confirmed = await Navigator.push<bool>(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => DestinationDetailAddPage(
//                                 destination: destination,
//                                 onAddPressed: () {
//                                   Navigator.pop(context, true);
//                                 },
//                               ),
//                             ),
//                           );

//                           if (confirmed == true) {
//                             Navigator.pop(context, destination);
//                           }
//                         },
//                         child: FavouriteCard(
//                           data: FavouriteCardData(
//                             imageUrl: destination.photo.isNotEmpty 
//                                 ? destination.photo[0] 
//                                 : 'assets/images/default.jpg',
//                             placeName: destination.destinationName,
//                             description: destination.province,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// } 