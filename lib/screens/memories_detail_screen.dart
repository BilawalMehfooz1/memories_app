import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryDetailsScreen extends StatelessWidget {
  const MemoryDetailsScreen({
    required this.memoryId,
  });

  final String memoryId;

  Future<DocumentSnapshot> fetchMemoryDetails() {
    return FirebaseFirestore.instance
        .collection('memories')
        .doc(memoryId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context);
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchMemoryDetails(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Memory not found.'));
          }

          final memoryData = snapshot.data!.data() as Map<String, dynamic>;

          final lat = memoryData['location']['latitude'] as double;
          final lng = memoryData['location']['longitude'] as double;

          final locationImage =
              'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyB-qF_ODijQOhNfpfI2IxmeIjYw0LeY5OE';

          return Stack(
            children: [
              Image.network(
                memoryData['imageUrl'],
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle map tap if needed
                      },
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(locationImage),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black45,
                            Colors.black87,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
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
            ],
          );
        },
      ),
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: fetchMemoryDetails(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('Memory not found.');
            }

            final memoryData = snapshot.data!.data() as Map<String, dynamic>;
            return Text(memoryData['title']);
          },
        ),
      ),
    );
  }
}
