import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  LatLng _currentLocation = const LatLng(9.9312, 76.2673);  
  List<LatLng> _locationHistory = [];
  LatLng? _startPoint;
  LatLng? _endPoint;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchLocationHistory();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: ((GoogleMapController controller) =>
            _mapController.complete(controller)),
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 7,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("_currentLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: _currentLocation,
          ),
          if (_startPoint != null)
            Marker(
              markerId: const MarkerId("_startPoint"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              position: _startPoint!,
            ),
          if (_endPoint != null)
            Marker(
              markerId: const MarkerId("_endPoint"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 45,bottom: 15),
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: _playbackLocationHistory,
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }

  void _fetchLocationHistory() {
    // Coordinates for Kochi, Kerala and Coimbatore, Tamil Nadu
    LatLng kochi = const LatLng(9.9312, 76.2673);
    LatLng coimbatore = const LatLng(11.0168, 76.9558);

    // Simulate a route from Kochi to Coimbatore with a few intermediate points
    _locationHistory = [
      kochi,
      LatLng(10.5276, 76.2144), // Intermediate point
      LatLng(10.7769, 76.6548), // Intermediate point
      coimbatore
    ];

    // Set start and end points
    _startPoint = _locationHistory.first;
    _endPoint = _locationHistory.last;
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _saveLocation();
    });
  }

  void _saveLocation() {
    // Simulate location updates by moving the current location slightly
    // In real app, you would get the actual location from a location provider
    setState(() {
      _currentLocation = LatLng(_currentLocation.latitude + 0.01, _currentLocation.longitude + 0.01);
    });
  }

  void _playbackLocationHistory() async {
    final GoogleMapController controller = await _mapController.future;
    for (int i = 0; i < _locationHistory.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      controller.animateCamera(
        CameraUpdate.newLatLng(_locationHistory[i]),
      );
    }
  }
}
