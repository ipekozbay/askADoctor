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
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(''),
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
                        'hastaEmail': Provider.of<Auth>(context,listen: false).userEmail,
                        'doktorEmail': doktor.email,
                        'hastaUserName': Provider.of<Auth>(context,listen: false).kullaniciAdi,
                        'doktorUserName': '${doktor.ad} ${doktor.soyad}',
                        'isNewMessage' : 'No',
                      };
                      Navigator.of(context).pushNamed(ChatRoom.chatRoomRoute,arguments: chatRoomInfo);
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
