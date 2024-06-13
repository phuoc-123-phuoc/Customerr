// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

//import 'dart:convert';

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/minor_screens/sale.dart';
import 'package:customer_app_multistore/providers/id_provider.dart';
import 'package:customer_app_multistore/providers/stripe_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:customer_app_multistore/providers/cart_provider.dart';
import 'package:customer_app_multistore/widgets/appbar_widgets.dart';
import 'package:customer_app_multistore/widgets/yellow_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:http/http.dart' as http;

//import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String address;
  const PaymentScreen(
      {Key? key,
      required this.name,
      required this.phone,
      required this.address})
      : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedValue = 1;
  late String orderId;
  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');
  Map<String, dynamic>? selectedDiscount;
  double discountPercentage = 0.0;

  void showProgress() {
    ProgressDialog progress = ProgressDialog(context: context);
    progress.show(max: 100, msg: 'please wait ..', progressBgColor: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    String docId = context.read<IdProvider>().getData;
    double totalPrice = context.watch<Cart>().totalPrice;
    double shippingCost = 10.0;
    double discountAmount = (totalPrice * discountPercentage) / 100;
    double totalPaid = totalPrice - discountAmount + shippingCost;

    return FutureBuilder<DocumentSnapshot>(
        future: customers.doc(docId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Text("Document does not exist");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Material(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Material(
              color: Colors.grey.shade200,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.grey.shade200,
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.grey.shade200,
                    leading: const AppBarBackButton(),
                    title: const AppBarTitle(
                      title: 'Payment',
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                    child: Column(
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      '${totalPaid.toStringAsFixed(2)} USD',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 2,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total order',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      '${totalPrice.toStringAsFixed(2)} USD',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Discount',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      '${discountAmount.toStringAsFixed(2)} USD',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Shipping Cost',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      '10.00 USD',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                RadioListTile(
                                  value: 1,
                                  groupValue: selectedValue,
                                  onChanged: (int? value) {
                                    setState(() {
                                      selectedValue = value!;
                                    });
                                  },
                                  title: const Text('Cash On Delivery'),
                                  subtitle: const Text('Pay Cash At Home'),
                                ),
                                RadioListTile(
                                  value: 2,
                                  groupValue: selectedValue,
                                  onChanged: (int? value) {
                                    setState(() {
                                      selectedValue = value!;
                                    });
                                  },
                                  title:
                                      const Text('Pay via Visa / Master Card'),
                                  subtitle: const Row(
                                    children: [
                                      Icon(Icons.payment, color: Colors.blue),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Icon(
                                            FontAwesomeIcons.ccMastercard,
                                            color: Colors.blue),
                                      ),
                                      Icon(FontAwesomeIcons.ccVisa,
                                          color: Colors.blue),
                                    ],
                                  ),
                                ),
                                RadioListTile(
                                  value: 3,
                                  groupValue: selectedValue,
                                  onChanged: (int? value) {
                                    setState(() {
                                      selectedValue = value!;
                                    });
                                  },
                                  title: const Text('Pay via Paypal'),
                                  subtitle: const Row(
                                    children: [
                                      Icon(FontAwesomeIcons.paypal,
                                          color: Colors.blue),
                                      SizedBox(width: 15),
                                      Icon(FontAwesomeIcons.ccPaypal,
                                          color: Colors.blue),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        YellowButton(
                          label: 'Choose Discount',
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                                context, DiscountCodeScreen.id);
                            if (result != null &&
                                result is Map<String, dynamic>) {
                              setState(() {
                                selectedDiscount = result;
                                discountPercentage =
                                    (selectedDiscount!['percentage'] as num)
                                        .toDouble();
                              });
                            }
                          },
                          width: 0.4,
                        )
                      ],
                    ),
                  ),
                  bottomSheet: Container(
                    color: Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: YellowButton(
                        label: 'Confirm ${totalPaid.toStringAsFixed(2)} USD',
                        width: 1,
                        onPressed: () async {
                          if (selectedValue == 1) {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) => SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 100),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                'Pay At Home ${totalPaid.toStringAsFixed(2)} \$',
                                                style: const TextStyle(
                                                    fontSize: 24),
                                              ),
                                              YellowButton(
                                                  label:
                                                      'Confirm ${totalPaid.toStringAsFixed(2)} \$',
                                                  onPressed: () async {
                                                    showProgress();
                                                    for (var item in context
                                                        .read<Cart>()
                                                        .getItems) {
                                                      CollectionReference
                                                          orderRef =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'orders');
                                                      orderId =
                                                          const Uuid().v4();
                                                      await orderRef
                                                          .doc(orderId)
                                                          .set({
                                                        'cid': data['cid'],
                                                        'custname': widget.name,
                                                        'email': data['email'],
                                                        'address':
                                                            widget.address,
                                                        'phone': widget.phone,
                                                        'profileimage': data[
                                                            'profileimage'],
                                                        'sid': item.suppId,
                                                        'proid':
                                                            item.documentId,
                                                        'orderid': orderId,
                                                        'ordername': item.name,
                                                        'orderimage':
                                                            item.imagesUrl,
                                                        'orderqty': item.qty,
                                                        'orderprice': totalPaid,
                                                        'deliverystatus':
                                                            'preparing',
                                                        'deliverydate': '',
                                                        'orderdate':
                                                            DateTime.now(),
                                                        'paymentstatus':
                                                            'cash on delivery',
                                                        'orderreview': false,
                                                      }).whenComplete(() async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .runTransaction(
                                                                (transaction) async {
                                                          DocumentReference
                                                              documentReference =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'products')
                                                                  .doc(item
                                                                      .documentId);
                                                          DocumentSnapshot
                                                              snapshot2 =
                                                              await transaction.get(
                                                                  documentReference);
                                                          transaction.update(
                                                              documentReference,
                                                              {
                                                                'instock': snapshot2[
                                                                        'instock'] -
                                                                    item.qty,
                                                              });
                                                        });
                                                      });
                                                    }
                                                    await Future.delayed(
                                                            const Duration(
                                                                microseconds:
                                                                    100))
                                                        .whenComplete(() {
                                                      context
                                                          .read<Cart>()
                                                          .clearCart();
                                                      Navigator.popUntil(
                                                          context,
                                                          ModalRoute.withName(
                                                              '/customer_home'));
                                                    });
                                                  },
                                                  width: 0.9)
                                            ]),
                                      ),
                                    ));
                          } else if (selectedValue == 2) {
                            print('visa');

                            int payment = totalPaid.round();
                            int pay = payment * 100;

                            await makePayment(context, data, pay.toString());
                          } else if (selectedValue == 3) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PaypalPaymentDemo()));
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment(
      BuildContext context, dynamic data, String total) async {
    try {
      int amount =
          (double.parse(total)).toInt(); // Convert to smallest currency unit
      paymentIntentData = await createPaymentIntent(amount.toString(), 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          merchantDisplayName: 'ANNIE',
          // applePay: const PaymentSheetApplePay(
          //   merchantCountryCode: 'US', // Specify the correct country code
          // ),
          // googlePay: const PaymentSheetGooglePay(
          //   merchantCountryCode: 'US', // Specify the correct country code
          //   testEnv: true, // Set to true if testing in sandbox
          // ),
        ),
      );

      await displayPaymentSheet(context, data);
    } catch (e) {
      print('Exception during makePayment: $e');
    }
  }

  Future<void> displayPaymentSheet(BuildContext context, dynamic data) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      paymentIntentData = null;
      print('Paid');

      showProgress();
      for (var item in context.read<Cart>().getItems) {
        CollectionReference orderRef =
            FirebaseFirestore.instance.collection('orders');
        String orderId = const Uuid().v4();
        await orderRef.doc(orderId).set({
          'cid': data['cid'],
          'custname': data['name'],
          'email': data['email'],
          'address': data['address'],
          'phone': data['phone'],
          'profileimage': data['profileimage'],
          'sid': item.suppId,
          'proid': item.documentId,
          'orderid': orderId,
          'ordername': item.name,
          'orderimage': item.imagesUrl,
          'orderqty': item.qty,
          'orderprice': item.qty * item.price,
          'deliverystatus': 'preparing',
          'deliverydate': '',
          'orderdate': DateTime.now(),
          'paymentstatus': 'paid online',
          'orderreview': false,
        }).whenComplete(() async {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentReference documentReference = FirebaseFirestore.instance
                .collection('products')
                .doc(item.documentId);
            DocumentSnapshot snapshot2 =
                await transaction.get(documentReference);
            transaction.update(documentReference, {
              'instock': snapshot2['instock'] - item.qty,
            });
          });
        });
      }
      await Future.delayed(const Duration(milliseconds: 100)).whenComplete(() {
        context.read<Cart>().clearCart();
        Navigator.popUntil(context, ModalRoute.withName('/customer_home'));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String total, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': total,
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Exception during createPaymentIntent: $e');
      return {};
    }
  }
}

class PaypalPaymentDemo extends StatelessWidget {
  const PaypalPaymentDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Schedule navigation to PaypalCheckoutView after the current frame has finished building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId:
              "AS8m-iX-5p60bvFWDael22vG-eDN1E36444XKoQGN7DqkQb4UliycxeciIRvD2DFTL6l5PJUyZdejCi9",
          secretKey:
              "EKk67ORYrgqXZzC8Ed2WRFxyu3X4TusrTDOYSlINwWKZijjcJPaZq_7omGdxP7lNpyb_UYElC3wirylz",
          transactions: const [
            {
              "amount": {
                "total": '100',
                "currency": "USD",
                "details": {
                  "subtotal": '100',
                  "shipping": '0',
                  "shipping_discount": 0
                }
              },
              "description": "The payment transaction description.",
              "item_list": {
                "items": [
                  {
                    "name": "Apple",
                    "quantity": 4,
                    "price": '10',
                    "currency": "USD"
                  },
                  {
                    "name": "Pineapple",
                    "quantity": 5,
                    "price": '12',
                    "currency": "USD"
                  }
                ],
              }
            }
          ],
          note: "Contact us for any questions on your order.",
          onSuccess: (Map params) async {
            log("onSuccess: $params");
            Navigator.popUntil(context, ModalRoute.withName('/customer_home'));
          },
          onError: (error) {
            log("onError: $error");
            Navigator.popUntil(context, ModalRoute.withName('/customer_home'));
          },
          onCancel: () {
            print('cancelled:');
            Navigator.popUntil(context, ModalRoute.withName('/customer_home'));
          },
        ),
      ));
    });

    // Return MaterialApp để hiển thị
    return MaterialApp(
      title: 'PaypalPaymentDemp',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
            // Không cần nút "Pay with Paypal" nữa
            ),
      ),
    );
  }
}
