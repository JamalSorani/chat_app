import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../widgets/chat_messages.dart';
import '../widgets/new_messages.dart';

Color selectedColor = Colors.red;
Color? color = Colors.purple[50];

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void changeColor(Color color1) {
    setState(() {
      selectedColor = color1;
      color = color1;
    });
    void setupPushNotifications() async {
      final fcm = FirebaseMessaging.instance;
      await fcm.requestPermission();
      final token = fcm.getToken();
      fcm.subscribeToTopic('chat');
    }

    @override
    void initState() {
      super.initState();
      setupPushNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color,
        appBar: AppBar(
          backgroundColor: color,
          elevation: 2,
          title: const Text('Chat'),
          actions: [
            PopupMenuButton(
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: true,
                  child: Text('First way'),
                ),
                PopupMenuItem(
                  value: false,
                  child: Text('Second way'),
                ),
              ],
              onSelected: (value) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Pick a color'),
                          content: SingleChildScrollView(
                            child: value
                                ? ColorPicker(
                                    pickerColor: selectedColor,
                                    onColorChanged: changeColor,
                                  )
                                : MaterialPicker(
                                    pickerColor: selectedColor,
                                    onColorChanged: changeColor,
                                  ),
                          ),
                          actions: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: color),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel')),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: color),
                                onPressed: () {
                                  setState(() {
                                    color;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Submit')),
                          ],
                        ));
              },
              icon: Icon(
                Icons.color_lens_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        body: const Column(
          children: [
            Expanded(
              child: ChatMessages(),
            ),
            NewMessages(),
          ],
        ));
  }
}
