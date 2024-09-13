import 'package:ff/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAT', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found'),
          );
        }

        final loaded = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: loaded.length,
          itemBuilder: (context, index) {
            final message = loaded[index].data() as Map<String, dynamic>;
            final currentUserId = message['userId'];

            final nextMessage = index + 1 < loaded.length
                ? loaded[index + 1].data() as Map<String, dynamic>
                : null;
            final nextUserId =
                nextMessage != null ? nextMessage['userId'] : null;
            final isNextUserSame = nextUserId == currentUserId;
            if (isNextUserSame) {
              return MessageBubble.next(
                message: message['text'],
                isMe: authUser!.uid == currentUserId,
                // Add logic to show/hide the next message bubble
              );
            } else {
              return MessageBubble.first(
                userImage: message['userImage'],
                username: message['username'],
                message: message['text'],
                isMe: authUser!.uid == currentUserId,
              );
            }
          },
        );
      },
    );
  }
}
