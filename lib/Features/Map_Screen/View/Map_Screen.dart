import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndFetchLocation();
  }

  Future<void> _checkPermissionsAndFetchLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      log('serviceEnabled $serviceEnabled');
      // If not, show a dialog and return
      _showLocationServiceDisabledDialog();
      setState(() => _loading = false);
      return;
    }

    // Check location permission
    var status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      // Fetch the current location

      _fetchCurrentLocation();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchCurrentLocation() async {
    log('_currentPosition');
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        log('$_currentPosition');
        _loading = false;
      });
    } on PermissionDeniedException {
      _showPermissionDeniedDialog();
    } catch (e) {
      log('Error fetching location: $e');
      setState(() => _loading = false);
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text(
            'Location permission is permanently denied. Please enable it from the app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Services Disabled'),
        content: Text('Please enable location services to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _currentPosition == null
          ? Center(child: Text('Location not available'))
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _mapController.animateCamera(
            CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), northeast:  LatLng(_currentPosition!.latitude, _currentPosition!.longitude),), 50), // Padding around the bounds
          );
        },
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
