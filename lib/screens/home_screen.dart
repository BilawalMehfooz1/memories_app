import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('memories').snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No memories found.'));
          }
          final memories = snapshot.data!.docs;
          return ListView.builder(
            itemCount: memories.length,
            itemBuilder: (ctx, index) {
              return MemoryItem(
                title: memories[index]['title'],
                imageUrl: memories[index]['imageUrl'],
              );
            },
          );
        },
      ),
    );
  }
}
