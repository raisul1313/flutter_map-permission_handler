import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MarkerMapPage extends StatefulWidget {
  const MarkerMapPage({Key? key}) : super(key: key);

  @override
  State<MarkerMapPage> createState() => _MarkerMapPageState();
}

class _MarkerMapPageState extends State<MarkerMapPage>
    with WidgetsBindingObserver {
  Location location = Location();
  LocationData? _currentLocation;
  bool isLocationServiceEnabled = false;
  bool isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //_initLocation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Location services are still not enabled, show a dialog or toast
        return;
      }
    }

    final PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.granted) {
      setState(() {
        isPermissionGranted = true;
      });
      getCurrentLocation();
    } else {
      final PermissionStatus permissionResult =
      await location.requestPermission();
      if (permissionResult == PermissionStatus.granted) {
        setState(() {
          isPermissionGranted = true;
        });
        getCurrentLocation();
      } else {
        return;
      }
    }
  }

  void getCurrentLocation() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _initLocation();
                },
                child: Text('Get Location'),
              ),
              SizedBox(height: 20),

              if (_currentLocation != null)
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: _showMap(
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showMap(double latitude, double longitude) {
    return  FlutterMap(
      options: MapOptions(
          initialCenter: LatLng(latitude, longitude), initialZoom: 18),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: [
          Marker(
              point: LatLng(latitude, longitude),
              child: Icon(
                Icons.pin_drop,
                color: Colors.red,
                size: 50,
              ))
        ])
      ],
    );
  }
}
