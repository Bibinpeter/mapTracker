import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  LatLng? _currentLocation;
  List<LatLng> _locationHistory = [];
  LatLng? _startPoint;
  LatLng? _endPoint;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  void _startLocationUpdates() {
    _timer = Timer.periodic(Duration(minutes: 15), (timer) {
      _saveLocation();
    });
  }

  void _saveLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _locationHistory.add(LatLng(position.latitude, position.longitude));
    });
  }

  void _playbackLocationHistory() async {
    if (_locationHistory.isNotEmpty) {
      final GoogleMapController controller = await _mapController.future;
      for (int i = 0; i < _locationHistory.length; i++) {
        await Future.delayed(Duration(milliseconds: 1000));
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            _locationHistory[i],
            15,
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
