

import 'dart:developer';
import 'dart:io';
import 'package:chat_application/screens/pdf_viewer_page';
import 'package:chat_application/screens/image_viewer_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/api/apis.dart';

import 'package:chat_application/helper/dialogs.dart';
import 'package:chat_application/helper/my_date_util.dart';
import 'package:chat_application/main.dart';
import 'package:http/http.dart' as http;
import 'package:chat_application/models/message.dart';
import  'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
    const MessageCard({super.key, required this.message,});
    final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.message.formId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage(): _blueMessage());  
  }

// sender message
  Widget _blueMessage() {

    //update last read message if sender and receiver are different
    if(widget.message.read.isEmpty){
      Apis.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
            // for showing message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image || widget.message.type == Type.pdf? mq.width*.02 : mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04, vertical: mq.height*.01),
            decoration: BoxDecoration(color: Colors.blue.shade100, border: Border.all(color: Colors.lightBlue)),
            child: 
            widget.message.type == Type.text ? 
            // show text
            Text(widget.message.msg, style: TextStyle(fontSize: 15, color: Colors.black87)):
            //show image
            widget.message.type == Type.image?
             GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerPage(imageUrl: widget.message.msg),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.image, size: 70),
                      ),
                    ):
       GestureDetector(
        onTap: () async{
          final file = await _downloadPdf(widget.message.msg);
          if (file !=null){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PdfViewerPage(pdfPath: file.path)));
          }
        },
        child: Row(
  mainAxisSize: MainAxisSize.min, // Ensures the row only takes the space required by its children
  children: [
    Container(
      padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
      
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center-align icon and text vertically
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red, size: 30), // Reduced icon size for better spacing
          SizedBox(width: 8), // Reduced spacing between icon and text
          Text(
            'Open PDF',
            style: TextStyle(
              fontSize: 15, // Adjusted font size for consistency
              fontWeight: FontWeight.w500, // Semi-bold for better readability
              color: Colors.black87, // Darker text color for contrast
            ),
          ),
        ],
      ),
    ),
  ],
)
       )
          ),
        ),
        // for showing message time
        Padding(
          padding: EdgeInsets.only(right: mq.width*.04),
          child: Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent), 
          style: TextStyle(fontSize: 13, color: Colors.black54)),
        ),

      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        
        // for showing message time
        Row(
          children: [
            // for adding some space
            SizedBox(width: mq.width*.04,),
            // double tick icon
            if(widget.message.read.isNotEmpty)
            Icon(Icons.done_all_rounded, color: Colors.blue, size: 20,),

            // for adding some space
            SizedBox(width: 2,),


            //sent time
            Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent), 
            style: TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),

        // for showing message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image? mq.width*.02: widget.message.type == Type.pdf? mq.width*.01 : mq.width*.04),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04, vertical: mq.height*.01),
            decoration: BoxDecoration(color: Colors.green.shade100, border: Border.all(color: Colors.lightGreen)),
            child: 
            widget.message.type == Type.text ? 
            // show text
            Text(widget.message.msg, style: TextStyle(fontSize: 15, color: Colors.black87)):
            //show image
            widget.message.type == Type.image?
             GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerPage(imageUrl: widget.message.msg),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.image, size: 70),
                      ),
                    ):
        GestureDetector(
  onTap: () async {
    final file = await _downloadPdf(widget.message.msg);
    if (file != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(pdfPath: file.path),
        ),
      );
    }
  },
  child: Row(
  mainAxisSize: MainAxisSize.min, // Ensures the row only takes the space required by its children
  children: [
    Container(
      padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
      
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center-align icon and text vertically
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red, size: 30), // Reduced icon size for better spacing
          SizedBox(width: 8), // Reduced spacing between icon and text
          Text(
            'Open PDF',
            style: TextStyle(
              fontSize: 15, // Adjusted font size for consistency
              fontWeight: FontWeight.w500, // Semi-bold for better readability
              color: Colors.black87, // Darker text color for contrast
            ),
          ),
        ],
      ),
    ),
  ],
)

)

          ),
        ),
      ],
    );
  }
  Future<File?> _downloadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/file_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      log('Error downloading PDF: $e');
    }
    return null;
  }

// bottom sheet for selecting messages
    void _showBottomSheet(bool isMe) {
      showModalBottomSheet(context: context, 
      builder: (_) {
        return ListView(
         shrinkWrap: true,
         children: [
          Container(
            height: 4,
            margin: EdgeInsets.symmetric(vertical: mq.height*.015, horizontal: mq.width*.4),
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8))),

widget.message.type == Type.text
    // Option for copying a message
    ? _OptionItem(
        icon: Icon(Icons.copy_all_rounded, color: Colors.blue, size: 26),
        name: 'Copy Text',
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((onValue) {
            Navigator.pop(context);
            Dialogs.showSnackBar(context, 'Text Copied!');
          });
        },
      )
    : widget.message.type == Type.image
        // Option to save an image
        ? _OptionItem(
            icon: Icon(Icons.download_rounded, color: Colors.blue, size: 26),
            name: 'Save Image',
            onTap: () async {
              downloadImage(context, widget.message.msg);
            },
          )
        : widget.message.type == Type.pdf
            // Option to save a PDF
            ? _OptionItem(
                icon: Icon(Icons.picture_as_pdf_rounded, color: Colors.blue, size: 26),
                name: 'Save PDF',
                onTap: () async {
                  downloadPDF(context, widget.message.msg);
                },
              )
            : Container(), // Add a fallback widget in case no type matches


           if(isMe)
            Divider(color: Colors.black54, endIndent: mq.width*.04, indent: mq.width*.04,),


           // if (widget.message.type == Type.text && isMe)
            // option for edit
           // _OptionItem(icon: Icon(Icons.edit, color: Colors.blue, size: 26,), name: 'Edit message', onTap: (){}),

        //    if (isMe)
        //    _OptionItem(
        //     icon: Icon(Icons.delete_forever, color: Colors.red, size: 26),
        //     name: 'Delete Message',
        //     onTap: () async {
      
        //     Navigator.pop(context); // Close the dialog first
        //     await Apis.deleteMessage(widget.message); // Perform API call
      
        //   },
        // ),



            if(isMe)
            Divider(color: Colors.black54, endIndent: mq.width*.04, indent: mq.width*.04,),


            //option for sent time
            _OptionItem(icon: Icon(Icons.remove_red_eye, color: Colors.blue,), name: 
            'Sent time: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}', onTap: (){}),

            //option for read time
            _OptionItem(icon: Icon(Icons.remove_red_eye, color: Colors.green, size: 26,), name:
            widget.message.read.isEmpty? 'Read At: Not seen yet' :
            'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}', onTap: (){}),

         ], 
                );
      });
    }

}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () => onTap(),
    child: Padding(
      padding: EdgeInsets.only(left: mq.width*.05, top: mq.height*.015, bottom: mq.height*.02),
      child: Row(children: [icon, Flexible(child: Text('   $name', style: TextStyle(fontSize: 15, color: Colors.black54, letterSpacing: 0.5)))
      ],),
    ),);
  }
}

Future<void> downloadImage(BuildContext context, String url) async {
  try {
    final status = await Permission.photos.request();
log('Permission status: $status');
    // Request storage permissions
    if (status.isGranted) {
      // Download the image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Get the app's documents directory
        // final directory = await getExternalStorageDirectory();
        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory.createSync();
        }
        final path = '${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Save the image file
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);
        Navigator.pop(context);

        // Notify user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image saved to $path')));
        log(path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download image')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Storage permission denied')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}
Future<void> downloadPDF(BuildContext context, String url) async {
  try {
    // Request storage permissions
    if (await Permission.storage.request().isGranted) {
      // Download the image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Get the app's documents directory
        // final directory = await getExternalStorageDirectory();
        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory.createSync();
        }
        final path = '${directory.path}/PDF_${DateTime.now().millisecondsSinceEpoch}.pdf';

        // Save the image file
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);
        Navigator.pop(context);

        // Notify user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF saved to $path')));
        log(path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download PDF')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Storage permission denied')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}