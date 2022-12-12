import 'package:chatapp/main.dart';
import 'package:chatapp/models/chatroommodel.dart';
import 'package:chatapp/models/messagemodel.dart';
import 'package:chatapp/models/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      MessageModel newMessage = MessageModel(
          messageId: uuid.v1(),
          sender: widget.userModel.uid,
          text: msg,
          seen: false,
          creatOn: DateTime.now());
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatRoomId)
          .set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(
                widget.targetUser.profilePic!,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.targetUser.fullName!,
              style: const TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(widget.chatroom.chatRoomId)
                  .collection("messages")
                  .orderBy("creatOn", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      reverse: true,
                      itemCount: dataSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        MessageModel currentMessage = MessageModel.fromMap(
                            dataSnapshot.docs[index].data()
                                as Map<String, dynamic>);
                        return Row(
                          mainAxisAlignment:
                              (currentMessage.sender == widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 13, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: (currentMessage.sender ==
                                            widget.userModel.uid)
                                        ? Theme.of(context).primaryColor
                                        : Colors.green,
                                    borderRadius: (currentMessage.sender ==
                                            widget.userModel.uid)
                                        ? const BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))
                                        : const BorderRadius.only(
                                            bottomRight: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                child: Text(
                                  currentMessage.text.toString(),
                                  style: const TextStyle(color: Colors.white),
                                )),
                          ],
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                          "An error occured! Please check your internet connection"),
                    );
                  } else {
                    return const Center(
                      child: Text("Say hi to your new friend"),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Row(
              children: [
                Flexible(
                    child: TextField(
                  controller: messageController,
                  maxLines: null,
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: "Enter Messege"),
                )),
                IconButton(
                  splashRadius: 10,
                  onPressed: () {
                    sendMessage();
                  },
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}
