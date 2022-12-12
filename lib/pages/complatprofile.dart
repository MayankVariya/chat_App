import 'dart:developer';
import 'dart:io';

import 'package:chatapp/models/usermodel.dart';
import 'package:chatapp/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/uihelper.dart';

class ComplateProfilePage extends StatefulWidget {
  const ComplateProfilePage(
      {super.key, required this.userModel, required this.firebaseUser});
  final UserModel userModel;
  final User firebaseUser;
  @override
  State<ComplateProfilePage> createState() => _ComplateProfilePageState();
}

class _ComplateProfilePageState extends State<ComplateProfilePage> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    File? croppedImage = await ImageCropper().cropImage(sourcePath: file.path);
    if (croppedImage != null) {
      setState(() {
        imageFile = croppedImage;
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: const Icon(Icons.photo_album_outlined),
                title: const Text("Select From Gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
              )
            ],
          ),
        );
      },
    );
  }

  void checkValue() {
    String fullName = fullNameController.text.trim();
    if (fullName == "" || imageFile == null) {
      UiHelper.showAlertDialog(context, "Incomplete Data",
          "Please fill all the fields and upload a profile picture");
    } else {
      log("Uploading data..");
      uploadData();
    }
  }

  void uploadData() async {
    UiHelper.showLoadingDialog(context, "Uploading image....");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullName = fullNameController.text.trim();

    widget.userModel.fullName = fullName;
    widget.userModel.profilePic = imageUrl;

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      log("Data Uploaded");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userModel: widget.userModel,
              firebaseUser: widget.firebaseUser,
            ),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Complet Profile"),
      ),
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              MaterialButton(
                onPressed: () {
                  showPhotoOptions();
                },
                child: CircleAvatar(
                  radius: 65,
                  backgroundImage:
                      imageFile == null ? null : FileImage(imageFile!),
                  child: imageFile == null
                      ? const Icon(
                          Icons.person,
                          size: 80,
                        )
                      : null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: fullNameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: "Enter Full Name",
                    enabledBorder: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 45)),
                  onPressed: () {
                    checkValue();
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 16),
                  ))
            ],
          ),
        ),
      )),
    );
  }
}
