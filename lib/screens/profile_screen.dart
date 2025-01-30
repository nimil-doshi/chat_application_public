

// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/api/apis.dart';
import 'package:chat_application/helper/dialogs.dart';
import 'package:chat_application/main.dart';
import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

//profile screen to show user details


class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      appBar: AppBar(


        title: Text('Profile Details'),

        ),
      // floating logout button
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 15, right: 8),
          child: FloatingActionButton.extended(
            onPressed: () async {
              //await Apis.updateActiveStatus(false);

              Dialogs.showProgresskBar(context);
              await Apis.auth.signOut().then((onValue) async {
              await GoogleSignIn().signOut().then((onValue) async {
                
                // for closing progres bar
                Navigator.pop(context);
                // for closing home screen in background
                Navigator.pop(context);
                //await Apis.updateActiveStatus(false);
                //Apis.auth = FirebaseAuth.instance;

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));

              });

              });
              
              
            }, icon: Icon(Icons.logout), label: Text('logout'),),
        ),
    
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width*.05),
            child: SingleChildScrollView(
              child: Column(children: [
                //for adding some space in profile picture
                SizedBox(width: mq.width, height: mq.height*.05,),
                Stack(
                  children: [
                    // local image temporarily
                    _image != null ? Image.file(
                      File(_image!),
                      width: mq.height*.2,
                      height: mq.height*.2,
                      fit: BoxFit.cover,              
                      ):
                    //profile picture from database or server
                    CachedNetworkImage(
                      width: mq.height*.2,
                      height: mq.height*.2,
                              imageUrl: widget.user.image,
                              errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person)),
                       ),
              
                       // edit button on profile pciture
                      //  Positioned(
                      //   bottom: 15,
                      //   right: 0,
                      //    child: MaterialButton(onPressed: (){
                      //     _showBottomSheet();
                      //    },
                      //    shape: CircleBorder(),
                      //    color: Colors.white, 
                      //    child: Icon(Icons.edit, color: Colors.blue,)),
                      //  )
                  ],
                ),
              
              
                  // for showing user email, user name 
                  SizedBox(height: mq.height*.03,),
                   Text(widget.user.name, style: TextStyle(fontSize: 16)),
              
              
                  SizedBox(height: mq.height*.05,),
                   TextFormField(initialValue: widget.user.name,
                   onSaved: (val) => Apis.me.name = val ?? '',
                   validator: (val) => val != null && val.isNotEmpty ? null :'Required*',
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'Enter your name',
                    label: Text('Name'),
                    ),
                    ),
              
              
                    SizedBox(height: mq.height*.02),
                    TextFormField(initialValue: widget.user.about,
                  onSaved: (val) => Apis.me.about = val ?? '',
                   validator: (val) => val != null && val.isNotEmpty ? null :'Required*',
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.info_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'e.g. Feeling happy',
                    label: Text('About'),
                    ),
                    
                    ),
                    SizedBox(height: mq.height*.02),
                    ElevatedButton.icon(onPressed: (){
                      if(_formKey.currentState!.validate()){
                        _formKey.currentState!.save();
                        Apis.updateUserInfo().then((onValue) {
                          Dialogs.showSnackBar(context, 'Profile Updated Successfully!');
                        });
                        
                      }
                    }, icon: Icon(Icons.edit), label: Text('Update'),)
                   ],),
            ),
          ),
        )

    ));
  }
// showing dialog for editing profile pciture
    // void _showBottomSheet() {
    //   showModalBottomSheet(context: context, 
    //   builder: (_) {
    //     return ListView(
    //      shrinkWrap: true,
    //      padding: EdgeInsets.only(top: mq.height*.03, bottom: mq.height*.05),
    //      children: [
    //       Text('select the Profile Pic', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //         children: [
    //           ElevatedButton(
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.white, shape: CircleBorder() ,fixedSize: Size(mq.width*.3, mq.height*.15)),
    //             onPressed: () async {
    //               final ImagePicker picker = ImagePicker();
    //             // Pick an image.
    //               final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    //               if(image != null){
    //                 setState(() {
    //                   _image = image.path;
    //                 });
    //                 //for uploading image calling api, uncomment later on
    //                 //Apis.updateProfilePicture(File(_image!));
    //                 //for hiding bottom sheet
    //                 Navigator.pop(context);
    //               }
                  
                  
    //             },
    //             child: Image.asset('images/gallery.png')),
    //             ElevatedButton(
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.white, shape: CircleBorder() ,fixedSize: Size(mq.width*.3, mq.height*.15)),
    //             onPressed: () async {
    //               final ImagePicker picker = ImagePicker();
    //             // Pick an image.
    //               final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    //               if(image != null){
    //                 setState(() {
    //                   _image = image.path;
    //                 });
    //                 //for uploading image calling api, uncomment later on
    //                 //Apis.updateProfilePicture(File(_image!));
    //                 //for hiding bottom sheet
    //                 Navigator.pop(context);
    //               }
    //             },
    //             child: Image.asset('images/camera.png'))
    //         ],
    //       )
    //      ], 
    //             );
    //   });
    // }


}