import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    this.location,
    this.isSelecting=true,
    super.key,
  });

  final LatLng? location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Pick Your Location' : 'Your Location'),
        actions: widget.isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.save_outlined),
                  onPressed: _pickedLocation == null
                      ? null
                      : () {
                          Navigator.of(context).pop(_pickedLocation);
                        },
                ),
              ]
            : [],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.location ?? const LatLng(33.1496943, 73.7451016),
          zoom: 16,
        ),
        onTap: widget.isSelecting
            ? (position) {
                setState(() {
                  _pickedLocation = position;
                });
              }
            : null,
        markers: (_pickedLocation == null && widget.isSelecting)
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('m1'),
                  position: _pickedLocation ?? widget.location!,
                ),
              },
      ),
    );
  }
}
