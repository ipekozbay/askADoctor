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
  late Future fetchDoktor;

  @override
  void didChangeDependencies() {
    uzmanlikAlani = ModalRoute.of(context)!.settings.arguments as String;
    fetchDoktor = Provider.of<DoktorUser>(context, listen: false)
        .filter_doktors_byUzmanlikAlani(uzmanlikAlani);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
                          (doktor) => ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  DoktorTabsScreen.doktorTabsScreenRoute,
                                  arguments: doktor);
                            },
                            leading: Icon(
                              doktor.cinsiyet == 'Erkek'
                                  ? Icons.man_rounded
                                  : Icons.woman_rounded,
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
