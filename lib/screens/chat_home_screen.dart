

// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'dart:developer';

import 'package:chat_application/api/apis.dart';
import 'package:chat_application/helper/dialogs.dart';
import 'package:chat_application/main.dart';
import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/screens/home_screen.dart';
import 'package:chat_application/screens/profile_screen.dart';
import 'package:chat_application/widgets/chat_user_card.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();
    // for setting user status to active, init chalu krne k liy hai
    SystemChannels.lifecycle.setMessageHandler((message) {
// for checking user is online or not
if(Apis.auth.currentUser!= null) {
      if(message.toString().contains('pause')) Apis.updateActiveStatus(false);
      if(message.toString().contains('resume')) Apis.updateActiveStatus(true);
}


      return Future.value(message);
    });

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  //for storing all users
  List<ChatUser> _list = [];
  // for storing search items
  final List<ChatUser> _searchList = [];
  // for storing search status
 bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
            onTap: () => FocusScope.of(context).unfocus(),


      child: WillPopScope(
        // if search is on then by going back close the search screen
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;

            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
          
        },
        child: Scaffold(
          appBar: AppBar(
            // home button
           leading: IconButton(
    icon: Icon(CupertinoIcons.home),
    onPressed: () {
      // Navigate to home page
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    },
  ),
            // dynamic heading chaning when clicking search button
            title: _isSearching? 
            TextField(decoration: InputDecoration(border: InputBorder.none, hintText: 'Name, User Name,...'),
            autofocus: true,
            // when usearch text changes then update search list
            onChanged: (val) {
              // search logic
              _searchList.clear();
        
              for (var i in _list) {
                if(i.name.toLowerCase().contains(val.toLowerCase()) || 
                i.name.toLowerCase().contains(val.toLowerCase())){
                  _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                
              }
            },
            )
            : Text('Chat Application'),
            actions: [
              //search button
              IconButton(onPressed: (){
                setState(() {
                  _isSearching =!_isSearching;
                });
              }, icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid : Icons.search)),
              //menu button
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: Apis.me,)));
              }, icon: Icon(Icons.more_vert))
            ],
            ),
          // floating add button
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 15, right: 8),
              child: FloatingActionButton(
                onPressed: () {
        
                  _addChatUserDialog();
                  
                }, child: Icon(Icons.add_circle_outline)),
            ),
        
            body: StreamBuilder(stream: Apis.getMyUsersId(), builder: (context, snapshot){
              switch (snapshot.connectionState) {
                  // if data is loading from database
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());
                    // if all data is loaded
                    case ConnectionState.active:
                    case ConnectionState.done:
                    final userIds = snapshot.data?.docs.map((e) => e.id).toList() ?? [];
        if (userIds.isEmpty) {
          return Center(child: Text('No chats found!'));
        }
                 return StreamBuilder(
              //change later on for ec2
              stream: Apis.getAllUsers(userIds),
              builder: (context, snapshot){
        
                switch (snapshot.connectionState) {
                  // if data is loading from database
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    //return Center(child: CircularProgressIndicator());
                    // if all data is loaded
                    case ConnectionState.active:
                    case ConnectionState.done:
        
                    
                
                  final data = snapshot.data?.docs;
                  _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                  
                  if(_list.isNotEmpty){
                    return ListView.builder(
                itemCount: _isSearching? _searchList.length: _list.length,
                padding: EdgeInsets.only(top: mq.height*.01),
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index){
                return ChatUserCard(user: _isSearching? _searchList[index]: _list[index]);
                //return Text('Name: ${list[index]}');
              });
                  } else {
                    return Center(child: Text('No users found!'));
                  }
        
                  }
        
                
              },
            );
              }
            }),

        
        ),
      ),
    );
  }


// for adding user to list
  void _addChatUserDialog() {
    String email= '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: Row(
          children: [
            Icon(
              Icons.person_add, color: Colors.blue, size: 28),
              Text(' Add User')
          ],
        ),

        content: TextFormField(
          maxLines: null,
          
          onChanged: (value) => email = value + '@gmail.com',
          decoration: InputDecoration(
            hintText: 'Enter user name...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
          ),
        ),

        actions: [
          MaterialButton(onPressed: (){
            Navigator.pop(context);
          },
          child: Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),

          MaterialButton(onPressed: () async {
            Navigator.pop(context);
            if(email.isNotEmpty)
             {
              await Apis.addChatUser(email).then((onValue) {
                if(!onValue){
                  Dialogs.showSnackBar(context, 'User Does not exist');
                }
              });
            }
          },
          child: Text('Add', style: TextStyle(color: Colors.blue, fontSize: 16)),
          )
        ],

      )
    );
  }

}