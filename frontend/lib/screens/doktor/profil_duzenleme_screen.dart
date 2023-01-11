import 'package:doktora_sor/models/tip_bilim_dallari.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doktor.dart';
import '../../providers/doktor_user.dart';
import '/models/http_exceptions.dart';
import 'dawer_screen.dart';

class DoktorProfilDuzenleme extends StatefulWidget {
  const DoktorProfilDuzenleme({Key? key}) : super(key: key);

  static String DoktorProfilDuzenlemeRoute = 'DoktorProfilDuzenlemeRoute';

  @override
  _DoktorProfilDuzenlemeState createState() => _DoktorProfilDuzenlemeState();
}

class _DoktorProfilDuzenlemeState extends State<DoktorProfilDuzenleme> {
  var form = GlobalKey<FormState>();
  bool isLoading = false;
  final ScrollController scrollController = ScrollController();
  late final adController;
  late final soyadController;
  late final mezuniyetUniController;
  late final hastaneAdiController;
  late String hastaneTuru;
  late String dropDownValue_bilimDali;
  late String dropDownValue_cinsiyet;
  late String dropDownValue_uzmanlikAlani;

  Doktor doktor = Doktor(
    email: '',
    ad: '',
    soyad: '',
    cinsiyet: '',
    mezuniyetUni: '',
    bilimDali: '',
    uzmanlikAlani: '',
    hastaneTuru: '',
    hastaneAdi: '',
  );

  List<DropdownMenuItem> getBilimDallari() {
    List<DropdownMenuItem> bilim_dallari = [];
    for (String bilimDali in Tip().bolumler.keys.toList()) {
      bilim_dallari.add(DropdownMenuItem(
        value: bilimDali,
        child: Center(
          child: Text(
            bilimDali,
          ),
        ),
      ));
    }
    return bilim_dallari;
  }

  List<DropdownMenuItem> getUzmanlikAlanlari() {
    List<DropdownMenuItem> uzmanlikAlanlari = [];
    dropDownValue_uzmanlikAlani = Tip().bolumler[dropDownValue_bilimDali]![0];
    for (String uzmanlikAlani in Tip().bolumler[dropDownValue_bilimDali]!) {
      uzmanlikAlanlari.add(DropdownMenuItem(
        value: uzmanlikAlani,
        child: Center(
          child: Text(
            uzmanlikAlani,
          ),
        ),
      ));
    }
    return uzmanlikAlanlari;
  }

  Future<void> saveForm() async {
    final isValid = form.currentState!.validate();
    if (!isValid) {
      return;
    }
    form.currentState!.save();

    doktor.cinsiyet = dropDownValue_cinsiyet.trim();
    doktor.bilimDali = dropDownValue_bilimDali.trim();
    doktor.uzmanlikAlani = dropDownValue_uzmanlikAlani.trim();
    doktor.hastaneTuru = hastaneTuru.trim();

    try {
      await Provider.of<DoktorUser>(context, listen: false)
          .ProfilBilgileriniGuncelle(doktor);
    } on HttpException catch (info) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          info.message,
          textAlign: TextAlign.center,
        )),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          error.toString(),
          textAlign: TextAlign.center,
        )),
      );
    }
  }

  @override
  void initState() {
    isLoading = true;
    Provider.of<DoktorUser>(context, listen: false)
        .fetch_doktor_bilgileri()
        .then((_) {
      Doktor userData = Provider.of<DoktorUser>(context, listen: false).doktor;
      adController = TextEditingController(text: userData.ad);
      soyadController = TextEditingController(text: userData.soyad);
      mezuniyetUniController =
          TextEditingController(text: userData.mezuniyetUni);
      hastaneAdiController = TextEditingController(text: userData.hastaneAdi);
      dropDownValue_cinsiyet = userData.cinsiyet;
      dropDownValue_bilimDali = userData.bilimDali;
      dropDownValue_uzmanlikAlani = userData.uzmanlikAlani;
      hastaneTuru = userData.hastaneTuru;
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil düzenle'),
          centerTitle: true,
        ),
        drawer: const Drawer(
          child: DoktorDrawerScreen(),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: Container(
                      child: Form(
                        key: form,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                              bottom: 40, left: 20, top: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: TextFormField(
                                  controller: adController,
                                  decoration: const InputDecoration(
                                    labelText: 'adınız',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Lütfen Adınızı Giriniz';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  onSaved: (enteredValue) {
                                    doktor.ad = enteredValue!.trim();
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: TextFormField(
                                  controller: soyadController,
                                  decoration: const InputDecoration(
                                    labelText: 'Soyadınız',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Lütfen Soyadınızı Giriniz';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  onSaved: (enteredValue) {
                                    doktor.soyad = enteredValue!.trim();
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: TextFormField(
                                  controller: mezuniyetUniController,
                                  decoration: const InputDecoration(
                                    labelText: 'Mezuniyet üniversitesi',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Lütfen mezun olduğunuz üniversite adını Giriniz';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  onSaved: (enteredValue) {
                                    doktor.mezuniyetUni = enteredValue!.trim();
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              DropdownButtonFormField(
                                itemHeight: 60,
                                icon: const Icon(
                                  Icons.arrow_drop_down_circle,
                                  color: Colors.blue,
                                ),
                                dropdownColor: Colors.blue.shade50,
                                decoration: const InputDecoration(
                                  labelText: "Cinsiyetiniz",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Erkek',
                                    child: Text('Erkek'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Kadın',
                                    child: Text('Kadın'),
                                  ),
                                ],
                                value: dropDownValue_cinsiyet,
                                onChanged: (val) {
                                  setState(() {
                                    dropDownValue_cinsiyet = val!;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField(
                                itemHeight: 60,
                                menuMaxHeight: 250,
                                icon: const Icon(
                                  Icons.arrow_drop_down_circle,
                                  color: Colors.blue,
                                ),
                                dropdownColor: Colors.blue.shade50,
                                decoration: const InputDecoration(
                                  labelText: "Bilim dalınız",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                items: getBilimDallari(),
                                value: dropDownValue_bilimDali,
                                onChanged: (val) {
                                  setState(() {
                                    dropDownValue_bilimDali = val!;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField(
                                itemHeight: 60,
                                menuMaxHeight: 250,
                                icon: const Icon(
                                  Icons.arrow_drop_down_circle,
                                  color: Colors.blue,
                                ),
                                decoration: const InputDecoration(
                                  labelText: "Uzmanlık alanınız",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                dropdownColor: Colors.blue.shade50,
                                items: getUzmanlikAlanlari(),
                                value: dropDownValue_uzmanlikAlani,
                                onChanged: (val) {
                                  setState(() {
                                    dropDownValue_uzmanlikAlani = val!;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              const Text(
                                'Nerede çalışıyorsunuz ?',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    flex: 12,
                                    child: RadioListTile(
                                      title: const Text('Kamu hastane'),
                                      value: 'Kamu hastane',
                                      groupValue: hastaneTuru,
                                      onChanged: (val) {
                                        setState(() {
                                          hastaneTuru = val!;
                                        });
                                      },
                                    ),
                                  ),
                                  Flexible(
                                    flex: 10,
                                    child: RadioListTile(
                                      title: const Text('Özel klinik'),
                                      value: 'Özel klinik',
                                      groupValue: hastaneTuru,
                                      onChanged: (val) {
                                        setState(() {
                                          hastaneTuru = val!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: TextFormField(
                                  maxLength: 100,
                                  maxLines: null,
                                  controller: hastaneAdiController,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Çalıştığınız yerin adını giriniz',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bu alanı boş bırakmayınız';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  onSaved: (enteredValue) {
                                    doktor.hastaneAdi = enteredValue!.trim();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 70,
                    margin: const EdgeInsets.only(
                      right: 5,
                      left: 5,
                    ),
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        saveForm();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20)),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      child: const Text('Değişikleri kaydet'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
