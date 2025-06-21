import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/views/service/travel/destination_bloc/desination_event.dart';
import 'package:tourguideapp/views/service/travel/destination_bloc/destination_state.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_bloc.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_event.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/views/service/travel/destination_detail_add_page.dart';
import 'package:tourguideapp/views/service/travel/destination_bloc/destination_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDestinationScreen extends StatelessWidget {
  final String provinceName;
  final String? existingRouteId;
  final int maxDestinations;

  const AddDestinationScreen({
    Key? key,
    required this.provinceName,
    this.existingRouteId,
    this.maxDestinations = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DestinationBloc(
        firestore: FirebaseFirestore.instance,
      )..add(LoadDestinationsByProvinceWithLimit(provinceName, maxDestinations)),
      child: AddDestinationScreenContent(
        provinceName: provinceName,
        existingRouteId: existingRouteId,
        maxDestinations: maxDestinations,
      ),
    );
  }
}

class AddDestinationScreenContent extends StatefulWidget {
  final String provinceName;
  final String? existingRouteId;
  final int maxDestinations;

  const AddDestinationScreenContent({
    Key? key,
    required this.provinceName,
    this.existingRouteId,
    required this.maxDestinations,
  }) : super(key: key);

  @override
  State<AddDestinationScreenContent> createState() => _AddDestinationScreenContentState();
}

class _AddDestinationScreenContentState extends State<AddDestinationScreenContent> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load thêm khi scroll đến gần cuối (còn 200px)
      final state = context.read<DestinationBloc>().state;
      if (state is DestinationLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<DestinationBloc>().add(
          LoadMoreDestinations(
            widget.provinceName,
            widget.maxDestinations,
            lastDocument: state.lastDocument,
          ),
        );
      }
    }
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
            child: BlocBuilder<DestinationBloc, DestinationState>(
              builder: (context, state) {
                if (state is DestinationLoading && state is! DestinationLoaded) {
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _searchQuery.isEmpty
                                ? AppLocalizations.of(context).translate('No destinations available')
                                : AppLocalizations.of(context).translate('No results found'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              AppLocalizations.of(context).translate('Try different keywords'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DestinationBloc>().add(
                        RefreshDestinations(widget.provinceName, limit: widget.maxDestinations),
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.only(left: 20.w, top: 10.h, right: 20.w, bottom: 20.h),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 161.w / 190.h,
                              mainAxisSpacing: 10.h,
                              crossAxisSpacing: 10.w,
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
                          ),
                        ),
                        // Hiển thị loading indicator khi đang load thêm
                        if (state.isLoadingMore)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(strokeWidth: 2.w),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  AppLocalizations.of(context).translate('Loading more...'),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }

                if (state is DestinationError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: Colors.red[300],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<DestinationBloc>()
                              .add(LoadDestinationsByProvinceWithLimit(widget.provinceName, widget.maxDestinations));
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context).translate('Try Again')),
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