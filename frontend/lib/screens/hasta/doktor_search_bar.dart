import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
      padding: const EdgeInsets.all(10),
      itemCount: matchQuery.keys.length,
      itemBuilder: (ctx, index) => Column(
        children: [
          ListTile(
            leading: ProfileImage(matchQuery, tumDoktorlar_bilgileri, index),
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
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.lightBlueAccent,
            ),
          ),
          if (matchQuery.keys.toList().length - 1 != index)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: Colors.lightBlueAccent,
              ),
            )
        ],
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
      itemBuilder: (ctx, index) => Column(
        children: [
          ListTile(
            leading: ProfileImage(matchQuery, tumDoktorlar_bilgileri, index),
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
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.lightBlueAccent,
            ),
          ),
          if (matchQuery.keys.toList().length - 1 != index)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: Colors.lightBlueAccent,
              ),
            )
        ],
      ),
    );
  }
}

class ProfileImage extends StatefulWidget {
  final List<Doktor> tumDoktorlar_bilgileri;
  final Map<String, String> matchQuery;
  final int index;

  ProfileImage(this.matchQuery, this.tumDoktorlar_bilgileri, this.index);

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  var firebaseFuture;

  @override
  void initState() {
    firebaseFuture = Firebase.initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseFuture,
      builder: (ctx, data) {
        if (data.error != null) {
          return const Text('!');
        }
        if (data.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('/UsersProfileImages')
              .doc(widget.matchQuery.keys.toList()[widget.index])
              .snapshots(),
          builder: (ctx, streamSnapshot) {
            if (streamSnapshot.error != null) {
              return const Text('!');
            }
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final document = streamSnapshot.data!.data();
            String imageUrl = document != null ? document['image'] : '';

            String onlinestatus = document != null
                ? document['status'] == 'online'
                    ? 'online'
                    : 'offline'
                : '';
            return Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      imageUrl.isEmpty ? Colors.lightBlueAccent : null,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? Icon(
                          widget.tumDoktorlar_bilgileri
                                      .firstWhere((doktor) =>
                                          doktor.email ==
                                          widget.matchQuery.keys
                                              .toList()[widget.index])
                                      .cinsiyet ==
                                  'Erkek'
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
                        onlinestatus == 'online' ? Colors.green : Colors.red,
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
