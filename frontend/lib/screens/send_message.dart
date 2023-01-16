import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doktora_sor/models/http_exceptions.dart';
import 'package:doktora_sor/providers/doktor_user.dart';
import 'package:doktora_sor/providers/hasta_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import 'package:http/http.dart' as http;

class SendMessage extends StatefulWidget {
  final Map<String, String> chatRoomInfo;

  SendMessage(this.chatRoomInfo);

  @override
  _SendMessageState createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  var messageController = TextEditingController();
  bool sendVerifier = false;

  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    requestPermission();

    loadFCM();

    listenFCM();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(

          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              styleInformation: const BigTextStyleInformation(''),
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',

            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void sendPushMessage(String token, String title, String body) async {
    try {
      await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'authorization':
                'key=AAAAh6B1M8U:APA91bFJYHGHhIGjV-0EXJSaz26Af4GyWhQs6E2j7ETrHKjG_7aqmERTkw8pSBUQVVT2WRdPmlM_MJY_kXwe2T4ioEPhfgfPoprg7Ij8wk9QCGvpwM8UiYlwd7iq3vdOMdFyIC6DVz7F',
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              'android_channel_id': 'doktoraSor',
            },
            'to': token,
          }));
    } catch (error) {
      throw HttpException(error.toString());
    }
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      String currentUserEmail =
          Provider.of<Auth>(context, listen: false).userEmail;
      String currentUserName =
          Provider.of<Auth>(context, listen: false).user == 'Hasta'
              ? Provider.of<HastaUser>(context, listen: false).kullaniciAdi
              : Provider.of<DoktorUser>(context, listen: false).kullaniciAdi;
      String otherUserEmail =
          currentUserEmail == widget.chatRoomInfo['hastaEmail']
              ? widget.chatRoomInfo['doktorEmail'] as String
              : widget.chatRoomInfo['hastaEmail'] as String;
      String otherUserName =
          currentUserName == widget.chatRoomInfo['hastaUserName']
              ? widget.chatRoomInfo['doktorUserName'] as String
              : widget.chatRoomInfo['hastaUserName'] as String;
      try {
        FirebaseFirestore.instance
            .collection(
                '/Users/${widget.chatRoomInfo['hastaEmail']}/konustuklari/${widget.chatRoomInfo['doktorEmail']}/sohbet')
            .add({
          'message': messageController.text,
          'sentAt': Timestamp.now(),
          'sentByEmail': currentUserEmail,
          'sentToEmail': otherUserEmail,
          'sentByUser': currentUserName,
          'sentToUser': otherUserName,
        });
        FirebaseFirestore.instance
            .collection(
                '/Users/${widget.chatRoomInfo['hastaEmail']}/konustuklari')
            .doc(widget.chatRoomInfo['doktorEmail'])
            .set({
          'message': messageController.text,
          'sentAt': Timestamp.now(),
          'hastaEmail': widget.chatRoomInfo['hastaEmail'],
          'doktorEmail': widget.chatRoomInfo['doktorEmail'],
          'hastaCinsiyet': widget.chatRoomInfo['hastaCinsiyet'],
          'doktorCinsiyet': widget.chatRoomInfo['doktorCinsiyet'],
          'hastaUserName': widget.chatRoomInfo['hastaUserName'],
          'doktorUserName': widget.chatRoomInfo['doktorUserName'],
          'isNewMessage': currentUserEmail == widget.chatRoomInfo['hastaEmail']
              ? 'No'
              : 'Yes',
        });
        FirebaseFirestore.instance
            .collection(
                '/Users/${widget.chatRoomInfo['doktorEmail']}/konustuklari')
            .doc(widget.chatRoomInfo['hastaEmail'])
            .set({
          'message': messageController.text,
          'sentAt': Timestamp.now(),
          'hastaEmail': widget.chatRoomInfo['hastaEmail'],
          'doktorEmail': widget.chatRoomInfo['doktorEmail'],
          'hastaCinsiyet': widget.chatRoomInfo['hastaCinsiyet'],
          'doktorCinsiyet': widget.chatRoomInfo['doktorCinsiyet'],
          'hastaUserName': widget.chatRoomInfo['hastaUserName'],
          'doktorUserName': widget.chatRoomInfo['doktorUserName'],
          'isNewMessage': currentUserEmail == widget.chatRoomInfo['hastaEmail']
              ? 'Yes'
              : 'No',
        });
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection('/UsersTokens')
            .doc(otherUserEmail);
        documentReference.get().then((snapshot) {
          String token = snapshot.get('token') ?? '';
          print(token);
          if (token.isNotEmpty) {
            sendPushMessage(token, currentUserName, messageController.text);
          }
        });
      } catch (error) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      messageController.clear();
      setState(() {
        sendVerifier = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 80,
            padding:
                const EdgeInsets.only(right: 10, bottom: 2, left: 10, top: 10),
            child: TextFormField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Mesaj',
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
              onChanged: (val) {
                if (val.isNotEmpty) {
                  setState(() {
                    sendVerifier = true;
                  });
                } else {
                  setState(() {
                    sendVerifier = false;
                  });
                }
              },
              textInputAction: TextInputAction.done,
            ),
          ),
        ),
        IconButton(
          onPressed: sendVerifier ? sendMessage : null,
          icon: const Icon(
            Icons.send,
          ),
          color: sendVerifier ? Colors.blue : Colors.grey,
        ),
      ],
    );
  }
}
