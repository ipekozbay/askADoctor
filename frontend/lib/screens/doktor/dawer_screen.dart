import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../providers/auth.dart';
import '../../providers/doktor_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profil_duzenleme_screen.dart';
import 'yorumlar_screen.dart';

class DoktorDrawerScreen extends StatelessWidget {
  const DoktorDrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cinsiyet;
    Provider.of<DoktorUser>(context, listen: false)
        .fetch_doktor_bilgileri()
        .then((_) {
      cinsiyet =
          Provider.of<DoktorUser>(context, listen: false).doktor.cinsiyet;
    });
    String currentUserEmail =
        Provider.of<Auth>(context, listen: false).userEmail;
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          color: Colors.blue,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FutureBuilder(
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
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('/UsersProfileImages')
                            .doc(currentUserEmail)
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
                          String imageUrl =
                              document != null ? document['image'] : '';
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl.isEmpty
                                ? Icon(
                                    cinsiyet == 'Erkek'
                                        ? Icons.man_rounded
                                        : Icons.woman_rounded,
                                    size: 80,
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Consumer<DoktorUser>(
                  builder: (context, doktor, _) => Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      doktor.kullaniciAdi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
          leading: const Icon(
            Icons.email,
            color: Colors.blue,
          ),
          title: const Text('Mesajlar'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context)
                .pushNamed(DoktorProfilDuzenleme.DoktorProfilDuzenlemeRoute);
          },
          leading: const Icon(
            Icons.person,
            color: Colors.blue,
          ),
          title: const Text('Profil düzenleme'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(Yorumlar.yorumlarRoute);
          },
          leading: const Icon(
            Icons.comment_sharp,
            color: Colors.blue,
          ),
          title: const Text('Yorumlar'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
        const Spacer(),
        ListTile(
          onTap: () {
            Provider.of<Auth>(context, listen: false).logOut(context);
          },
          leading: const Icon(
            Icons.logout,
            color: Colors.blue,
          ),
          title: const Text('Çıkış'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
