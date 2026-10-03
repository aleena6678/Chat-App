class MessageModel {
  final String messageId, senderId, text, timestamp;
  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.timestamp
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp
    };
  }

  factory MessageModel.fromMap(Map<dynamic, dynamic> map) {
    return MessageModel(
        messageId: map['messageId'],
        senderId: map['senderId'],
        text: map['text'],
        timestamp: map['timestamp']);
  }

}
