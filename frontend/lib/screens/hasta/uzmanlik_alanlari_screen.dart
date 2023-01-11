import 'package:flutter/material.dart';

import 'doktorlar_screen.dart';

class UzmanlikAlanlari extends StatelessWidget {
  static String uzmanlikAlanlariRoute = 'uzmanlikAlanlariRoute';

  @override
  Widget build(BuildContext context) {
    List<String> tumUzmanlikAlanlari =
        ModalRoute.of(context)!.settings.arguments as List<String>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzmanlık Alanları'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: tumUzmanlikAlanlari
              .map(
                (uzmanlikAlan) => ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        DoktorlarScreen.DoktorlarScreenRoute,
                        arguments: uzmanlikAlan);
                  },
                  title: Text(uzmanlikAlan),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
