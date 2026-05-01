import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryMapScreen extends StatelessWidget {
  const DeliveryMapScreen({super.key});

  Future<void> _navigate(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final Uri browserUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    
    try {
      if (!kIsWeb && await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      launchUrl(browserUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final double latitude = args['latitude'] ?? 0.0;
    final double longitude = args['longitude'] ?? 0.0;
    final String address = args['address'] ?? 'Delivery Location';
    
    final location = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(address, style: const TextStyle(fontSize: 16)),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: location,
          initialZoom: 15.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dz.algeo.delivery.agent.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: location,
                width: 40,
                height: 40,
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'map_navigate_screen_fab',
        onPressed: () => _navigate(latitude, longitude),
        icon: const Icon(Icons.navigation),
        label: const Text('Navigate'),
      ),
    );
  }
}
