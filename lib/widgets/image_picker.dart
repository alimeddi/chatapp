import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickim});
  final void Function(File pick) onPickim;
  @override
  State<UserImagePicker> createState() {
    return _UserImageState();
  }
}

class _UserImageState extends State<UserImagePicker> {
  File? _pickedim;
  void _pickimage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (picked == null) {
      return;
    }
    setState(() {
      _pickedim = File(picked.path);
    });
    widget.onPickim(_pickedim!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedim != null ? FileImage(_pickedim!) : null,
        ),
        TextButton.icon(
          onPressed: _pickimage,
          label: Text('Add Image',
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          icon: Icon(Icons.image),
        )
      ],
    );
  }
}
