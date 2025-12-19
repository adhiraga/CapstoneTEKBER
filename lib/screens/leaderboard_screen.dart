import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedCategory = 0; // 0 = AI Wins, 1 = Multiplayer Wins

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('AI Wins'),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Multiplayer Wins'),
                ),
              ],
              selected: {selectedCategory},
              onSelectionChanged: (newSelection) {
                setState(() {
                  selectedCategory = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: selectedCategory == 0
                ? buildAILeaderboard()
                : buildMultiplayerLeaderboard(),
          ),
        ],
      ),
    );
  }

  Widget buildAILeaderboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .orderBy('aiWins', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('⚠️ OFFLINE MODE\nLeaderboard unavailable'),
                const SizedBox(height: 8),
                Text('Error: ${snapshot.error}', 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No scores yet. Play some games!'),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final username = data['username'] ?? 'Unknown';
            final aiWins = data['aiWins'] ?? 0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    child: Text('${index + 1}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$aiWins wins',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildMultiplayerLeaderboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .orderBy('multiplayerWins', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('⚠️ OFFLINE MODE\nLeaderboard unavailable'),
                const SizedBox(height: 8),
                Text('Error: ${snapshot.error}', 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No scores yet. Play some games!'),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final username = data['username'] ?? 'Unknown';
            final multiplayerWins = data['multiplayerWins'] ?? 0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    child: Text('${index + 1}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$multiplayerWins wins',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
