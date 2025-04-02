import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chat_messages')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                //
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: const CircularProgressIndicator());
                }
                if ((snapshot.data?.docs.length ?? 0) == 0) {
                  return Center(child: Text('No messages yet!'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data?.docs[index];

                    return ListTile(
                      title: Text(message?['text'] ?? ''),
                      subtitle: Text(message?['username'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(hintText: 'Enter message...'),
                ),
              ),
              IconButton(
                onPressed: () {
                  // FirebaseFirestore.instance.collection('chat_messages').add({
                  //   'text': _messageController.text,
                  // });

                  FirebaseFirestore.instance.collection('chat_messages').add({
                    'text': _messageController.text,
                    'createdAt': Timestamp.now(),
                    'userId': FirebaseAuth.instance.currentUser!.uid,
                    'username': FirebaseAuth.instance.currentUser!.email,
                  });
                  _messageController.clear();
                },
                icon: Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
