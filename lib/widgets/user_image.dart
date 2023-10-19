import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImage extends StatefulWidget {
  const UserImage({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;
  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  File? pickedImageFile;
  void pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 50);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              pickedImageFile != null ? FileImage(pickedImageFile!) : null,
        ),
        TextButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.image),
            label: Text(
              'Add Image',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ))
      ],
    );
  }
}
