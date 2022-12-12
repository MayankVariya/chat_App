import 'package:chatapp/models/chatroommodel.dart';
import 'package:chatapp/models/firebasehelper.dart';
import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/pages/chatroompage.dart';

import 'package:chatapp/pages/searchpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/mydrawer.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});
  final UserModel userModel;
  final User firebaseUser;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context, widget.userModel.fullName, widget.userModel.email,
          widget.userModel.profilePic),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chat App"),
      ),
      body: SafeArea(
          child: Container(
        color: Colors.white,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("participants.${widget.userModel.uid}", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        chatRoomSnapshot.docs[index].data()
                            as Map<String, dynamic>);
                    Map<String, dynamic> participants =
                        chatRoomModel.participants!;
                    List<String> participantsKeys = participants.keys.toList();
                    participantsKeys.remove(widget.userModel.uid);
                    return FutureBuilder(
                      future:
                          FirebaseHelper.getUserModelById(participantsKeys[0]),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          if (userData.data != null) {
                            UserModel targetUser = userData.data as UserModel;
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                          targetUser: targetUser,
                                          chatroom: chatRoomModel,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser),
                                    ));
                              },
                              leading: CircleAvatar(
                                radius: 27,
                                backgroundImage:
                                    NetworkImage(targetUser.profilePic!),
                              ),
                              title: Text(
                                targetUser.fullName.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: (chatRoomModel.lastMessage.toString() ==
                                      "")
                                  ? Text(chatRoomModel.lastMessage.toString())
                                  : Text(
                                      "Say hi to your new friend",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.hasError.toString()),
                );
              } else {
                return const Center(
                  child: Text("No Chats"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser),
              ));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
