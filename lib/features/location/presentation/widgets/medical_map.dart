import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medical_app/features/location/domain/entities/medical_place.dart';

class MedicalMap extends StatefulWidget {
  const MedicalMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.places,
    this.selectedPlace,
    this.onPlaceSelected,
  });

  final double latitude;
  final double longitude;
  final List<MedicalPlace> places;
  final MedicalPlace? selectedPlace;
  final ValueChanged<MedicalPlace>? onPlaceSelected;

  @override
  State<MedicalMap> createState() => _MedicalMapState();
}

class _MedicalMapState extends State<MedicalMap> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant MedicalMap oldWidget,) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedPlace != oldWidget.selectedPlace) {
      if (widget.selectedPlace != null) {
        _moveToPlace(widget.selectedPlace!);
      } else {
        _moveToUserLocation();
      }
    }

    if (widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude) {
      _moveToUserLocation();
    }
  }

  Future<void> _moveToPlace(MedicalPlace place,) async {
    if (_mapController == null) {
      return;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          place.latitude,
          place.longitude,
        ),
        16,
      ),
    );
  }

  Future<void> _moveToUserLocation() async {
    if (_mapController == null) {
      return;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          widget.latitude,
          widget.longitude,
        ),
        14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPosition = LatLng(
      widget.latitude,
      widget.longitude,
    );

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('user_location'),
        position: userPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
        infoWindow: const InfoWindow(
          title: 'Your Location',
        ),
      ),
      ...widget.places.map(
            (place) {
          final isSelected =
              widget.selectedPlace?.id == place.id;

          return Marker(
            markerId: MarkerId(place.id),
            position: LatLng(
              place.latitude,
              place.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueRose,
            ),
            infoWindow: InfoWindow(
              title: place.name,
              snippet:
              '${place.distance.toStringAsFixed(1)} km away',
            ),
            onTap: () {
              widget.onPlaceSelected?.call(place);
            },
          );
        },
      ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: userPosition,
        zoom: 14,
      ),
      onMapCreated: (controller) {
        _mapController = controller;

        if (widget.selectedPlace != null) {
          _moveToPlace(
            widget.selectedPlace!,
          );
        } else {
          _moveToUserLocation();
        }
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      markers: markers,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      buildingsEnabled: true,
      indoorViewEnabled: false,
      trafficEnabled: false,
    );
  }
}