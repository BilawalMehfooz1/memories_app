import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:memories_app/screens/map_screen.dart';
import 'package:photo_view/photo_view.dart';

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
  Map<String, dynamic>? memoryData;

  @override
  void initState() {
    super.initState();
    _fetchMemoryDetails();
  }

  Future<void> _fetchMemoryDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('memories')
          .doc(widget.memoryId)
          .get();

      if (doc.exists) {
        setState(() {
          memoryData = doc.data() as Map<String, dynamic>;
          isFavorite = memoryData!['isFavorite'] ?? false;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Failed to fetch memory details. Please try again.",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  Future<void> toggleFavoriteStatus() async {
    final currentStatus = isFavorite;
    if (currentStatus == null) return;

    try {
      if (currentStatus) {
        // If currently favorited, simply remove from favorites without setting timestamp
        await FirebaseFirestore.instance
            .collection('memories')
            .doc(widget.memoryId)
            .update({
          'isFavorite': !currentStatus,
          'favoritedAt': FieldValue.delete()
        }); // Notice the FieldValue.delete() here
      } else {
        // If not favorited, mark as favorite and set the favoritedAt timestamp
        await FirebaseFirestore.instance
            .collection('memories')
            .doc(widget.memoryId)
            .update({
          'isFavorite': !currentStatus,
          'favoritedAt': Timestamp.now() // Setting the timestamp here
        });
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentStatus
              ? 'Removed from favorites.'
              : 'Marked as favorite.'),
        ),
      );

      setState(() {
        isFavorite = !currentStatus;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Failed to mark as favorite. Please check your internet connection.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context);

    if (memoryData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final lat = memoryData!['latitude'] as double;
    final lng = memoryData!['longitude'] as double;
    final locationImage =
        'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyB-qF_ODijQOhNfpfI2IxmeIjYw0LeY5OE';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            PhotoView(
              imageProvider:
                  CachedNetworkImageProvider(memoryData!['imageUrl']),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
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
                        backgroundImage:
                            CachedNetworkImageProvider(locationImage),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      child: Text(
                        memoryData!['address'],
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
      ),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Text(
          memoryData!['title'],
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite! ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: toggleFavoriteStatus,
          ),
        ],
      ),
    );
  }
}
