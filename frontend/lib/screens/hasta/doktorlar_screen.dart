import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/doktor_user.dart';
import 'doktor_tabs_screen.dart';

class DoktorlarScreen extends StatefulWidget {
  const DoktorlarScreen({Key? key}) : super(key: key);

  static String DoktorlarScreenRoute = 'DoktorlarScreenRoute';

  @override
  _DoktorlarScreenState createState() => _DoktorlarScreenState();
}

class _DoktorlarScreenState extends State<DoktorlarScreen> {
  late String uzmanlikAlani;
  bool init = true;
  var fetchDoktor;

  @override
  Widget build(BuildContext context) {
    uzmanlikAlani = ModalRoute.of(context)!.settings.arguments as String;
    fetchDoktor = Provider.of<DoktorUser>(context, listen: false)
        .filter_doktors_byUzmanlikAlani(uzmanlikAlani);
    return Scaffold(
      appBar: AppBar(
        title: Text(uzmanlikAlani),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: fetchDoktor,
        builder: (ctx, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (data.error != null) {
            return const Center(
              child: Text('Bir hata oluştu'),
            );
          } else if (Provider.of<DoktorUser>(context, listen: false)
              .doktorlar
              .isEmpty) {
            return const Center(
              child: Text(
                  'Bu uzmanlık alanında geçici olarak doktor bulunmamaktadır'),
            );
          } else {
            return Consumer<DoktorUser>(
              builder: (ctx, doktorUser, _) => SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ...doktorUser.doktorlar
                        .map(
                          (doktor) => Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      DoktorTabsScreen.doktorTabsScreenRoute,
                                      arguments: doktor);
                                },
                                leading: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('/UsersProfileImages')
                                      .doc(doktor.email)
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
                                    String onlinestatus = document != null
                                        ? document['status'] == 'online'
                                            ? 'online'
                                            : 'offline'
                                        : '';
                                    return Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: imageUrl.isEmpty
                                              ? Colors.lightBlueAccent
                                              : null,
                                          backgroundImage: imageUrl.isNotEmpty
                                              ? NetworkImage(imageUrl)
                                              : null,
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
                                          right: 6,
                                          child: CircleAvatar(
                                            radius: 5,
                                            backgroundColor:
                                                onlinestatus == 'online'
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                ),
                                title: Text('${doktor.ad} ${doktor.soyad}'),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      '${doktor.hastaneTuru} :',
                                      style: const TextStyle(
                                        color: Colors.lightGreen,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      doktor.hastaneAdi,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                              if (doktorUser.doktorlar.last != doktor)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: const Divider(
                                      color: Colors.lightBlueAccent),
                                ),
                            ],
                          ),
                        )
                        .toList(),
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
