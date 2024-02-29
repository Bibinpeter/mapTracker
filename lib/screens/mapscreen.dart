import 'package:fleet_map_tracker/constant/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController>? _mapController;
  Location _locationController = Location();
  LatLng _currentLocation = const LatLng(10.5276, 76.2144);
  List<LatLng> _locationHistory = [];
  List<LatLng> _savedLocations = [];
  LatLng? _startPoint;
  LatLng? _endPoint;
  late Timer _timer;
  late StreamSubscription<LocationData> _locationSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = Completer<GoogleMapController>();
    _fetchLocationHistory();
    _startLocationUpdates();
    getLocationUpdates().then((_) {
      getPolylinesPoints().then((coordinates) {
        generatePolyLineFromPoints(coordinates);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 12,
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
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _savedLocations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Saved Location $index'),
                  subtitle: Text(
                    'Lat: ${_savedLocations[index].latitude}, Lng: ${_savedLocations[index].longitude}',
                  ),
                  onTap: () {
                    _showCustomInfoWindow(_savedLocations[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _playbackLocationHistory,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapController!.isCompleted) {
      _mapController!.complete(controller);
    }
  }

  void _fetchLocationHistory() {
    // Load location history from database or other source
    // For demonstration purposes, we'll simulate some location history
    // Coordinates for Thrissur, Kerala and Coimbatore, Tamil Nadu
    LatLng thrissur = const LatLng(10.5276, 76.2144);
    LatLng coimbatore = const LatLng(11.0168, 76.9558);
    // Intermediate points along the route

    // Define the route
    _locationHistory = [thrissur, coimbatore];
    // Set start and end points
    _startPoint = thrissur;
    _endPoint = coimbatore;
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _saveLocation();
    });

    _locationSubscription =
        _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          _currentLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentLocation);
        });
      }
    });
  }

  void _saveLocation() {
    // Get the current location and save it to the database or other storage
    LatLng newLocation = LatLng(_currentLocation.latitude + 0.01, _currentLocation.longitude + 0.01);
    setState(() {
      _savedLocations.add(newLocation);
    });
  }

  void _playbackLocationHistory() async {
    final GoogleMapController controller = await _mapController!.future;
    for (int i = 0; i < _locationHistory.length; i++) {
      // Delay between each step of the animation
      await Future.delayed(const Duration(seconds: 2));
      // Move the camera to the next point in the route
      controller.animateCamera(
        CameraUpdate.newLatLng(_locationHistory[i]),
      );
    }
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    }
    if (!_serviceEnabled) {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<List<LatLng>> getPolylinesPoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      // Replace this with your Google Maps API key
      'GOOGLE_MAP_API_KEY',
      PointLatLng(_currentLocation.latitude, _currentLocation.longitude),
      PointLatLng(_endPoint!.latitude, _endPoint!.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      _locationHistory.addAll(polylineCoordinates);
    });
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController!.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  void _showCustomInfoWindow(LatLng location) {
    // Implement custom info window logic here
    // For demonstration purposes, we'll just show a dialog with location information
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Location Information'),
          content: Text('Latitude: ${location.latitude}, Longitude: ${location.longitude}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
