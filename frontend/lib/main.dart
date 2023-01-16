import 'package:doktora_sor/screens/hasta/profil_duzenleme_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth.dart';
import 'providers/doktor_user.dart';
import 'providers/hasta_user.dart';
import 'providers/yorum_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/doktor/doktor_home_screen.dart';
import 'screens/doktor/profil_duzenleme_screen.dart';
import 'screens/doktor/yorumlar_screen.dart';
import 'screens/chat_room_screen.dart';
import 'screens/hasta/doktor_tabs_screen.dart';
import 'screens/hasta/doktorlar_screen.dart';
import 'screens/hasta/tab_screens.dart';
import 'screens/hasta/uzmanlik_alanlari_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, HastaUser>(
          create: (ctx) => HastaUser(
            Auth().userEmail,
            Auth().kullaniciAdi,
            Auth().userGender,
          ),
          update: (ctx, auth, previousProd) => HastaUser(
            auth.userEmail,
            auth.kullaniciAdi,
            auth.userGender,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, DoktorUser>(
          create: (ctx) => DoktorUser(
            Auth().userEmail,
            Auth().kullaniciAdi,
            Auth().userGender,
          ),
          update: (ctx, auth, previousProd) => DoktorUser(
            auth.userEmail,
            auth.kullaniciAdi,
            auth.userGender,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => YorumProvider(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Doktora sor',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth
              ? auth.user == 'Hasta'
                  ? TabsScreen()
                  : const DoktorHomeScreen()
              : const AuthScreen(),
          routes: {
            UzmanlikAlanlari.uzmanlikAlanlariRoute: (ctx) => UzmanlikAlanlari(),
            HastaProfilDuzenleme.HastaProfilDuzenlemeRoute: (ctx) => const HastaProfilDuzenleme(),
            DoktorProfilDuzenleme.DoktorProfilDuzenlemeRoute: (ctx) => const DoktorProfilDuzenleme(),
            DoktorlarScreen.DoktorlarScreenRoute: (ctx) => const DoktorlarScreen(),
            DoktorTabsScreen.doktorTabsScreenRoute: (ctx) => const DoktorTabsScreen(),
            Yorumlar.yorumlarRoute: (ctx) => Yorumlar(),
            ChatRoom.chatRoomRoute: (ctx) => ChatRoom(),
          },
        ),
      ),
    );
  }
}
