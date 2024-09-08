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
    var status = await Permission.location.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      // Request the permission
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      // Fetch the current location
      _fetchCurrentLocation();
    } else {
      // Permission denied, handle appropriately
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _currentPosition == null
          ? Center(child: Text('Location not available'))
          : GoogleMap(
        onMapCreated: _onMapCreated,
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
