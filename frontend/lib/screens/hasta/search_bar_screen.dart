import 'package:flutter/material.dart';

import '/models/tip_bilim_dallari.dart';
import 'doktorlar_screen.dart';
import 'uzmanlik_alanlari_screen.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<String> searchTerms;

  CustomSearchDelegate(this.searchTerms);

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
    List<String> matchQuery = [];
    for (var term in searchTerms) {
      if (term.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(term);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (ctx, index) => ListTile(
        title: Text(matchQuery[index]),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var term in searchTerms) {
      if (term.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(term);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (ctx, index) => ListTile(
        title: Text(matchQuery[index]),
        onTap: () {
          String ilkBilimDali = Tip().bolumler.keys.first;
          if (Tip().bolumler.keys.contains(matchQuery[index])) {
            Navigator.of(ctx).pushNamed(
              UzmanlikAlanlari.uzmanlikAlanlariRoute,
              arguments: Tip().bolumler[matchQuery[index]],
            );
          } else if (searchTerms.contains(Tip().bolumler[ilkBilimDali]![0])) {
            Navigator.of(context).pushNamed(
                DoktorlarScreen.DoktorlarScreenRoute,
                arguments: matchQuery[index]);
          }
        },
      ),
    );
  }
}
