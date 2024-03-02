import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/model/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Uint8List? _image;
  bool isLoading = false;
  late final User? user;
  late TextEditingController emailController = TextEditingController();
  late TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).getUser!;
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  void selectImg() async {
    Uint8List? img = await pickImg(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void updateProfile() async {
    setState(() {
      isLoading = true;
    });

    String res = await FirestoreMethods().editProfile(
        user!.uid, _image!, emailController.text, bioController.text);
    setState(() {
      isLoading = false;
    });
    if (res == 'success') {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MobileScreenLayout(
                page: 4,
              )));
      showSnackBar("successfully updated", context);
    } else {
      showSnackBar("Something went wrong", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: updateProfile,
              child: Text(
                "save",
                style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          )
        ],
        bottom: isLoading
            ? PreferredSize(
                preferredSize:
                    Size.fromHeight(4.0), // Adjust the size as needed
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(_image!),
                        radius: 50,
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(user!.photoUrl),
                        radius: 50,
                      ),
                Positioned(
                  right: -5,
                  bottom: -5,
                  child: IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: selectImg,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            TextFieldInput(
              textEditingController: emailController,
              textInputType: TextInputType.emailAddress,
              hintText: "Enter your new Email",
            ),
            SizedBox(height: 15.0),
            TextFieldInput(
              textEditingController: bioController,
              textInputType: TextInputType.text,
              hintText: "Enter your new Bio",
            ),
          ],
        ),
      ),
    );
  }
}
