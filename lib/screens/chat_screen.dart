import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {

  final UserModel user;
  final String roomId;

  const ChatScreen({
   super.key,
   required this.user,
   required this.roomId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final ScrollController _scrollController = ScrollController();

  void scrollToBottom() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

  @override
  void dispose() { // to prevent memory leak risk
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> sendCurrentMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageId = _database.ref().push().key ?? ''; // no nullable string
    final message = MessageModel(
        messageId: messageId,
        senderId: currentUser!.uid,
        text: _messageController.text.trim(),
        timestamp: DateTime.now().toString());
    await _databaseService.sendMessage(widget.roomId, message);
    _messageController.clear();
    scrollToBottom();
  }

  String formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.email),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<List<MessageModel>>(
                    stream: _databaseService.getMessages(widget.roomId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final messages = snapshot.data ?? [];
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollToBottom();
                      });
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId == currentUser!.uid;

                            return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: isMe ? Colors.blue : Colors.grey.shade300,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                                      bottomRight: Radius.circular(isMe ? 0 : 16)
                                    ),
                                ),
                                child: Column(
                                  children: [
                                    Text(message.text,
                                      style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                                    Text(
                                      formatTimestamp(DateTime.now().toString()),
                                      style: TextStyle(fontSize: 10),)
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                    }
                )
            )
          ],
        )
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                    hintText: 'Message',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => sendCurrentMessage(),
              )),
            IconButton(
                onPressed: () {
                  sendCurrentMessage();
                }, icon: Icon(Icons.send),color: Colors.lightGreen,),
          ],
        ),
      ),

    );
  }
}
