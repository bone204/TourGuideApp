import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/blocs/travel/travel_bloc.dart';
import 'package:tourguideapp/blocs/travel/travel_event.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/views/service/travel/destination_detail_add_page.dart';
import 'package:tourguideapp/blocs/destination/destination_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDestinationScreen extends StatelessWidget {
  final String provinceName;
  final String? existingRouteId;

  const AddDestinationScreen({
    Key? key,
    required this.provinceName,
    this.existingRouteId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DestinationBloc(
        firestore: FirebaseFirestore.instance,
      )..add(LoadDestinationsByProvince(provinceName)),
      child: AddDestinationScreenContent(
        provinceName: provinceName,
        existingRouteId: existingRouteId,
      ),
    );
  }
}

class AddDestinationScreenContent extends StatefulWidget {
  final String provinceName;
  final String? existingRouteId;

  const AddDestinationScreenContent({
    Key? key,
    required this.provinceName,
    this.existingRouteId,
  }) : super(key: key);

  @override
  State<AddDestinationScreenContent> createState() => _AddDestinationScreenContentState();
}

class _AddDestinationScreenContentState extends State<AddDestinationScreenContent> {
  String _searchQuery = '';

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
            child: BlocBuilder<DestinationBloc, DestinationState>(
              builder: (context, state) {
                if (state is DestinationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DestinationLoaded) {
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<TravelBloc>(),
                                child: DestinationDetailAddPage(
                                  destination: destination,
                                  onAddPressed: () {
                                    final bloc = context.read<TravelBloc>();
                                    bloc.add(
                                      AddDestinationToRoute(
                                        destination,
                                        existingRouteId: widget.existingRouteId,
                                      ),
                                    );
                                    
                                    // Pop cả 2 màn hình và reload destinations
                                    Navigator.of(context).pop(); // Pop DestinationDetailAddPage
                                    Navigator.of(context).pop(); // Pop AddDestinationScreen
                                    
                                    // Reload destinations sau khi thêm
                                    if (widget.existingRouteId != null) {
                                      bloc.add(LoadRouteDestinations(widget.existingRouteId!));
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: FavouriteCard(
                          data: FavouriteCardData(
                            imageUrl: destination.photo.isNotEmpty
                                ? destination.photo[0]
                                : 'assets/img/default_destination.png',
                            placeName: destination.destinationName,
                            description: destination.province,
                          ),
                        ),
                      );
                    },
                  );
                }

                if (state is DestinationError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DestinationBloc>()
                              .add(LoadDestinationsByProvince(widget.provinceName));
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
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