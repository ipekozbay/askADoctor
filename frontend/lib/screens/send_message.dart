import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class SendMessage extends StatefulWidget {
  final Map<String, String> chatRoomInfo;

  SendMessage(this.chatRoomInfo);

  @override
  _SendMessageState createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  var messageController = TextEditingController();
  bool sendVerifier = false;

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      String currentUserEmail =
          Provider.of<Auth>(context, listen: false).userEmail;
      String currentUserName =
          Provider.of<Auth>(context, listen: false).kullaniciAdi;
      String otherUserEmail =
          currentUserEmail == widget.chatRoomInfo['hastaEmail']
              ? widget.chatRoomInfo['doktorEmail'] as String
              : widget.chatRoomInfo['hastaEmail'] as String;
      String otherUserName =
          currentUserName == widget.chatRoomInfo['hastaUserName']
              ? widget.chatRoomInfo['doktorUserName'] as String
              : widget.chatRoomInfo['hastaUserName'] as String;
      try {
        FirebaseFirestore.instance
            .collection(
                '/Users/${widget.chatRoomInfo['hastaEmail']}/konustuklari/${widget.chatRoomInfo['doktorEmail']}/sohbet')
            .add({
          'message': messageController.text,
          'sentAt': Timestamp.now(),
          'sentByEmail': currentUserEmail,
          'sentToEmail': otherUserEmail,
          'sentByUser': currentUserName,
          'sentToUser': otherUserName,
        });
        FirebaseFirestore.instance
            .collection(
                '/Users/${widget.chatRoomInfo['hastaEmail']}/konustuklari')
            .doc(widget.chatRoomInfo['doktorEmail'])
            .set({
          'message': messageController.text,
          'sentAt': Timestamp.now(),
          'hastaEmail': widget.chatRoomInfo['hastaEmail'],
          'doktorEmail': widget.chatRoomInfo['doktorEmail'],
          'hastaUserName': widget.chatRoomInfo['hastaUserName'],
          'doktorUserName': widget.chatRoomInfo['doktorUserName'],
          'isNewMessage': currentUserEmail == widget.chatRoomInfo['hastaEmail']
              ? 'No'
              : 'Yes',
        });
        FirebaseFirestore.instance
            .collection(
                '/Users/${widget.chatRoomInfo['doktorEmail']}/konustuklari')
            .doc(widget.chatRoomInfo['hastaEmail'])
            .set({
          'message': messageController.text,
          'sentAt': Timestamp.now(),
          'hastaEmail': widget.chatRoomInfo['hastaEmail'],
          'doktorEmail': widget.chatRoomInfo['doktorEmail'],
          'hastaUserName': widget.chatRoomInfo['hastaUserName'],
          'doktorUserName': widget.chatRoomInfo['doktorUserName'],
          'isNewMessage': currentUserEmail == widget.chatRoomInfo['hastaEmail']
              ? 'Yes'
              : 'No',
        });
      } catch (_) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bir hata oluştu',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      messageController.clear();
      setState(() {
        sendVerifier = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 80,
            padding:
                const EdgeInsets.only(right: 10, bottom: 2, left: 10, top: 10),
            child: TextFormField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Mesaj',
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
              onChanged: (val) {
                if (val.isNotEmpty) {
                  setState(() {
                    sendVerifier = true;
                  });
                } else {
                  setState(() {
                    sendVerifier = false;
                  });
                }
              },
              textInputAction: TextInputAction.done,
            ),
          ),
        ),
        IconButton(
          onPressed: sendVerifier ? sendMessage : null,
          icon: const Icon(
            Icons.send,
          ),
          color: sendVerifier ? Colors.blue : Colors.grey,
        ),
      ],
    );
  }
}
