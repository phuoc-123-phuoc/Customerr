// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/widgets/snackbar.dart';
import 'package:customer_app_multistore/widgets/yellow_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
// import 'package:customer_app_multistore/core.dart';
import 'package:customer_app_multistore/minor_screens/full_screen_view.dart';
import 'package:customer_app_multistore/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Choose extends StatefulWidget {
  final dynamic proList;
  const Choose({Key? key, required this.proList}) : super(key: key);

  @override
  State<Choose> createState() => _ChooseState();
}

class _ChooseState extends State<Choose> {
  late final Stream<QuerySnapshot> _productsStream;

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  String selectedSize = '';
  String selectedColor = '';

  @override
  void initState() {
    super.initState();
    _productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('maincateg', isEqualTo: widget.proList['maincateg'])
        .where('subcateg', isEqualTo: widget.proList['subcateg'])
        .snapshots();
  }

  Future<void> _saveSelectionSizes() async {
    if (selectedSize.isNotEmpty && selectedColor.isNotEmpty) {
      try {
        for (var item in context.read<Cart>().getItems) {
          CollectionReference orderRef =
              FirebaseFirestore.instance.collection('CustomerSelectedSized');
          String orderId = const Uuid().v4();
          await orderRef.doc(orderId).set({
            'sid': item.suppId,
            'orderid': orderId,
            'selectedSize': selectedSize,
          }).whenComplete(() async {
            await FirebaseFirestore.instance
                .runTransaction((transaction) async {});
          });
        }
        for (var item in context.read<Cart>().getItems) {
          CollectionReference orderRef =
              FirebaseFirestore.instance.collection('CustomerSelectedColors');
          String orderId = const Uuid().v4();
          await orderRef.doc(orderId).set({
            'sid': item.suppId,
            'orderid': orderId,
            'selectedColors': selectedColor
          }).whenComplete(() async {
            await FirebaseFirestore.instance
                .runTransaction((transaction) async {});
          });
        }
        print('Selection saved successfully');

        Navigator.pop(context);
      } catch (e) {
        print('Error saving selection: $e');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Error saving selection. Please try again.'),
        //     duration: Duration(seconds: 2),
        //   ),
        // );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select size and color'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: ScaffoldMessenger(
          key: _scaffoldKey,
          child: Scaffold(
            body: StreamBuilder<QuerySnapshot>(
              stream: _productsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> products = snapshot.data!.docs;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenView(
                                imagesList: widget.proList['proimages'],
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Swiper(
                                pagination: const SwiperPagination(
                                  builder: SwiperPagination.fraction,
                                ),
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    widget.proList['proimages'][index],
                                    fit: BoxFit.cover,
                                  );
                                },
                                itemCount: widget.proList['proimages'].length,
                              ),
                            ),
                            Positioned(
                              left: 15,
                              top: 20,
                              child: CircleAvatar(
                                backgroundColor: Colors.yellow,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sizes:',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Wrap(
                              spacing: 8.0,
                              children: List.generate(
                                widget.proList['sizes'].length,
                                (index) {
                                  String size = widget.proList['sizes'][index];
                                  return ChoiceChip(
                                    label: Text(size),
                                    selected: selectedSize == size,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        selectedSize = selected ? size : '';
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Colors:',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Wrap(
                              spacing: 8.0,
                              children: List.generate(
                                widget.proList['colors'].length,
                                (index) {
                                  String color =
                                      widget.proList['colors'][index];
                                  return ChoiceChip(
                                    label: Text(color),
                                    selected: selectedColor == color,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        selectedColor = selected ? color : '';
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      YellowButton(
                        onPressed: () {
                          // Check if both size and color are selected
                          if (selectedSize.isNotEmpty &&
                              selectedColor.isNotEmpty) {
                            // If both are selected, proceed
                            _saveSelectionSizes();
                            Navigator.pop(
                                context); // Call your function to save selections
                          } else {
                            // If either size or color (or both) is not selected, show a message
                            MyMessageHandler.showSnackBar(_scaffoldKey,
                                'Please select at least one size and one color.');
                          }
                        },
                        label: 'Ok',
                        width: 0.8,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
