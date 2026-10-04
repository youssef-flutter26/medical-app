import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/location/presentation/cubit/location_cubit.dart';
import 'package:medical_app/features/location/presentation/cubit/location_state.dart';
import 'package:medical_app/features/location/presentation/widgets/location_search_bar.dart';
import 'package:medical_app/features/location/presentation/widgets/medical_map.dart';
import 'package:medical_app/features/location/presentation/widgets/medical_place_card.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with WidgetsBindingObserver {
  late final LocationCubit _locationCubit;

  bool _openedSettings = false;
  int _mapLocationRequest = 0;

  @override
  void initState() {
    super.initState();

    _locationCubit = GetIt.I<LocationCubit>();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _locationCubit.initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state != AppLifecycleState.resumed) {
      return;
    }

    _handleAppResumed();
  }

  Future<void> _handleAppResumed() async {
    if (!mounted) return;

    if (_openedSettings) {
      _openedSettings = false;

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      await _locationCubit.initialize();

      return;
    }

    final serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!mounted) return;

    if (!serviceEnabled) {
      await _locationCubit.initialize();
    }
  }

  Future<void> _openLocationSettings() async {
    _openedSettings = true;

    if (_locationCubit.state.isLocationServiceDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  void _goToMyLocation() {
    _locationCubit.goToMyLocation();

    setState(() {
      _mapLocationRequest++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _locationCubit,
      child: _LocationView(
        onOpenLocationSettings: _openLocationSettings,
        mapLocationRequest: _mapLocationRequest,
        onGoToMyLocation: _goToMyLocation,
      ),
    );
  }
}

class _LocationView extends StatelessWidget {
  const _LocationView({
    required this.onOpenLocationSettings,
    required this.mapLocationRequest,
    required this.onGoToMyLocation,
  });

  final Future<void> Function() onOpenLocationSettings;
  final int mapLocationRequest;
  final VoidCallback onGoToMyLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          if (state.status == LocationStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == LocationStatus.failure) {
            final locationDisabled =
                state.isLocationServiceDisabled;

            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      locationDisabled
                          ? Icons.location_off
                          : Icons.location_off_outlined,
                      size: 56.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      locationDisabled
                          ? 'Location is turned off'
                          : 'Location permission is required',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      locationDisabled
                          ? 'Please enable location services to find nearby doctors and hospitals.'
                          : 'Please allow location permission from your phone settings to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.gray500,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          await onOpenLocationSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(26.r),
                          ),
                        ),
                        child: Text(
                          locationDisabled
                              ? 'Enable Location'
                              : 'Open Settings',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: () {
                        context
                            .read<LocationCubit>()
                            .initialize();
                      },
                      child: Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.darkTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.latitude == null ||
              state.longitude == null) {
            return const SizedBox();
          }

          return Stack(
            children: [
              Positioned.fill(
                child: MedicalMap(
                  latitude: state.latitude!,
                  longitude: state.longitude!,
                  places: state.places,
                  selectedPlace: state.selectedPlace,
                  locationRequest: mapLocationRequest,
                  onPlaceSelected: (place) {
                    context
                        .read<LocationCubit>()
                        .selectPlace(place);
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      12.h,
                      16.w,
                      0,
                    ),
                    child: LocationSearchBar(
                      onSearch: (query) {
                        context
                            .read<LocationCubit>()
                            .search(query);
                      },
                    ),
                  ),
                ),
              ),
              if (state.places.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 230.h,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 5.h,
                        ),
                        scrollDirection: Axis.horizontal,
                        physics:
                        const BouncingScrollPhysics(),
                        itemCount: state.places.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: 12.w),
                        itemBuilder: (_, index) {
                          final place =
                          state.places[index];

                          return MedicalPlaceCard(
                            place: place,
                            onTap: () {
                              context
                                  .read<LocationCubit>()
                                  .selectPlace(place);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 16.w,
                bottom: state.places.isNotEmpty
                    ? 245.h
                    : 24.h,
                child: Material(
                  color: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black26,
                  borderRadius:
                  BorderRadius.circular(14.r),
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(14.r),
                    onTap: onGoToMyLocation,
                    child: SizedBox(
                      width: 48.w,
                      height: 48.w,
                      child: Icon(
                        Icons.my_location,
                        size: 22.sp,
                        color: AppColors.darkTeal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}