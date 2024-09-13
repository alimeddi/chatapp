import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  var _messagecont = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _messagecont.dispose();
  }

  void _submit() async {
    final entredMessage = _messagecont.text;
    if (entredMessage.trim().isEmpty) {
      return;
    }
    _messagecont.clear();
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': entredMessage,
      'createdAT': Timestamp.now(),
      'userId': user!.uid,
      'username': userdata.data()!['username'],
      'userImage': userdata.data()!['image'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _messagecont,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(labelText: 'Send Message'),
          )),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: _submit,
              icon: Icon(Icons.send)),
        ],
      ),
    );
  }
}
