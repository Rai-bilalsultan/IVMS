import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

class GoogleMap extends StatelessWidget {
  const GoogleMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(30.0490, 70.6403),
            initialZoom: 8,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.example.track_vision',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(30.0490, 70.6403),
                  child: Icon(Icons.location_pin, size: 40, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
