import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});
  @override
  State<NewMessages> createState() => _NewMessagesState();
}

var firestore = FirebaseFirestore.instance;

class _NewMessagesState extends State<NewMessages> {
  var messageController = TextEditingController();
  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enteredMessage = messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    messageController.clear();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await firestore.collection('users').doc(user.uid).get();
    firestore.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  void sendImage() {}
  File? selectedImage;
  void pickImage(bool isGallery) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
        source: isGallery ? ImageSource.gallery : ImageSource.camera);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      selectedImage = File(pickedImage.path);
    });
    Navigator.of(context).pop();
    // ignore: use_build_context_synchronously
    showBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          Expanded(child: Image.file(selectedImage!)),
          FloatingActionButton(
            onPressed: sendImage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  File? selectedFile;
  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      return;
    }
    setState(() {
      selectedFile = File(result.files.single.path!);
    });
    Navigator.of(context).pop();
    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          FloatingActionButton(
            onPressed: sendImage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void openOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.outlined(
                  iconSize: 50,
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.purpleAccent),
                  onPressed: () => pickImage(true),
                  icon: const Icon(
                    color: Colors.white,
                    Icons.image,
                  ),
                ),
                IconButton.outlined(
                  iconSize: 50,
                  style: IconButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => pickImage(false),
                  icon: const Icon(
                    color: Colors.white,
                    Icons.camera_alt,
                  ),
                ),
                IconButton.outlined(
                  iconSize: 50,
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent),
                  onPressed: pickFile,
                  icon: const Icon(
                    color: Colors.white,
                    Icons.file_open,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.outlined(
                  iconSize: 50,
                  style: IconButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {},
                  icon: const Icon(
                    color: Colors.white,
                    Icons.person,
                  ),
                ),
                IconButton.outlined(
                  iconSize: 50,
                  style: IconButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {},
                  icon: const Icon(
                    color: Colors.white,
                    Icons.location_on,
                  ),
                ),
                IconButton.outlined(
                  iconSize: 50,
                  style:
                      IconButton.styleFrom(backgroundColor: Colors.deepOrange),
                  onPressed: () {},
                  icon: const Icon(
                    color: Colors.white,
                    Icons.headphones,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            onPressed: openOptions,
            icon: Icon(
              Icons.attachment_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: submitMessage,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
