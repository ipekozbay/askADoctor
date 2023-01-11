import '../models/doktor.dart';
import '../models/hasta.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exceptions.dart';
import '../providers/auth.dart';

enum AuthMode {
  login,
  signUp,
}

enum AuthPerson {
  hasta,
  doktor,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode authMode = AuthMode.login;
  AuthPerson authPerson = AuthPerson.hasta;
  final passwordController = TextEditingController();
  var form = GlobalKey<FormState>();
  bool isLoading = false;
  Map<String, String> authData = {
    'email': '',
    'password': '',
  };
  Hasta hasta = Hasta(
    ad: 'Hasta',
    soyad: 'Kullanıcı',
    cinsiyet: 'Erkek',
    yas: '18',
    boy: '165',
    kilo: '60',
    kanGrubu: 'Bilinmiyor',
    kronikHastalik: '',
  );

  Doktor doktor = Doktor(
    email: '',
    ad: 'Doktor',
    soyad: 'Kullanıcı',
    cinsiyet: 'Erkek',
    mezuniyetUni: '',
    bilimDali: 'Halk Sağlığı',
    uzmanlikAlani: 'Epidemiyoloji',
    hastaneTuru: 'Kamu hastane',
    hastaneAdi: '',
  );

  void toggle_hasta_doktor() {
    if (authPerson == AuthPerson.hasta) {
      setState(() {
        authPerson = AuthPerson.doktor;
      });
    } else {
      setState(() {
        authPerson = AuthPerson.hasta;
      });
    }
  }

  void toggleAuth() {
    if (authMode == AuthMode.signUp) {
      setState(() {
        authMode = AuthMode.login;
      });
    } else {
      setState(() {
        authMode = AuthMode.signUp;
      });
    }
  }

  Future<void> saveForm() async {
    final isValid = form.currentState!.validate();
    if (!isValid) {
      return;
    }
    form.currentState!.save();

    try {
      setState(() {
        isLoading = true;
      });
      if (authPerson == AuthPerson.hasta) {
        if (authMode == AuthMode.signUp) {
          bool emailKayitli = await Provider.of<Auth>(context, listen: false)
              .Check_emailAvailability(authData['email']!.trim(), 'hastalar');
          if (emailKayitli) {
            setState(() {
              isLoading = false;
            });
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Bir hata oluştu'),
                content:
                    const Text('bu email bizim sistemizde başka bir hesaba aittir'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Tamam'),
                  ),
                ],
              ),
            );
          } else {
            await Provider.of<Auth>(context, listen: false).hasta_SignUp(
              authData['email']!.trim(),
              authData['password']!.trim(),
              hasta,
            );
          }
        } else {
          await Provider.of<Auth>(context, listen: false).Login(
              authData['email']!.trim(),
              authData['password']!.trim(),
              'hastalar');
        }
      } else {
        if (authMode == AuthMode.signUp) {
          bool emailKayitli = await Provider.of<Auth>(context, listen: false)
              .Check_emailAvailability(authData['email']!.trim(), 'doktorlar');
          if (emailKayitli) {
            setState(() {
              isLoading = false;
            });
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Bir hata oluştu'),
                content:
                    const Text('bu email bizim sistemizde başka bir hesaba aittir'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Tamam'),
                  ),
                ],
              ),
            );
          } else {
            await Provider.of<Auth>(context, listen: false).doktor_SignUp(
              authData['email']!.trim(),
              authData['password']!.trim(),
              doktor,
            );
          }
        } else {
          await Provider.of<Auth>(context, listen: false).Login(
              authData['email']!.trim(),
              authData['password']!.trim(),
              'doktorlar');
        }
      }
    } on HttpException catch (error) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bir hata oluştu'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bir hata oluştu'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.blue,
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'images/illu.png',
                              width: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                  onPressed: toggle_hasta_doktor,
                                  child: Text(
                                    'Hasta',
                                    style: TextStyle(
                                      color: authPerson == AuthPerson.hasta
                                          ? Colors.white
                                          : Colors.white60,
                                      fontSize: authPerson == AuthPerson.hasta
                                          ? 30
                                          : 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: toggle_hasta_doktor,
                                  child: Text(
                                    'Doktor',
                                    style: TextStyle(
                                      color: authPerson == AuthPerson.doktor
                                          ? Colors.white
                                          : Colors.white60,
                                      fontSize: authPerson == AuthPerson.doktor
                                          ? 30
                                          : 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Form(
                      key: form,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                bottom: 12, right: 40, left: 40),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'E-posta',
                                border: UnderlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'E-posta hesabınızı giriniz';
                                }
                                if (!value.contains('@')) {
                                  return 'Lütfen geçerli bir eposta hesabınızı giriniz';
                                }
                                return null;
                              },
                              onSaved: (enteredValue) {
                                authData['email'] = enteredValue!;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                bottom: 12, right: 40, left: 40),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Şifre',
                                border: UnderlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              controller: passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Lütfen Şifreyi giriniz';
                                }
                                if (value.length < 6) {
                                  return 'Lütfen 6 karakterden fazla oluşan bir şifre giriniz';
                                }
                                return null;
                              },
                              onSaved: (enteredValue) {
                                authData['password'] = enteredValue!;
                              },
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          if (authMode == AuthMode.signUp)
                            Container(
                              margin: const EdgeInsets.only(
                                  bottom: 12, right: 40, left: 40),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Şifreyi doğrulayın',
                                  border: UnderlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Lütfen Şifreyi doğrulayın';
                                  }
                                  if (value != passwordController.text) {
                                    return 'Girdiğiniz şifre eşleşmiyor';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: saveForm,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            authMode == AuthMode.login
                                ? 'Giriş Yapın'
                                : 'Yeni Hesap Oluşturunuz',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Veya',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextButton(
                      onPressed: toggleAuth,
                      child: Text(
                        authMode == AuthMode.login
                            ? 'Yeni Hesap Oluşturunuz'
                            : 'Giriş Yapın',
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
