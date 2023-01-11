import 'package:flutter/material.dart';

import '../../models/doktor.dart';
import 'doktor_profil_screen.dart';
import 'yorumlar_screen.dart';

class DoktorTabsScreen extends StatefulWidget {
  const DoktorTabsScreen({Key? key}) : super(key: key);

  static String doktorTabsScreenRoute = 'doktorTabsScreenRoute';

  @override
  _DoktorTabsScreenState createState() => _DoktorTabsScreenState();
}

class _DoktorTabsScreenState extends State<DoktorTabsScreen> {



  @override
  Widget build(BuildContext context) {
    Doktor doktor = ModalRoute.of(context)!.settings.arguments as Doktor;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${doktor.ad} ${doktor.soyad}'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.person),
                text: 'Profil',
              ),
              Tab(
                icon: Icon(Icons.comment),
                text: 'Yorumlar',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            DoktorProfilScreen(doktor),
            DoktorYorumlar(doktor),
          ],
        ),
      ),
    );
  }
}
