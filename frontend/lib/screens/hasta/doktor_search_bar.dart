import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doktor.dart';
import '../../providers/doktor_user.dart';
import 'doktor_tabs_screen.dart';

class DoktorCustomSearchDelegate extends SearchDelegate {
  final Map<String, String> doktorlar;
  final List<Doktor> tumDoktorlar_bilgileri;

  DoktorCustomSearchDelegate(this.doktorlar, this.tumDoktorlar_bilgileri);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Map<String, String> matchQuery = {};
    List<String> emails = doktorlar.keys.toList();
    String term;
    for (var email in emails) {
      term = doktorlar[email]!;
      if (term.toLowerCase().contains(query.toLowerCase())) {
        matchQuery[email] = term;
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (ctx, index) => ListTile(
        title: Text(matchQuery[matchQuery.keys.toList()[index]]!),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Map<String, String> matchQuery = {};
    List<String> emails = doktorlar.keys.toList();
    String term;
    for (var email in emails) {
      term = doktorlar[email]!;
      if (term.toLowerCase().contains(query.toLowerCase())) {
        matchQuery[email] = term;
      }
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: matchQuery.keys.length,
      itemBuilder: (ctx, index) => ListTile(
        leading: Icon(tumDoktorlar_bilgileri
                    .firstWhere((doktor) =>
                        doktor.email == matchQuery.keys.toList()[index])
                    .cinsiyet ==
                'Erkek'
            ? Icons.man_rounded
            : Icons.woman_rounded),
        title: Text(matchQuery[matchQuery.keys.toList()[index]]!),
        subtitle: Row(
          children: [
            Text(
              tumDoktorlar_bilgileri
                  .firstWhere((doktor) =>
                      doktor.email == matchQuery.keys.toList()[index])
                  .hastaneTuru,
              style: const TextStyle(
                color: Colors.lightGreen,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              tumDoktorlar_bilgileri
                  .firstWhere((doktor) =>
                      doktor.email == matchQuery.keys.toList()[index])
                  .hastaneAdi,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: () {
          //print(matchQuery.keys.toList()[index]);

          Provider.of<DoktorUser>(context, listen: false)
              .GetOneDoctorData(matchQuery.keys.toList()[index])
              .then((_) {
            Doktor doktor =
                Provider.of<DoktorUser>(context, listen: false).doktor;
            Navigator.of(context).pushNamed(
                DoktorTabsScreen.doktorTabsScreenRoute,
                arguments: doktor);
          });
        },
      ),
    );
  }
}
