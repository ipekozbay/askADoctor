import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doktora_sor/screens/doktor/dawer_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/doktor_user.dart';
import '../../providers/yorum_provider.dart';

class Yorumlar extends StatefulWidget {
  static String yorumlarRoute = 'yorumlarRoute';

  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  late Future fetchYorumlar;

  @override
  void initState() {
    String email = Provider.of<DoktorUser>(context, listen: false).userEmail;

    fetchYorumlar = Provider.of<YorumProvider>(context, listen: false)
        .fetch_yorumlar(email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlar'),
      ),
      drawer: const Drawer(
        child: DoktorDrawerScreen(),
      ),
      body: FutureBuilder(
        future: fetchYorumlar,
        builder: (ctx, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (data.error != null) {
            return Center(
              child: Text(data.error.toString()),
            );
          } else if (Provider.of<YorumProvider>(context, listen: false)
              .yorumlar
              .isEmpty) {
            return const Center(
              child: Text('Sizin hakkınızda yorum yoktur'),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Consumer<YorumProvider>(
                builder: (ctx, yorumProvider, _) => Column(
                  children: [
                    ...yorumProvider.yorumlar.reversed
                        .map(
                          (yorum) => Column(
                            children: [
                              ListTile(
                                leading: FutureBuilder(
                                  future: Firebase.initializeApp(),
                                  builder: (ctx, data) {
                                    if (data.error != null) {
                                      return const Text('!');
                                    }
                                    if (data.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('/UsersProfileImages')
                                          .doc(yorum.gonderenEmail)
                                          .snapshots(),
                                      builder: (ctx, streamSnapshot) {
                                        if (streamSnapshot.error != null) {
                                          return const Text('!');
                                        }
                                        if (streamSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        }
                                        final document =
                                            streamSnapshot.data!.data();
                                        String imageUrl = document != null
                                            ? document['image']
                                            : '';
                                        return CircleAvatar(
                                          radius: 30,
                                          backgroundColor: imageUrl.isEmpty
                                              ? Colors.lightBlueAccent
                                              : null,
                                          backgroundImage: imageUrl.isNotEmpty
                                              ? NetworkImage(imageUrl)
                                              : null,
                                          child: imageUrl.isEmpty
                                              ? Icon(
                                                  yorum.gonderenKullanicininCinsiyeti ==
                                                          'Erkek'
                                                      ? Icons.man_rounded
                                                      : Icons.woman_rounded,
                                                  size: 40,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        );
                                      },
                                    );
                                  },
                                ),
                                title: Text(
                                  yorum.gonderenKullaniciAdi,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(yorum.icerik),
                                trailing: Column(
                                  children: [
                                    Text(DateTime.now()
                                                .difference(yorum.createdAt)
                                                .inDays ==
                                            0
                                        ? 'Bugün'
                                        : DateFormat('d/MM').format(yorum
                                            .createdAt
                                            .add(const Duration(hours: 3)))),
                                    Text(DateFormat.Hm().format(yorum.createdAt
                                        .add(const Duration(hours: 3)))),
                                  ],
                                ),
                              ),
                              if (yorumProvider.yorumlar.reversed.last != yorum)
                                const Divider(color: Colors.blue),
                            ],
                          ),
                        )
                        .toList()
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
