// import 'dart:convert';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:memories_app/models/location.dart';
import 'package:memories_app/screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  final Function(PlaceLocation) onSaveLocation;

  const LocationInput({
    required this.onSaveLocation,
    super.key,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyB-qF_ODijQOhNfpfI2IxmeIjYw0LeY5OE';
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyB-qF_ODijQOhNfpfI2IxmeIjYw0LeY5OE');

    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address'];
    if (lat != null && lng != null && address != null) {
      setState(() {
        _pickedLocation = PlaceLocation(
          latitude: lat,
          longitude: lng,
          address: address,
        );
        _isGettingLocation = false;
      });
      widget.onSaveLocation(_pickedLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Text(
      'No location chosen',
      textAlign: TextAlign.center,
    );

    if (_isGettingLocation) {
      content = const CircularProgressIndicator();
    }

    if (_pickedLocation != null) {
      content = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: content,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: () async {
                final selectedLocation =
                    await Navigator.of(context).push<LatLng>(
                  MaterialPageRoute(
                    builder: (ctx) => const MapScreen(isSelecting: true),
                  ),
                );

                if (selectedLocation != null) {
                  widget.onSaveLocation(
                    PlaceLocation(
                      latitude: selectedLocation.latitude,
                      longitude: selectedLocation.longitude,
                      address:
                          "Obtained address using geocoding perhaps?", // This is a placeholder. You'd typically use geocoding.
                    ),
                  );
                }
              },
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        )
      ],
    );
  }
}
