import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import 'send_message.dart';

class ChatRoom extends StatefulWidget {
  static String chatRoomRoute = 'chatRoomRoute';

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  var firebaseFuture;
  var firebaseStream;
  bool init = true;


  @override
  void didChangeDependencies() {
    if(init){
      Map<String, String> chatRoomInfo =
      ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      firebaseFuture = Firebase.initializeApp();
      firebaseStream = FirebaseFirestore.instance
          .collection(
          '/Users/${chatRoomInfo['hastaEmail']}/konustuklari/${chatRoomInfo['doktorEmail']}/sohbet')
          .orderBy(
        'sentAt',
        descending: true,
      )
          .snapshots();
      init = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> chatRoomInfo =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    String currentUserEmail =
        Provider.of<Auth>(context, listen: false).userEmail;

    String otherUserEmail = currentUserEmail == chatRoomInfo['hastaEmail']
        ? chatRoomInfo['doktorEmail'] as String
        : chatRoomInfo['hastaEmail'] as String;

    String currentUserName =
        Provider.of<Auth>(context, listen: false).kullaniciAdi;

    String otherUserName = currentUserName == chatRoomInfo['hastaUserName']
        ? chatRoomInfo['doktorUserName'] as String
        : chatRoomInfo['hastaUserName'] as String;

    return GestureDetector(
      onTap: () {
        final FocusScopeNode currentScope = FocusScope.of(context);
        if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(otherUserName),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: firebaseFuture,
                builder: (ctx, data) {
                  if (data.error != null) {
                    return const Center(
                      child: Text('Bir hata oluştu'),
                    );
                  }
                  if (data.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  print(firebaseStream);
                  return StreamBuilder(
                    stream: firebaseStream as Stream,
                    builder: (ctx, streamSnapshot) {
                      if (streamSnapshot.error != null) {
                        return const Center(
                          child: Text('Bir hata oluştu'),
                        );
                      }
                      if (streamSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final documents = streamSnapshot.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        itemCount: documents.length,
                        itemBuilder: (ctx, index) {
                          try {
                            FirebaseFirestore.instance
                                .collection(
                                    '/Users/$currentUserEmail/konustuklari')
                                .doc(otherUserEmail)
                                .update({
                              'isNewMessage': 'No',
                            });
                          } catch (_) {
                            rethrow;
                          }

                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: currentUserEmail ==
                                      documents[index]['sentByEmail']
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: documents[index]['message'].length > 23
                                      ? (MediaQuery.of(context).size.width /
                                              2) +
                                          5
                                      : null,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12),
                                      topRight: const Radius.circular(12),
                                      bottomLeft: currentUserEmail ==
                                              documents[index]['sentByEmail']
                                          ? const Radius.circular(12)
                                          : const Radius.circular(0),
                                      bottomRight: currentUserEmail ==
                                              documents[index]['sentByEmail']
                                          ? const Radius.circular(0)
                                          : const Radius.circular(12),
                                    ),
                                    color: currentUserEmail ==
                                            documents[index]['sentByEmail']
                                        ? Colors.lightBlue
                                        : Colors.grey[300],
                                  ),
                                  child: Text(
                                    documents[index]['message'],
                                    style: TextStyle(
                                      color: currentUserEmail ==
                                              documents[index]['sentByEmail']
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SendMessage(chatRoomInfo),
          ],
        ),
      ),
    );
  }
}
