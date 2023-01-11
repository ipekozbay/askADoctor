import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doktor.dart';
import '../../providers/doktor_user.dart';
import '/models/tip_bilim_dallari.dart';
import 'doktor_search_bar.dart';
import 'search_bar_screen.dart';

class HastaHomeScreen extends StatefulWidget {
  const HastaHomeScreen({Key? key}) : super(key: key);

  @override
  _HastaHomeScreenState createState() => _HastaHomeScreenState();
}

class _HastaHomeScreenState extends State<HastaHomeScreen> {
  List<String> tumUzmanlikAlanlari() {
    List<String> uzmanlikAlanlari = [];
    Map<String, List<String>> bolumler = Tip().bolumler;
    for (var bolum in bolumler.keys) {
      uzmanlikAlanlari += bolumler[bolum]!;
    }
    return uzmanlikAlanlari;
  }

  Map<String, String> doktorlar = {};
  List<Doktor> tumDoktorlar_bilgileri = [];
  late Future future;

  @override
  void initState() {
    future = Provider.of<DoktorUser>(context, listen: false)
        .get_tumDoktorlar()
        .then((_) {
      tumDoktorlar_bilgileri =
          Provider.of<DoktorUser>(context, listen: false).tumDoktorlar;
      for (int i = 0; i < tumDoktorlar_bilgileri.length; i++) {
        doktorlar[tumDoktorlar_bilgileri[i].email] =
            '${tumDoktorlar_bilgileri[i].ad} ${tumDoktorlar_bilgileri[i].soyad}';
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (ctx, data) {
        if (data.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                          ),
                          backgroundColor: Colors.white,
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: DoktorCustomSearchDelegate(
                              doktorlar,
                              tumDoktorlar_bilgileri,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.red,
                          size: 35,
                        ),
                        label: const Text(
                          'doktor araması',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                          ),
                          backgroundColor: Colors.white,
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(
                                Tip().bolumler.keys.toList()),
                          );
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.blue,
                          size: 35,
                        ),
                        label: const Text(
                          'Ana bilim dalına göre arama',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          backgroundColor: Colors.white,
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate:
                                CustomSearchDelegate(tumUzmanlikAlanlari()),
                          );
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.green,
                          size: 35,
                        ),
                        label: const Text(
                          'Uzmanlık alanına göre arama',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
