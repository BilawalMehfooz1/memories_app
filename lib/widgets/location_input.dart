import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({
    super.key,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  var _pickedLocation;
  var _isGettingLocation = false;

  // String get locationImage {
  //   if (_pickedLocation == null) {
  //     return '';
  //   }
  //   final lat = _pickedLocation!.latitude;
  //   final lng = _pickedLocation!.longitude;

  //   return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyClPM4aaxlYFz2qD6gEZQjs8zSvG4e2V-g';
  // }

  // Future _savePlace(double lat, double lng) async {
  //   final url = Uri.parse(
  //       'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyClPM4aaxlYFz2qD6gEZQjs8zSvG4e2V-g');
  //   final response = await http.get(url);
  //   final resData = json.decode(response.body);
  //   final address = resData['results'][0]['formatted_address'];
  //   setState(() {
  //     _pickedLocation = PlaceLocation(
  //       latitude: lat,
  //       longitude: lng,
  //       address: address,
  //     );
  //     _isGettingLocation = false;
  //   });
  // }

  // void _getCurrentLocation() async {
  //   Location location = Location();

  //   bool serviceEnabled;
  //   PermissionStatus permissionGranted;
  //   LocationData locationData;

  //   serviceEnabled = await location.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await location.requestService();
  //     if (!serviceEnabled) {
  //       return;
  //     }
  //   }
  //   permissionGranted = await location.hasPermission();
  //   if (permissionGranted == PermissionStatus.denied) {
  //     permissionGranted = await location.requestPermission();
  //     if (permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }

  //   setState(() {
  //     _isGettingLocation = true;
  //   });
  //   locationData = await location.getLocation();
  //   final lat = locationData.latitude;
  //   final lng = locationData.longitude;
  //   if (lat == null || lng == null) {
  //     return;
  //   }

  //   _savePlace(lat, lng);

  //   widget.onSelectLocation(_pickedLocation!);
  // }

  // void _selectFromMap() async {
  //   final pickedLocation = await Navigator.of(context).push<LatLng>(
  //     MaterialPageRoute(
  //       builder: (context) {
  //         return const MapScreen();
  //       },
  //     ),
  //   );
  //   if (pickedLocation == null) {
  //     return;
  //   }

  //   _savePlace(
  //     pickedLocation.latitude,
  //     pickedLocation.longitude,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Widget content = const Text(
      'No location chosen',
      textAlign: TextAlign.center,
    );

    if (_isGettingLocation) {
      content = const CircularProgressIndicator();
    }

    // if (_pickedLocation != null) {
    //   content = Image.network(
    //     locationImage,
    //     fit: BoxFit.cover,
    //     width: double.infinity,
    //     height: double.infinity,
    //   );
    // }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.black26,
            ),
          ),
          child: content,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: (){},
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: (){},
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        )
      ],
    );
  }
}
