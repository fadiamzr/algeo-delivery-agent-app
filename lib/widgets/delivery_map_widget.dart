import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';

class DeliveryMapWidget extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? address;
  final VoidCallback? onTap;

  const DeliveryMapWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
    this.onTap,
  });

  Future<void> _navigate() async {
    if (latitude == null || longitude == null) return;
    
    final Uri googleMapsUrl = Uri.parse('google.navigation:q=$latitude,$longitude');
    final Uri browserUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    
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
    if (latitude == null || longitude == null) {
      return Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
           color: Theme.of(context).colorScheme.surface,
           borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('📍 Location not available — address could not be geocoded'),
        ),
      );
    }

    final location = LatLng(latitude!, longitude!);
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
         borderRadius: BorderRadius.circular(16),
         child: Stack(
           children: [
             GestureDetector(
               onTap: onTap,
               child: AbsorbPointer( // Prevent scrolling map inside scrollable details page
                 child: FlutterMap(
                   options: MapOptions(
                     initialCenter: location,
                     initialZoom: 15.0,
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
               ),
             ),
             if (address != null)
               Positioned(
                 bottom: 16,
                 left: 16,
                 right: 80, // Space for FAB
                 child: Card(
                   elevation: 4,
                   margin: EdgeInsets.zero,
                   color: cs.surface.withValues(alpha: 0.9),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     child: Text(
                       address!,
                       style: TextStyle(
                         color: cs.onSurface,
                         fontSize: 13,
                         fontWeight: FontWeight.w500,
                       ),
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                 ),
               ),
             Positioned(
               bottom: 16,
               right: 16,
               child: FloatingActionButton(
                 heroTag: 'map_navigate_widget_fab',
                 mini: true,
                 onPressed: _navigate,
                 child: const Icon(Icons.navigation_outlined),
               ),
             ),
           ],
         ),
      ),
    );
  }
}
