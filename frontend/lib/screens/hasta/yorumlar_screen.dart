import 'package:flutter/material.dart';
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

  @override
  void initState() {
    yorum = Yorum(
      gonderenKullaniciAdi:
          Provider.of<HastaUser>(context, listen: false).kullaniciAdi,
      gonderenEmail: Provider.of<HastaUser>(context, listen: false).userEmail,
      alici: widget.doktor.email,
      icerik: '',
    );

    fetchYorumlar = Provider.of<YorumProvider>(context, listen: false)
        .fetch_yorumlar(widget.doktor.email);
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
                                        title: Text(
                                          yorum.gonderenKullaniciAdi,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(yorum.icerik),
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
