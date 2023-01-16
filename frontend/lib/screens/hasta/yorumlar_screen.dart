import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/doktor.dart';
import '../../models/yorum.dart';
import '../../providers/hasta_user.dart';
import '../../providers/yorum_provider.dart';

class DoktorYorumlar extends StatefulWidget {
  final Doktor doktor;

  DoktorYorumlar(this.doktor);

  @override
  _DoktorYorumlarState createState() => _DoktorYorumlarState();
}

class _DoktorYorumlarState extends State<DoktorYorumlar> {
  bool sendVerifier = false;
  late Yorum yorum;
  var yorumController = TextEditingController();
  late Future fetchYorumlar;
  var firebaseFuture;

  @override
  void initState() {
    yorum = Yorum(
      gonderenKullaniciAdi:
          Provider.of<HastaUser>(context, listen: false).kullaniciAdi,
      gonderenKullanicininCinsiyeti:
          Provider.of<HastaUser>(context, listen: false).cinsiyet,
      gonderenEmail: Provider.of<HastaUser>(context, listen: false).userEmail,
      alici: widget.doktor.email,
      icerik: '',
      createdAt: DateTime.now(),
    );
    firebaseFuture = Firebase.initializeApp();
    fetchYorumlar = Provider.of<YorumProvider>(context, listen: false)
        .fetch_yorumlar(widget.doktor.email);

    // DocumentReference documentReference = FirebaseFirestore.instance
    //     .collection('/UsersProfileImages')
    //     .doc(widget.yorum.gonderenEmail);
    // documentReference.get().then((snapshot) {
    //   imageUrl = snapshot.get('image') ?? '';
    //   print(imageUrl);
    // });
    super.initState();
  }

  void sendComment() async {
    FocusScope.of(context).unfocus();
    yorum.icerik = yorumController.text;
    try {
      if (yorum.alici.isNotEmpty) {
        await Provider.of<YorumProvider>(context, listen: false)
            .yorumEkle(yorum);
        yorumController.clear();
        setState(() {
          sendVerifier = false;
        });
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bir hata oluştu'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserName = Provider.of<HastaUser>(context).kullaniciAdi;

    return GestureDetector(
      onTap: () {
        final FocusScopeNode currentScope = FocusScope.of(context);
        if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
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
                      child: Text('Bu hekim hakkında yorum yoktur'),
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
                                          future: firebaseFuture,
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
                                                  .collection(
                                                      '/UsersProfileImages')
                                                  .doc(yorum.gonderenEmail)
                                                  .snapshots(),
                                              builder: (ctx, streamSnapshot) {
                                                if (streamSnapshot.error !=
                                                    null) {
                                                  return const Text('!');
                                                }
                                                if (streamSnapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircularProgressIndicator();
                                                }
                                                final document =
                                                    streamSnapshot.data!.data();
                                                String imageUrl =
                                                    document != null
                                                        ? document['image']
                                                        : '';
                                                return CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: imageUrl
                                                          .isEmpty
                                                      ? Colors.lightBlueAccent
                                                      : null,
                                                  backgroundImage: imageUrl
                                                          .isNotEmpty
                                                      ? NetworkImage(imageUrl)
                                                      : null,
                                                  child: imageUrl.isEmpty
                                                      ? Icon(
                                                          yorum.gonderenKullanicininCinsiyeti ==
                                                                  'Erkek'
                                                              ? Icons
                                                                  .man_rounded
                                                              : Icons
                                                                  .woman_rounded,
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
                                          currentUserName ==
                                                  yorum.gonderenKullaniciAdi
                                              ? 'Siz'
                                              : yorum.gonderenKullaniciAdi,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(yorum.icerik),
                                        trailing: Column(
                                          children: [
                                            Text(DateTime.now()
                                                        .difference(
                                                            yorum.createdAt)
                                                        .inDays ==
                                                    0
                                                ? 'Bugün'
                                                : DateFormat('d/MM')
                                                    .format(yorum.createdAt.add(const Duration(hours: 3)))),
                                            Text(DateFormat.Hm()
                                                .format(yorum.createdAt.add(const Duration(hours: 3)))),
                                          ],
                                        ),
                                      ),
                                      if (yorumProvider
                                              .yorumlar.reversed.last !=
                                          yorum)
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
                }),
          ),
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 7,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  height: 85,
                  padding: const EdgeInsets.only(
                      right: 10, bottom: 2, left: 10, top: 10),
                  child: TextFormField(
                    controller: yorumController,
                    maxLength: 255,
                    decoration: const InputDecoration(
                      labelText: 'Yorum yapınız',
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
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
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: IconButton(
                  onPressed: sendVerifier ? sendComment : null,
                  icon: const Icon(
                    Icons.send,
                  ),
                  color: sendVerifier ? Colors.blue : Colors.black,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
