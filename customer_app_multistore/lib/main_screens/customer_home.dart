// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:badges/badges.dart' as bgades;
import 'package:customer_app_multistore/minor_screens/visit_store.dart';
import 'package:customer_app_multistore/services/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:customer_app_multistore/main_screens/cart.dart';
import 'package:customer_app_multistore/main_screens/category.dart';
import 'package:customer_app_multistore/main_screens/home.dart';
import 'package:customer_app_multistore/main_screens/profile.dart';
import 'package:customer_app_multistore/main_screens/stores.dart';
import 'package:customer_app_multistore/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => CustomerHomeScreenState();
}

class CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> tabs = [
    const HomeScreen(),
    const CategoryScreen(),
    const StoresScreen(),
    const CartScreen(),
    const ProfileScreen(
        /* documentId: FirebaseAuth.instance.currentUser!.uid, */
        ),
  ];
  displayForegroundNotifications() {
    //FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Customer app ////Got a message whilst in the foreground');
      print('Customer app ////Message data: ${message.data}');
      if (message.notification != null) {
        print(
            'Customer app ////Message also contained a notification: ${message.notification}');
        NotificationsServices.displayNotification(message);
      }
    });
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'store') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const VisitStore(suppId: "FEam7kqqraXS3nA88LXYiAyw0c03")));
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getToken()
        .then((value) => print('token: $value'));
    context.read<Cart>().loadCartItemsProvider();
    displayForegroundNotifications();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        selectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Category',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: bgades.Badge(
                showBadge: context.read<Cart>().getItems.isEmpty ? false : true,
                badgeStyle: const bgades.BadgeStyle(
                  padding: EdgeInsets.all(2),
                  badgeColor: Colors.yellow,
                ),
                badgeContent: Text(
                  context.watch<Cart>().getItems.length.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Icon(Icons.shopping_cart)),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
