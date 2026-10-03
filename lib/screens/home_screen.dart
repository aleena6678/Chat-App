import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final DatabaseService _databaseService = DatabaseService();
  final currentUser = FirebaseAuth.instance.currentUser;

  String getChatRoomId(String uid1, String uid2) {
    List<String> room1 = [uid1, uid2];
    room1.sort();
    return '${room1[0]}_${room1[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.grey,
      body: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.pink,
            alignment: Alignment.center,
            child: Text('Chat App', style: TextStyle(color: Colors.white, fontSize: 40),),),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _databaseService.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator());
                }
                final users = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    if (user.uid == currentUser?.uid) {
                      return SizedBox.shrink();
                  }
                  return ListTile(
                    title: Text(user.email),
                    onTap: () {
                      final roomId = getChatRoomId(currentUser!.uid, user.uid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(user: user, roomId: roomId))
                      );
                    },
                  );
              },);})),

                const SizedBox(height: 20),
                Consumer<AuthProviderClass>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                        onPressed: () {
                          provider.logOut();
                        },
                        child: const Text('Logout')
                    );
                  },

                )
              ],
            ),
          );
  }
}
