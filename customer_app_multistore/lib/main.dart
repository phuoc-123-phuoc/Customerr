// ignore_for_file: avoid_print

import 'package:customer_app_multistore/minor_screens/sale.dart';
import 'package:customer_app_multistore/providers/id_provider.dart';
import 'package:customer_app_multistore/providers/sql_helper.dart';
import 'package:customer_app_multistore/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:customer_app_multistore/auth/customer_login.dart';
import 'package:customer_app_multistore/auth/customer_signup.dart';
import 'package:customer_app_multistore/main_screens/customer_home.dart';
import 'package:customer_app_multistore/main_screens/onboarding_screen.dart';
import 'package:customer_app_multistore/main_screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:customer_app_multistore/providers/cart_provider.dart';
import 'package:customer_app_multistore/providers/stripe_id.dart';
import 'package:customer_app_multistore/providers/wish_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Customer app ////Handling a background message: ${message.messageId}");
  print("Handling a background message: ${message.notification!.title}");
  print("Handling a background message: ${message.notification!.body}");
  print("Handling a background message: ${message.data}");
  print(
      "Customer app ////Handling a background message: ${message.data['key1']}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationsServices.createNotificationChannelAndInitialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Stripe.publishableKey = stripePublishableKey;
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  SQLHelper.getDatabase;

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Cart()),
    ChangeNotifierProvider(create: (_) => Wish()),
    ChangeNotifierProvider(create: (_) => IdProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding_screen',
      routes: {
        '/welcome_screen': (context) => const WelcomeScreen(),
        '/onboarding_screen': (context) => const Onboardingscreen(),
        '/customer_home': (context) => const CustomerHomeScreen(),
        '/customer_signup': (context) => const CustomerRegister(),
        '/customer_login': (context) => const CustomerLogin(),
        DiscountCodeScreen.id: (context) => DiscountCodeScreen(),
      },
    );
  }
}
