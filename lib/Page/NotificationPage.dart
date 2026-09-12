import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("ការជូនដំណឹង"), backgroundColor: const Color(0xFF27AE60)),
      body: StreamBuilder<QuerySnapshot>(
        // ទាញយកប្រវត្តិសារជូនដំណឹងរបស់អ្នកប្រើប្រាស់បច្ចុប្បន្ន
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("មិនទាន់មានការជូនដំណឹងឡើយ"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.notifications, color: Color(0xFF27AE60))),
                title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['body'] ?? ''),
                trailing: Text(data['time'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              );
            },
          );
        },
      ),
    );
  }
}
