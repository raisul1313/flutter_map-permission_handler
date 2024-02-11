import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'flutter_map_zoom_button.dart';

class UsingPermissonHandaler extends StatefulWidget {
  const UsingPermissonHandaler({super.key});

  @override
  State<UsingPermissonHandaler> createState() => _UsingPermissonHandalerState();
}

class _UsingPermissonHandalerState extends State<UsingPermissonHandaler> {
  var locationData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus();
    }
  }

  void _checkPermissionStatus() async {
    var status = await Permission.location.status;
    if (status.isPermanentlyDenied) {
      // If permission is permanently denied and dialog not shown yet, inform the user and provide guidance
      _showPermissionDeniedDialog(); // Update flag to indicate dialog shown
    }
  }

  _getLocation() async {
    var status = await Permission.location.status;
    if (!status.isGranted && !status.isPermanentlyDenied) {
      // If permission is not granted and not permanently denied, request it
      await Permission.location.request();
      // After requesting, check permission status again
      status = await Permission.location.status;
    }

    if (status.isGranted) {
      setState(() {
        isLoading = true;
      });
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        locationData = position;
        isLoading = false;
      });
    } else if (status.isPermanentlyDenied) {
      // If permission is permanently denied, inform the user and provide guidance
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Denied"),
          content: Text(
              "Please grant location permission in the app settings to enable location services."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () async {
                await openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => _getLocation(), child: Text('press')),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else if (locationData != null)
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: _showMap(
                  locationData.latitude,
                  locationData.longitude,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _showMap(double latitude, double longitude) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(latitude, longitude),
        initialZoom: 17,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: [
          Marker(
              point: LatLng(latitude, longitude),
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 30,
              ))
        ]),
        FlutterMapZoomButtons(
          minZoom: 4,
          maxZoom: 19,
          mini: true,
          padding: 10,
          alignment: Alignment.bottomRight,
        )
      ],
    );
  }
}
