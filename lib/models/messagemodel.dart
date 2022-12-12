class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? creatOn;

  MessageModel(
      {required this.messageId,
      required this.sender,
      required this.text,
      required this.seen,
      required this.creatOn});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map["messageId"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    creatOn = map["creatOn"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageId": messageId,
      "sender": sender,
      "text": text,
      "seen": seen,
      "creatOn": creatOn
    };
  }
}
