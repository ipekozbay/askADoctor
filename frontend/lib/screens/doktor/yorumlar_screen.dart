import 'package:doktora_sor/screens/doktor/dawer_screen.dart';
import 'package:flutter/material.dart';
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
        },
      ),
    );
  }
}
