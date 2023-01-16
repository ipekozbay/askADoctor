import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doktora_sor/providers/yorum_provider.dart';
import 'package:doktora_sor/screens/hasta/drawer_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '/models/hasta.dart';
import '/models/http_exceptions.dart';
import '/providers/hasta_user.dart';

class HastaProfilDuzenleme extends StatefulWidget {
  const HastaProfilDuzenleme({Key? key}) : super(key: key);

  static String HastaProfilDuzenlemeRoute = 'HastaProfilDuzenlemeRoute';

  @override
  _HastaProfilDuzenlemeState createState() => _HastaProfilDuzenlemeState();
}

class _HastaProfilDuzenlemeState extends State<HastaProfilDuzenleme> {
  var form = GlobalKey<FormState>();
  final itemKey = GlobalKey();
  bool isLoading = false;
  bool init = true;
  final ScrollController scrollController = ScrollController();
  late final adController;
  late final soyadController;
  late final kronikHastalikController;
  late String kronikHastalik;
  late String dropDownValue_yas;
  late String dropDownValue_cinsiyet;
  late String dropDownValue_boy;
  late String dropDownValue_kilo;
  late String dropDownValue_kan_grubu;
  var profileImage;
  var firebaseFuture;
  var firebaseStream;

  void previewImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      profileImage = File(pickedImage!.path);
    });
  }

  List<String> kan_gruplari = [
    'Bilinmiyor',
    'O +',
    'O -',
    'A +',
    'A -',
    'B +',
    'B -',
    'AB +',
    'AB -',
  ];

  Hasta hasta = Hasta(
    ad: '',
    soyad: '',
    cinsiyet: '',
    yas: '',
    boy: '',
    kilo: '',
    kanGrubu: '',
    kronikHastalik: '',
  );

  Future scrollToItem() async {
    final context = itemKey.currentContext;
    await Scrollable.ensureVisible(
      context!,
      alignment: 1,
      duration: const Duration(seconds: 1),
    );
  }

  List<DropdownMenuItem> getAges() {
    List<DropdownMenuItem> ages = [];
    for (int i = 12; i < 100; i++) {
      ages.add(DropdownMenuItem(
        value: i.toString(),
        child: Center(
          child: Text(
            i.toString(),
          ),
        ),
      ));
    }
    return ages;
  }

  List<DropdownMenuItem> getWeight() {
    List<DropdownMenuItem> ages = [];
    for (int i = 30; i <= 300; i++) {
      ages.add(DropdownMenuItem(
        value: i.toString(),
        child: Center(
          child: Text(
            "$i kg",
          ),
        ),
      ));
    }
    return ages;
  }

  List<DropdownMenuItem> getHight() {
    List<DropdownMenuItem> ages = [];
    for (int i = 60; i <= 255; i++) {
      ages.add(DropdownMenuItem(
        value: i.toString(),
        child: Center(
          child: Text(
            "$i cm",
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }
    return ages;
  }

  Future<void> saveForm(BuildContext context) async {
    String currentUserEmail =
        Provider.of<Auth>(context, listen: false).userEmail;
    final isValid = form.currentState!.validate();
    if (!isValid) {
      return;
    }
    form.currentState!.save();
    hasta.cinsiyet = dropDownValue_cinsiyet.trim();
    hasta.yas = dropDownValue_yas.trim();
    hasta.boy = dropDownValue_boy.trim();
    hasta.kilo = dropDownValue_kilo.trim();
    hasta.kanGrubu = dropDownValue_kan_grubu.trim();
    if (kronikHastalik == 'Hayır') hasta.kronikHastalik = '';

    if (profileImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('usersProfileImages')
          .child('$currentUserEmail.jpg');
      await ref.putFile(profileImage).whenComplete(() {});
      final url = await ref.getDownloadURL();
      FirebaseFirestore.instance
          .collection('/UsersProfileImages')
          .doc(currentUserEmail)
          .set({
        'image': url,
      });
    }

    FirebaseFirestore.instance
        .collection('/Users/$currentUserEmail/konustuklari')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        FirebaseFirestore.instance
            .collection('/Users/$currentUserEmail/konustuklari')
            .doc(doc.id)
            .update({
          'hastaUserName': '${hasta.ad} ${hasta.soyad}',
          'hastaCinsiyet': hasta.cinsiyet
        });
        FirebaseFirestore.instance
            .collection('/Users/${doc.id}/konustuklari')
            .doc(currentUserEmail)
            .update({
          'hastaUserName': '${hasta.ad} ${hasta.soyad}',
          'hastaCinsiyet': hasta.cinsiyet
        });
      }
    });

    try {
      Provider.of<YorumProvider>(context, listen: false)
          .yorumBilgileriniGuncelle(
        currentUserEmail,
        '${hasta.ad} ${hasta.soyad}',
        hasta.cinsiyet,
      );
      await Provider.of<HastaUser>(context, listen: false)
          .ProfilBilgileriniGuncelle(hasta);

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
  void didChangeDependencies() {
    if (init) {
      String currentUserEmail = Provider.of<Auth>(context).userEmail;
      firebaseFuture = Firebase.initializeApp();
      isLoading = true;
      firebaseStream = FirebaseFirestore.instance
          .collection('/UsersProfileImages')
          .doc(currentUserEmail)
          .snapshots();
      Provider.of<HastaUser>(context, listen: false)
          .fetch_hasta_bilgileri()
          .then((_) {
        Hasta userData = Provider.of<HastaUser>(context, listen: false).hasta;
        adController = TextEditingController(text: userData.ad);
        soyadController = TextEditingController(text: userData.soyad);
        kronikHastalik = userData.kronikHastalik.isEmpty ? 'Hayır' : 'Evet';
        kronikHastalikController =
            TextEditingController(text: userData.kronikHastalik);
        dropDownValue_cinsiyet = userData.cinsiyet;
        dropDownValue_yas = userData.yas;
        dropDownValue_boy = userData.boy;
        dropDownValue_kilo = userData.kilo;
        dropDownValue_kan_grubu = userData.kanGrubu;
        setState(() {
          isLoading = false;
        });
      });
      init = false;
    }

    super.didChangeDependencies();
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
        drawer: Drawer(
          child: HastaDrawerScreen(),
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
                              bottom: 5, left: 20, top: 10, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                future: firebaseFuture,
                                builder: (ctx, data) {
                                  if (data.error != null) {
                                    return const Center(
                                      child: Text('Bir hata oluştu'),
                                    );
                                  }
                                  if (data.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  return StreamBuilder(
                                    stream: firebaseStream as Stream,
                                    builder: (ctx, streamSnapshot) {
                                      if (streamSnapshot.error != null) {
                                        return const Center(
                                          child: Text('Bir hata oluştu'),
                                        );
                                      }
                                      if (streamSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      final document =
                                          streamSnapshot.data!.data();
                                      String imageUrl = document != null
                                          ? document['image']
                                          : '';
                                      return Column(
                                        children: [
                                          if (profileImage == null)
                                            Container(
                                              alignment: Alignment.center,
                                              child: CircleAvatar(
                                                radius: 40,
                                                backgroundColor:
                                                    imageUrl.isEmpty
                                                        ? Colors.lightBlueAccent
                                                        : null,
                                                backgroundImage:
                                                    imageUrl.isNotEmpty
                                                        ? NetworkImage(imageUrl)
                                                        : null,
                                                child: imageUrl.isEmpty
                                                    ? Icon(
                                                        dropDownValue_cinsiyet ==
                                                                'Erkek'
                                                            ? Icons.man_rounded
                                                            : Icons
                                                                .woman_rounded,
                                                        color: Colors.white,
                                                        size: 60,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          if (profileImage != null)
                                            Container(
                                              alignment: Alignment.center,
                                              child: CircleAvatar(
                                                radius: 40,
                                                backgroundImage:
                                                    FileImage(profileImage),
                                              ),
                                            ),
                                          TextButton.icon(
                                            onPressed: previewImage,
                                            icon: const Icon(Icons.image),
                                            label: Text(profileImage == null &&
                                                    imageUrl.isEmpty
                                                ? 'Fotoğraf Yükleyiniz'
                                                : 'Fotoğraf Değiştiriniz'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
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
                                    hasta.ad = enteredValue!.trim();
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
                                    hasta.soyad = enteredValue!.trim();
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 160,
                                    child: DropdownButtonFormField(
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
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 160,
                                    child: DropdownButtonFormField(
                                      itemHeight: 60,
                                      menuMaxHeight: 250,
                                      icon: const Icon(
                                        Icons.arrow_drop_down_circle,
                                        color: Colors.blue,
                                      ),
                                      dropdownColor: Colors.blue.shade50,
                                      decoration: const InputDecoration(
                                        labelText: "Yaşınız",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                        ),
                                      ),
                                      items: getAges(),
                                      value: dropDownValue_yas,
                                      onChanged: (val) {
                                        setState(() {
                                          dropDownValue_yas = val!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 160,
                                    child: DropdownButtonFormField(
                                      itemHeight: 60,
                                      menuMaxHeight: 250,
                                      icon: const Icon(
                                        Icons.arrow_drop_down_circle,
                                        color: Colors.blue,
                                      ),
                                      dropdownColor: Colors.blue.shade50,
                                      decoration: const InputDecoration(
                                        labelText: "Boyunuz",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                        ),
                                      ),
                                      items: getHight(),
                                      value: dropDownValue_boy,
                                      onChanged: (val) {
                                        setState(() {
                                          dropDownValue_boy = val!;
                                        });
                                      },
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 160,
                                    child: DropdownButtonFormField(
                                      itemHeight: 60,
                                      menuMaxHeight: 250,
                                      icon: const Icon(
                                        Icons.arrow_drop_down_circle,
                                        color: Colors.blue,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: "Kilonuz",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                        ),
                                      ),
                                      dropdownColor: Colors.blue.shade50,
                                      items: getWeight(),
                                      value: dropDownValue_kilo,
                                      onChanged: (val) {
                                        setState(() {
                                          dropDownValue_kilo = val!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 160,
                                child: DropdownButtonFormField(
                                  itemHeight: 60,
                                  menuMaxHeight: 250,
                                  icon: const Icon(
                                    Icons.arrow_drop_down_circle,
                                    color: Colors.blue,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: "Kan Grubunuz",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  dropdownColor: Colors.blue.shade50,
                                  items: kan_gruplari
                                      .map(
                                        (kanGrubu) => DropdownMenuItem(
                                          value: kanGrubu,
                                          alignment: Alignment.center,
                                          child: Text(kanGrubu),
                                        ),
                                      )
                                      .toList(),
                                  value: dropDownValue_kan_grubu,
                                  onChanged: (val) {
                                    setState(() {
                                      dropDownValue_kan_grubu = val!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                'Kronik hastalığınız var mı ?',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                      title: const Text('Hayır'),
                                      value: 'Hayır',
                                      groupValue: kronikHastalik,
                                      onChanged: (val) {
                                        setState(() {
                                          kronikHastalik = val!;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile(
                                      title: const Text('Evet'),
                                      value: 'Evet',
                                      groupValue: kronikHastalik,
                                      onChanged: (val) {
                                        setState(() {
                                          kronikHastalik = val!;
                                        });
                                        Future.delayed(const Duration(
                                                milliseconds: 200))
                                            .then((value) => scrollToItem());
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (kronikHastalik == 'Evet')
                                const SizedBox(
                                  height: 20,
                                ),
                              if (kronikHastalik == 'Evet')
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  key: itemKey,
                                  child: TextFormField(
                                    minLines: 3,
                                    maxLength: 250,
                                    maxLines: null,
                                    controller: kronikHastalikController,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'Kronik hastalığınızdan kısaca bahsediniz',
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
                                      hasta.kronikHastalik =
                                          enteredValue!.trim();
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
                        saveForm(context);
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
