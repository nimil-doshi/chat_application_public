import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/api/apis.dart';
import 'package:chat_application/helper/my_date_util.dart';
import 'package:chat_application/main.dart';
import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/models/message.dart';
import 'package:chat_application/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:image_picker/image_picker.dart';


class ChatScreen extends StatefulWidget {
  final ChatUser user;
    const ChatScreen({super.key, required this.user, });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
// for storing all messages
  List<Message> _list = [];
  // for handling text changes
  final _textController = TextEditingController();

// for storing value of emoji, for checking if a image is uploading or not
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if emoji tab is open and back button is pressed close emoji tab 
          onWillPop: () {
          if(_showEmoji){
            setState(() {
              _showEmoji = !_showEmoji;

            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
          
        },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
                
            backgroundColor: Color.from(alpha: 255, red: 234, green: 248, blue: 255),
                
            // body
            body: Column(children: [
              Expanded(
                child: StreamBuilder(
                    //change later on for ec2
                    stream: Apis.getAllMessages(widget.user), 
                    builder: (context, snapshot){
                        
                      switch (snapshot.connectionState) {
                        // if data is loading from database
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                         return SizedBox();
                          // if all data is loaded
                          case ConnectionState.active:
                          case ConnectionState.done:
                        
                          
                      
                        final data = snapshot.data?.docs;
                        
                        _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                        //_list.clear();
                        if(_list.isNotEmpty){
                          return ListView.builder(
                            reverse: true,
                      itemCount: _list.length,
                      padding: EdgeInsets.only(top: mq.height*.01),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index){
                      return MessageCard(message: _list[index]);
                    });
                        } else {
                          return Center(child: Text('Say Hi!👋'));
                        }
                        
                        }
                        
                      
                    },
                  ),
              ),
              // progress indicator for showing uploading
              if(_isUploading)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: CircularProgressIndicator(strokeWidth: 2))),

              // chat input tab from below
              _chatInput(),
                
                
              if(_showEmoji)
                
                EmojiPicker(
                
                textEditingController: _textController,
                config: Config(
            height: mq.height*.35,
            
            checkPlatformCompatibility: true,
            emojiViewConfig: EmojiViewConfig(
            backgroundColor: Color.from(alpha: 255, red: 234, green: 248, blue: 255),
            columns: 8,
            emojiSizeMax: 28 *
            (foundation.defaultTargetPlatform == TargetPlatform.iOS
                ?  1.20
                :  1.0),
            ),
            viewOrderConfig: const ViewOrderConfig(
                top: EmojiPickerItem.categoryBar,
                middle: EmojiPickerItem.emojiView,
                bottom: EmojiPickerItem.searchBar,
            ),
            skinToneConfig: const SkinToneConfig(),
            categoryViewConfig: const CategoryViewConfig(),
            bottomActionBarConfig: const BottomActionBarConfig(),
            searchViewConfig: const SearchViewConfig(),
                ),
                )
              ]),
          ),
        ),
      ),
    );
  }

  //creating function for app bar
  Widget _appBar(){
    return InkWell(
      // for open to user details
      onTap: (){},
      child: StreamBuilder(stream: Apis.getUserInfo(widget.user), builder: (context, snapshot) {


        final data = snapshot.data?.docs;
           final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            

        return Row(children: [
        // back button
        IconButton(onPressed: () => Navigator.pop(context), 
        icon: Icon(Icons.arrow_back, color: Colors.black,)),
        // user profile pic
        CachedNetworkImage(
              width: mq.height*.05,
              height: mq.height*.05,
          imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
          //placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person)),
       ),
      
       SizedBox(width: 10),
        // for showing user name
       Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(list.isNotEmpty ? list[0].name : widget.user.name, 
       style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500 )),
      
       SizedBox(height: 1),
      
      // for showing last seen
       Text(list.isNotEmpty ? 
       list[0].isOnline ? 'Online' :
       MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive) 

       : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive), 
       style: TextStyle(fontSize: 13, color: Colors.black54 ))
       ])
      
      ],
       );
   
      }),
  );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height*.01, horizontal: mq.width*.02),
      child: Row(
        children: [
      
          //input field and buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                //emoji button
                        IconButton(onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                        }, 
                  icon: Icon(Icons.emoji_emotions, color: Colors.blueAccent)),
              
              
                  // text input field for message
                  Expanded(child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji){
                      setState(() {
                        
                        _showEmoji = !_showEmoji;
                      });
                      }
                    },
                    decoration: InputDecoration(hintText: 'type something...', border: InputBorder.none),
                  )),
              
                   IconButton(
                  onPressed: () => _showAttachmentOptions(),
                  icon: Icon(Icons.attach_file, color: Colors.blueAccent),
                ),

                  SizedBox(width: mq.width*.02),
              
              
              ]),
            ),
          ),
          // send message button
          MaterialButton(onPressed: (){
            if(_textController.text.isNotEmpty) {
              if(_list.isEmpty){
                Apis.sendFirstMessage(widget.user, _textController.text, Type.text);  
              }else {
                Apis.sendMessage(widget.user, _textController.text, Type.text);
              }
              _textController.text = '';
            }
          }, 
          minWidth: 0,
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
          shape: CircleBorder(),
          color: Colors.green,
          child: Icon(Icons.send, color: Colors.white,),)
        ],
      ),
    );
  }
void _showAttachmentOptions() {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true, // Allows full-screen adjustment
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blueAccent),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  if (image != null) {
                    setState(() {
                      _isUploading = true;
                    });
                    await S3Storage.sendChatImage(widget.user, File(image.path));
                    setState(() {
                      _isUploading = false;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blueAccent),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  final ImagePicker picker = ImagePicker();
                  final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);
                  for (var i in images) {
                    setState(() {
                      _isUploading = true;
                    });
                    await S3Storage.sendChatImage(widget.user, File(i.path));
                    setState(() {
                      _isUploading = false;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('Send PDF'),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                    allowMultiple: true,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    for (var file in result.files) {
                      setState(() {
                        _isUploading = true;
                      });
                      await S3Storage.sendChatPDF(widget.user, File(file.path!));
                      setState(() {
                        _isUploading = false;
                      });
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}




}
