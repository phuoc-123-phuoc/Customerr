import 'package:customer_app_multistore/providers/sql_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:customer_app_multistore/providers/product_class.dart';

class Cart extends ChangeNotifier {
  static List<Product> _list = [];
  List<Product> get getItems {
    return _list;
  }

  double get totalPrice {
    var total = 0.0;

    for (var item in _list) {
      total += item.price * item.qty;
    }
    return total;
  }

  int? get count {
    return _list.length;
  }

  void addItem(
      // String name,
      // double price,
      // int qty,
      // int qntty,
      // String imagesUrl,
      // String documentId,
      // String suppId,
      Product product) async {
    // final product = Product(
    //     name: name,
    //     price: price,
    //     qty: qty,
    //     qntty: qntty,
    //     imagesUrl: imagesUrl,
    //     documentId: documentId,
    //     suppId: suppId);
    await SQLHelper.insertCartItem(product)
        .whenComplete(() => _list.add(product));
    notifyListeners();
  }

  loadCartItemsProvider() async {
    List<Map> data = await SQLHelper.loadItems();
    _list = data.map((product) {
      return Product(
        documentId: product['documentId'],
        name: product['name'],
        price: product['price'],
        qty: product['qty'],
        qntty: product['qntty'],
        imagesUrl: product['imagesUrl'],
        suppId: product['suppId'],
      );
    }).toList();
    notifyListeners();
  }

  void increment(Product product) async {
    await SQLHelper.updateCartItem(product, 'increment')
        .whenComplete(() => product.increase());

    notifyListeners();
  }

  void reduceByOne(Product product) async {
    await SQLHelper.updateCartItem(product, 'reduce')
        .whenComplete(() => product.decrease());

    notifyListeners();
  }

  void removeItem(Product product) async {
    await SQLHelper.deleteCartItem(product.documentId)
        .whenComplete(() => _list.remove(product));

    notifyListeners();
  }

  void clearCart() async {
    await SQLHelper.removeAllItems().whenComplete(() => _list.clear());

    notifyListeners();
  }
}
