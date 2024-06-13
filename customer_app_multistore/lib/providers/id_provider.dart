// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdProvider with ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static String _customerId = '';
  String get getData {
    return _customerId;
  }

  setCustomerId(User user) async {
    final SharedPreferences pref = await _prefs;
    pref
        .setString('customerid', user.uid)
        .whenComplete(() => _customerId = user.uid);
    print('customerid was saved into shared preferences');
    notifyListeners();
  }

  clearCustomerId() async {
    final SharedPreferences pref = await _prefs;
    pref.setString('customerid', '').whenComplete(() => _customerId = '');
    print('customerid was removed from shared preferences');
    notifyListeners();
  }

  Future<String> getDocumnetId() {
    return _prefs.then((SharedPreferences prefs) {
      return prefs.getString('customerid') ?? '';
    });
  }

  getDocId() async {
    await getDocumnetId().then((value) => _customerId = value);
    print('customerid was updated into provider');
    notifyListeners();
  }
}
