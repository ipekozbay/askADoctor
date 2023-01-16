import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doktora_sor/providers/hasta_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doktor.dart';
import '../../providers/auth.dart';
import '../chat_room_screen.dart';

class DoktorProfilScreen extends StatelessWidget {
  final Doktor doktor;

  DoktorProfilScreen(this.doktor);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FutureBuilder(
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
            return Container(
              alignment: Alignment.center,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('/UsersProfileImages')
                    .doc(doktor.email)
                    .snapshots(),
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
                  final document = streamSnapshot.data!.data();
                  String imageUrl = document != null ? document['image'] : '';

                  String onlinestatus = document != null
                      ? document['status'] == 'online'
                          ? 'online'
                          : 'offline'
                      : '';
                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            imageUrl.isEmpty ? Colors.lightBlueAccent : null,
                        backgroundImage:
                            imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child: imageUrl.isEmpty
                            ? Icon(
                                doktor.cinsiyet == 'Erkek'
                                    ? Icons.man_rounded
                                    : Icons.woman_rounded,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        top: 6,
                        right: 6,

                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: onlinestatus == 'online'
                              ? Colors.green
                              : Colors.red,
                        ),
                      )
                    ],
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(
          height: 20,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Mezun olduğu üniversite',
                  ),
                  subtitle: Text(
                    doktor.mezuniyetUni,
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    'Hekimlik yaptığı Bilim Dalı',
                  ),
                  subtitle: Text(
                    doktor.bilimDali,
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    'Uzmanlık alanı',
                  ),
                  subtitle: Text(
                    doktor.uzmanlikAlani,
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    doktor.hastaneTuru,
                  ),
                  subtitle: Text(
                    doktor.hastaneAdi,
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Map<String, String> chatRoomInfo = {
                        'hastaEmail':
                            Provider.of<Auth>(context, listen: false).userEmail,
                        'doktorEmail': doktor.email,
                        'hastaUserName':
                            Provider.of<HastaUser>(context, listen: false)
                                .kullaniciAdi,
                        'hastaCinsiyet':
                            Provider.of<HastaUser>(context, listen: false)
                                .cinsiyet,
                        'doktorCinsiyet': doktor.cinsiyet,
                        'doktorUserName': '${doktor.ad} ${doktor.soyad}',
                        'isNewMessage': 'No',
                      };
                      Navigator.of(context).pushNamed(ChatRoom.chatRoomRoute,
                          arguments: chatRoomInfo);
                    },
                    child: const Text(
                      'Mesaj gönderiniz',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
