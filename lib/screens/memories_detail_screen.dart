import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:memories_app/screens/map_screen.dart';

class MemoryDetailsScreen extends StatefulWidget {
  const MemoryDetailsScreen({
    required this.memoryId,
    super.key,
  });

  final String memoryId;

  @override
  State<MemoryDetailsScreen> createState() => _MemoryDetailsScreenState();
}

class _MemoryDetailsScreenState extends State<MemoryDetailsScreen> {
  bool? isFavorite;

  Future<DocumentSnapshot> fetchMemoryDetails() {
    return FirebaseFirestore.instance
        .collection('memories')
        .doc(widget.memoryId)
        .get();
  }

  Future<void> toggleFavoriteStatus() async {
    final currentStatus = isFavorite;
    if (currentStatus == null) return;

    await FirebaseFirestore.instance
        .collection('memories')
        .doc(widget.memoryId)
        .update({'isFavorite': !currentStatus});
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(currentStatus
            ? 'Removed from favorites.'
            : 'Marked as favorite.')));

    setState(() {
      isFavorite = !currentStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context);
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchMemoryDetails(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Memory not found.'));
          }

          final memoryData = snapshot.data!.data() as Map<String, dynamic>;
          final lat = memoryData['latitude'] as double;
          final lng = memoryData['longitude'] as double;
          final locationImage =
              'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyB-qF_ODijQOhNfpfI2IxmeIjYw0LeY5OE';

          return Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: Stack(
              children: [
                Image.network(
                  memoryData['imageUrl'],
                  fit: BoxFit.contain,
                  height: double.infinity,
                  width: double.infinity,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black45,
                          Colors.black87,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return MapScreen(
                                    isSelecting: false,
                                    location: LatLng(lat, lng),
                                  );
                                },
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: NetworkImage(locationImage),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          child: Text(
                            memoryData['address'],
                            textAlign: TextAlign.center,
                            style: style.textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: FutureBuilder<DocumentSnapshot>(
          future: fetchMemoryDetails(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Memory not found.');
            }

            final memoryData = snapshot.data!.data() as Map<String, dynamic>;
            return Text(
              memoryData['title'],
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: fetchMemoryDetails(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); // Display an empty container while loading
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Container(); // Display an empty container for no data
              }

              final memoryData = snapshot.data!.data() as Map<String, dynamic>;
              if (isFavorite == null) {
                isFavorite = memoryData['isFavorite'] ?? false;
              }

              return IconButton(
                icon: Icon(
                  isFavorite! ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: toggleFavoriteStatus,
              );
            },
          ),
        ],
      ),
    );
  }
}
