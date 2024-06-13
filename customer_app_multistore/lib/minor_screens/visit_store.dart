import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/providers/id_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:customer_app_multistore/minor_screens/edit_store.dart';
import 'package:customer_app_multistore/models/product_model.dart';
import 'package:customer_app_multistore/widgets/appbar_widgets.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VisitStore extends StatefulWidget {
  final String suppId;
  const VisitStore({Key? key, required this.suppId}) : super(key: key);

  @override
  State<VisitStore> createState() => _VisitStoreState();
}

class _VisitStoreState extends State<VisitStore> {
  bool following = false;
  String customerId = '';
  List<String> subcriptionList = [];
  checkUserSubcription() {
    FirebaseFirestore.instance
        .collection('suppliers')
        .doc(widget.suppId)
        .collection('subscriptions')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        subcriptionList.add(doc['customerid']);
      }
    }).whenComplete(() {
      following = subcriptionList.contains(context.read<IdProvider>().getData);
    });
  }

  subscribeToTopic() {
    FirebaseMessaging.instance.subscribeToTopic('salah');
    String id = context.read<IdProvider>().getData;
    FirebaseFirestore.instance
        .collection('suppliers')
        .doc(widget.suppId)
        .collection('subscriptions')
        .doc(id)
        .set({'customerid': id});
    setState(() {
      following = true;
    });
  }

  unsubscripFromTopic() {
    FirebaseMessaging.instance.unsubscribeFromTopic('salah');
    String id = context.read<IdProvider>().getData;
    FirebaseFirestore.instance
        .collection('suppliers')
        .doc(widget.suppId)
        .collection('subscriptions')
        .doc(id)
        .delete();
    setState(() {
      following = false;
    });
  }

  @override
  void initState() {
    customerId = context.read<IdProvider>().getData;
    customerId == '' ? null : checkUserSubcription();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> prodcutsStream = FirebaseFirestore.instance
        .collection('products')
        .where('sid', isEqualTo: widget.suppId)
        .snapshots();
    CollectionReference suppliers =
        FirebaseFirestore.instance.collection('suppliers');

    return FutureBuilder<DocumentSnapshot>(
      future: suppliers.doc(widget.suppId).get(),
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
          ));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            backgroundColor: Colors.blueGrey.shade100,
            appBar: AppBar(
              toolbarHeight: 100,
              flexibleSpace: data['coverimage'] == ''
                  ? Image.asset(
                      'images/inapp/coverimage.jpg',
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      data['coverimage'],
                      fit: BoxFit.cover,
                    ),
              leading: const YellowBackButton(),
              title: Row(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(width: 4, color: Colors.yellow),
                        borderRadius: BorderRadius.circular(15)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        data['storelogo'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data['storename'].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.yellow),
                              ),
                            ),
                          ],
                        ),
                        customerId == ''
                            ? const SizedBox()
                            : Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    border: Border.all(
                                        width: 3, color: Colors.black),
                                    borderRadius: BorderRadius.circular(25)),
                                child: MaterialButton(
                                  onPressed: following == false
                                      ? () {
                                          subscribeToTopic();
                                        }
                                      : () {
                                          unsubscripFromTopic();
                                        },
                                  child: following == true
                                      ? const Text('following')
                                      : const Text('FOLLOW'),
                                ))
                      ],
                    ),
                  )
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: prodcutsStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text(
                      'This Store \n\n has no items yet !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 26,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Acme',
                          letterSpacing: 1.5),
                    ));
                  }

                  return SingleChildScrollView(
                    child: StaggeredGridView.countBuilder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        crossAxisCount: 2,
                        itemBuilder: (context, index) {
                          return ProductModel(
                            products: snapshot.data!.docs[index],
                          );
                        },
                        staggeredTileBuilder: (context) =>
                            const StaggeredTile.fit(1)),
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.green,
              child: const Icon(
                FontAwesomeIcons.whatsapp,
                color: Colors.black,
                size: 40,
              ),
              onPressed: () {},
            ),
          );
        }

        return const Text("loading");
      },
    );
  }
}
