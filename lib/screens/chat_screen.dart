import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final List<String> messages = [];

  void send() {
    if (controller.text.isEmpty) return;

    setState(() {
      messages.add(controller.text);
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages.map((e) => ListTile(title: Text(e))).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: controller)),
              IconButton(onPressed: send, icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }
}