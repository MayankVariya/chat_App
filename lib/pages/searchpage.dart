import 'package:chatapp/main.dart';
import 'package:chatapp/models/chatroommodel.dart';
import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/pages/chatroompage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});
  final UserModel userModel;
  final User firebaseUser;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.isNotEmpty) {
      //old ChatRoom
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatRoom;
    } else {
      //new ChatRoom
      ChatRoomModel newChatRoom = ChatRoomModel(
          chatRoomId: uuid.v1(),
          participants: {widget.userModel.uid!: true, targetUser.uid!: true},
          lastMessage: "");
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        color: Colors.white,
        child: Column(
          children: [
            TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                  hintText: "Email Address",
                  enabledBorder: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(130, 40)),
              child: const Text("Search"),
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .where("email", isEqualTo: searchController.text)
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    if (dataSnapshot.docs.isNotEmpty) {
                      Map<String, dynamic> userMap =
                          dataSnapshot.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () async {
                          ChatRoomModel? chatRoomModel =
                              await getChatRoomModel(searchedUser);
                          if (chatRoomModel != null) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomPage(
                                      targetUser: searchedUser,
                                      chatroom: chatRoomModel,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser),
                                ));
                          }
                        },
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(searchedUser.profilePic!),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          searchedUser.fullName!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(searchedUser.email!),
                        trailing: const Icon(
                          Icons.keyboard_arrow_right,
                          size: 30,
                        ),
                      );
                    } else {
                      return const Text("No Results Founds!");
                    }
                  } else if (snapshot.hasError) {
                    return const Text("An error occured!");
                  } else {
                    return const Text("No Results Founds!");
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      )),
    );
  }
}
