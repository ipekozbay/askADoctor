import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../providers/auth.dart';
import '../../providers/hasta_user.dart';
import '../hasta/profil_duzenleme_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HastaDrawerScreen extends StatelessWidget {
  const HastaDrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cinsiyet;
    Provider.of<HastaUser>(context, listen: false)
        .fetch_hasta_bilgileri()
        .then((_) {
      cinsiyet = Provider.of<HastaUser>(context, listen: false).hasta.cinsiyet;
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
                        return const Text('!');
                      }
                      if (data.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('/UsersProfileImages')
                            .doc(currentUserEmail)
                            .snapshots(),
                        builder: (ctx, streamSnapshot) {
                          if (streamSnapshot.error != null) {
                            return const Text('!');
                          }
                          if (streamSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
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
                Consumer<HastaUser>(
                  builder: (context, hasta, _) => Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      hasta.kullaniciAdi,
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
            Icons.home_filled,
            color: Colors.blue,
          ),
          title: const Text('Ana sayfa'),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context)
                .pushNamed(HastaProfilDuzenleme.HastaProfilDuzenlemeRoute);
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
