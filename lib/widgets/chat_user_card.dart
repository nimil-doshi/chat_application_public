import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/api/apis.dart';
import 'package:chat_application/helper/my_date_util.dart';
import 'package:chat_application/main.dart';
import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/models/message.dart';
import 'package:chat_application/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

// last message info if null no msg info
  Message? _message; 

  @override
  Widget build(BuildContext context) {

            
            

    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width*0.04, vertical: 4),
      child: InkWell(
        onTap: (){
          // navigating to chat screen with a particular user
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(stream: Apis.getLastMessage(widget.user), builder: (context, snapshot){
          final data = snapshot.data?.docs;
           final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if(list.isNotEmpty) {
              _message = list[0];
            }
          return ListTile(
          // user profile picture
          //leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
          leading: CachedNetworkImage(
            width: mq.height*.055,
            height: mq.height*.055,
        imageUrl: widget.user.image,
        //placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person)),
     ),
          // USer name
          title: Text(widget.user.name),
          // Last Message
          subtitle: Text(_message != null ? _message!.type == Type.image? 'image' :_message!.type == Type.pdf? 'PDF': _message!.msg : widget.user.about, maxLines: 1),
          // last message time
          trailing: _message == null ? null
          // show nothing when no msg is sent
           :
           _message!.read.isEmpty && _message!.formId != Apis.user.uid ?
           // show for unread msg
           Container(width: 15, height: 15, color: Colors.greenAccent.shade400,) :
           Text(MyDateUtil.getLastMessageTime(context: context, time: _message!.sent)),
          // ,
        );
        },)
      )
      );
  }
}