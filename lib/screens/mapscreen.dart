import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // For obtaining current location
import 'dart:async';

class Map_Page extends StatefulWidget {
  const Map_Page({Key? key}) : super(key: key);

  @override
  State<Map_Page> createState() => _Map_PageState();
}

class _Map_PageState extends State<Map_Page> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  LatLng? _currentLocation; // Current location
  List<LatLng> _locationHistory = []; // Location history data
  LatLng? _startPoint;
  LatLng? _endPoint;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchLocationHistory(); // Fetch location history from database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: ((GoogleMapController controller) =>
            _mapController.complete(controller)),
        initialCameraPosition: CameraPosition(
          target: _currentLocation ?? const LatLng(0, 0),
          zoom: 15,
        ),
        markers: {
          if (_currentLocation != null)
            Marker(
              markerId: const MarkerId("_currentLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _currentLocation!,
            ),
          if (_startPoint != null)
            Marker(
              markerId: const MarkerId("_startPoint"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              position: _startPoint!,
            ),
          if (_endPoint != null)
            Marker(
              markerId: const MarkerId("_endPoint"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              position: _endPoint!,
            ),
        },
        polylines: {
          Polyline(
            polylineId: const PolylineId("locationHistory"),
            color: Colors.black,
            points: _locationHistory,
            width: 5,
          ),
        },
        onTap: (LatLng latLng) {
          _showCustomInfoWindow(latLng);
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(38.0),
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: _playbackLocationHistory,
          child: Icon(Icons.play_arrow),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _fetchLocationHistory() {
    // Simulated location history data
    _locationHistory = [
      LatLng(37.422, -122.0848),
      LatLng(37.5, -122.1),
      LatLng(37.6, -122.2),
      LatLng(37.7, -122.3),
      LatLng(37.8, -122.4),
    ];

    if (_locationHistory.isNotEmpty) {
      _startPoint = _locationHistory.first;
      _endPoint = _locationHistory.last;
    }
  }

  void _playbackLocationHistory() async {
    if (_locationHistory.isNotEmpty) {
      final GoogleMapController controller = await _mapController.future;
      for (int i = 0; i < _locationHistory.length; i++) {
        await Future.delayed(Duration(milliseconds: 1000)); // Decreased delay for smoother animation
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            _locationHistory[i],
            15, // Adjust zoom level if needed
          ),
        );
      }
    }
  }

  void _showCustomInfoWindow(LatLng latLng) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Custom Info Window'),
          content: Text('Lat: ${latLng.latitude}, Lng: ${latLng.longitude}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
