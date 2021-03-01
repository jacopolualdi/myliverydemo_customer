import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/screens/common_all_products_screen.dart';
import 'package:grocery_store/screens/common_banner_products_screen.dart';
import 'package:grocery_store/screens/common_notif_products_screen.dart';
import 'package:grocery_store/screens/home_screen.dart';
import 'package:grocery_store/screens/my_orders_screen.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

dynamic notificationData;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
CartBloc cartBloc;

class FirebaseService {
  static init(context, uid, User currentUser) {
    cartBloc = BlocProvider.of<CartBloc>(context);
    initDynamicLinks(context);
    updateFirebaseToken(currentUser);
    initFCM(uid, context, currentUser);
    configureFirebaseListeners(context, currentUser);
  }
}

initDynamicLinks(context) async {
  PendingDynamicLinkData data =
      await FirebaseDynamicLinks.instance.getInitialLink();
  Uri deepLink = data?.link;

  if (deepLink != null) {
    print('LAUNCH');
    print('DEEP LINK URL ::: $deepLink ');
    print(deepLink.toString());
    // print(deepLink.queryParameters['link']);

    // print(
    //     deepLink.queryParameters['link'].split('${Config().urlPrefix}/')[1]);

    // var tempLink = deepLink.queryParameters['${Config().urlPrefix}/'];
    String pid = deepLink.toString().split('${Config().urlPrefix}/')[1];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(
          productId: pid,
        ),
      ),
    );
  }

  FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
    Uri deepLink = dynamicLink?.link;

    if (deepLink != null) {
      print('ON_LINK');
      print('DEEP LINK URL ::: $deepLink ');
      // print(deepLink.queryParametersAll);
      // print(deepLink.queryParameters['link']);

      // print(deepLink.queryParameters['link']
      //     .split('${Config().urlPrefix}/')[1]);

      // var tempLink = deepLink.queryParameters['${Config().urlPrefix}/'];
      String pid = deepLink.toString().split('${Config().urlPrefix}/')[1];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductScreen(
            productId: pid,
          ),
        ),
      );
    }
  }, onError: (OnLinkErrorException e) async {
    print('onLinkError');
    print(e.message);
  });
}

//FCM
updateFirebaseToken(User currentUser) {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  firebaseMessaging.subscribeToTopic('ADMIN_PUSH_NOTIFICATIONS');

  firebaseMessaging.getToken().then((token) {
    print(token);
    FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).update({
      'tokenId': token,
    });
  });
}

initFCM(String uid, context, User currentUser) async {
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  var android = new AndroidInitializationSettings('grocery');
  var ios = new IOSInitializationSettings();
  var initSetting = new InitializationSettings(iOS: ios, android: android);
  flutterLocalNotificationsPlugin.initialize(
    initSetting,
    onSelectNotification: (data) async {
      if (notificationData['data']['type'] == 'ADMIN_PUSH_NOTIFICATIONS') {
        switch (notificationData['data']['notificationType']) {
          case 'TRENDING_NOTIF':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommonNotifProductsScreen(
                  productType: 'Trending',
                  cartBloc: cartBloc,
                  currentUser: FirebaseAuth.instance.currentUser,
                ),
              ),
            );
            break;
          case 'FEATURED_NOTIF':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommonNotifProductsScreen(
                  productType: 'Featured',
                  cartBloc: cartBloc,
                  currentUser: FirebaseAuth.instance.currentUser,
                ),
              ),
            );
            break;
          case 'GENERAL_NOTIF':
            break;
          case 'CATEGORY_NOTIF':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommonBannerProductsScreen(
                  category: notificationData['data']['category'],
                  cartBloc: cartBloc,
                  currentUser: FirebaseAuth.instance.currentUser,
                ),
              ),
            );
            break;
          default:
        }
      } else {
        print('Send to my orders ::: $notificationData');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyOrdersScreen(
              currentUser: currentUser,
            ),
          ),
        );
      }
    },
  );
}

configureFirebaseListeners(context, User currentUser) {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  firebaseMessaging.configure(
    onBackgroundMessage: firebaseBackgroundMessageHandler,
    onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message');
      notificationData = message;
      showNotification(
        notificationData,
        notificationData['data']['type'],
        context,
      );
    },
    onLaunch: (Map<String, dynamic> message) async {
      notificationData = message;
      print('onLaunch: $notificationData');
      //send user to my orders

      if (notificationData['data']['type'] == 'ADMIN_PUSH_NOTIFICATIONS') {
        switch (notificationData['data']['notificationType']) {
          case 'TRENDING_NOTIF':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommonNotifProductsScreen(
                  productType: 'Trending',
                  cartBloc: cartBloc,
                  currentUser: FirebaseAuth.instance.currentUser,
                ),
              ),
            );
            break;
          case 'FEATURED_NOTIF':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommonNotifProductsScreen(
                  productType: 'Featured',
                  cartBloc: cartBloc,
                  currentUser: FirebaseAuth.instance.currentUser,
                ),
              ),
            );
            break;
          case 'GENERAL_NOTIF':
            break;
          case 'CATEGORY_NOTIF':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommonBannerProductsScreen(
                  category: notificationData['data']['category'],
                  cartBloc: cartBloc,
                  currentUser: FirebaseAuth.instance.currentUser,
                ),
              ),
            );
            break;
          default:
        }
      } else {
        print('Send to my orders ::: $notificationData');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyOrdersScreen(
              currentUser: currentUser,
            ),
          ),
        );
      }
    },
    onResume: (Map<String, dynamic> message) async {
      notificationData = message;
      print('onResume: $notificationData');

      if (notificationData['data']['type'] == 'ADMIN_PUSH_NOTIFICATIONS') {
        switch (notificationData['data']['notificationType']) {
          case 'TRENDING_NOTIF':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommonNotifProductsScreen(
                  productType: 'Trending',
                  cartBloc: cartBloc,
                  currentUser: FirebaseAuth.instance.currentUser,
                ),
              ),
            );
            break;
          case 'FEATURED_NOTIF':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommonNotifProductsScreen(
                  productType: 'Featured',
                  cartBloc: cartBloc,
                  currentUser: FirebaseAuth.instance.currentUser,
                ),
              ),
            );
            break;
          case 'GENERAL_NOTIF':
            break;
          case 'CATEGORY_NOTIF':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommonBannerProductsScreen(
                  category: notificationData['data']['category'],
                  cartBloc: cartBloc,
                  currentUser: FirebaseAuth.instance.currentUser,
                ),
              ),
            );
            break;
          default:
        }
      } else {
        print('Send to my orders ::: $notificationData');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyOrdersScreen(
              currentUser: currentUser,
            ),
          ),
        );
      }
    },
  );
}

showNotification(
  dynamic data,
  String notificationType,
  context,
) async {
  if (data['notification']['image'] != null) {
    print('WITH IMAGE');
    print(data['notification']['image']);
    final String largeIconPath = await _downloadAndSaveFile(
        '${data['notification']['image']}', 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(
        '${data['notification']['image']}', data['notification']['image']);
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
            // largeIcon: FilePathAndroidBitmap(largeIconPath),
            contentTitle: 'overridden <b>big</b> content title',
            htmlFormatContentTitle: true,
            summaryText: 'summary <i>text</i>',
            htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channelId',
      'channel_name',
      'desc',
      importance: Importance.high,
      playSound: true,
      styleInformation: bigPictureStyleInformation,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(100),
      data['notification']['title'],
      data['notification']['body'],
      platformChannelSpecifics,
    );
  } else {
    print('WITHOUT IMAGE');
    print(data['notification']['image']);
    var aNdroid = new AndroidNotificationDetails(
      'channelId',
      'channel_name',
      'desc',
      importance: Importance.high,
      playSound: true,
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: aNdroid, iOS: iOS);

    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(100),
      data['notification']['title'],
      data['notification']['body'],
      platform,
    );
  }
}

Future<dynamic> firebaseBackgroundMessageHandler(
    Map<String, dynamic> message) async {
  notificationData = message;
  print(notificationData);

  return Future<void>.value();
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(url);
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}
