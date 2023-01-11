import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doktora_sor/models/http_exceptions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import 'chat_room_screen.dart';

class Mesajlar extends StatefulWidget {
  const Mesajlar({Key? key}) : super(key: key);

  @override
  _MesajlarState createState() => _MesajlarState();
}

class _MesajlarState extends State<Mesajlar> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
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
        String currentUserEmail =
            Provider.of<Auth>(context, listen: false).userEmail;
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('/Users/$currentUserEmail/konustuklari')
              .orderBy('sentAt', descending: true)
              .snapshots(),
          builder: (ctx, streamSnapshot) {
            if (streamSnapshot.error != null) {
              return const Center(
                child: Text('Bir hata oluştu'),
              );
            }
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final documents = streamSnapshot.data!.docs;
            if (documents.isEmpty) {
              return const Center(
                child: Text('mesajlarınız yoktur'),
              );
            }
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (ctx, index) {
                if (documents[index].get('sentAt') != null) {
                  DateTime date = DateTime.parse(DateFormat('yyyy-MM-d').format(
                      DateTime.parse(
                          documents[index]['sentAt'].toDate().toString())));
                  DateTime sentAt = DateTime.parse(DateFormat('yyyy-MM-d HH:mm')
                      .format(DateTime.parse(
                          documents[index]['sentAt'].toDate().toString())));
                  DateTime dateNow = DateTime.parse(
                      DateFormat('yyyy-MM-d').format(DateTime.now()));
                  Map<String, String> chatRoomInfo = {
                    'hastaEmail': documents[index]['hastaEmail'],
                    'doktorEmail': documents[index]['doktorEmail'],
                    'hastaUserName': documents[index]['hastaUserName'],
                    'doktorUserName': documents[index]['doktorUserName'],
                    'isNewMessage': documents[index]['isNewMessage'],
                  };

                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(ChatRoom.chatRoomRoute,
                          arguments: chatRoomInfo);
                    },
                    title: Text(
                      currentUserEmail == documents[index]['hastaEmail']
                          ? documents[index]['doktorUserName']
                          : documents[index]['hastaUserName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      documents[index]['message'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: documents[index]['isNewMessage'] == 'Yes'
                            ? FontWeight.bold
                            : null,
                        color: documents[index]['isNewMessage'] == 'Yes'
                            ? Colors.lightBlue
                            : null,
                      ),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dateNow.difference(date).inDays == 0
                              ? 'Bugün'
                              : DateFormat('d/MM').format(date),
                          style: TextStyle(
                            fontWeight:
                                documents[index]['isNewMessage'] == 'Yes'
                                    ? FontWeight.bold
                                    : null,
                            color: documents[index]['isNewMessage'] == 'Yes'
                                ? Colors.lightBlue
                                : null,
                          ),
                        ),
                        Text(
                          DateFormat.Hm().format(sentAt),
                          style: TextStyle(
                            fontWeight:
                                documents[index]['isNewMessage'] == 'Yes'
                                    ? FontWeight.bold
                                    : null,
                            color: documents[index]['isNewMessage'] == 'Yes'
                                ? Colors.lightBlue
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  try {
                    FirebaseFirestore.instance
                        .collection('/Users/$currentUserEmail/konustuklari')
                        .doc(documents[index].toString())
                        .delete();
                  } catch (_) {
                    rethrow;
                  }

                  throw HttpException('');
                }
              },
            );
          },
        );
      },
    );
  }
}
