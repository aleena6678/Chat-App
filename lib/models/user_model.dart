class UserModel {
  final String uid, email, createdAt;
  final bool isOnline;

  UserModel({required this.uid, required this.email, required this.createdAt, required this.isOnline});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': createdAt,
      'isOnline': isOnline
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      createdAt: map['createdAt'],
      isOnline: map['isOnline']
    );
  }
}