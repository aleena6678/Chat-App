import 'package:chat_app/models/message_model.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> saveUser(UserModel user) async {
    await _database.ref('users/${user.uid}').set(user.toMap());
  }

  Stream<List<UserModel>> getUsers() {
    return _database.ref('users').onValue.map((event) {
      List<UserModel> users = [];
      final data = event.snapshot.value;
        if (data != null) {
          final userMap = Map<dynamic, dynamic>.from(data as Map);
          userMap.forEach((key, value) {
            users.add(UserModel.fromMap(
              Map<dynamic, dynamic>.from(value)
            ));
          });
        }
        return users;
    });
  }

  Future<void> sendMessage(String roomId, MessageModel message) async {
    await _database.ref('chats/$roomId/messages').push().set(message.toMap());
  }

  Stream<List<MessageModel>> getMessages(String roomId) {
    return _database.ref('chats/$roomId/messages').onValue.map((event) {
      List<MessageModel> messages = [];
      final data = event.snapshot.value;
      if (data != null) {
        final messageMap = Map<dynamic, dynamic>.from(data as Map);
        messageMap.forEach((key, value) {
          messages.add(
            MessageModel.fromMap(Map<dynamic, dynamic>.from(value))
          );
        });
      }
      return messages;
    });
  }

}

