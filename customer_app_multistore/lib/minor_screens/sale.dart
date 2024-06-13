import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DiscountCodeScreen extends StatelessWidget {
  static const String id = "discountCodeScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discount Codes'),
        backgroundColor: Colors.pinkAccent.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sale').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No discount codes available.'),
            );
          }
          List<DocumentSnapshot> documents = snapshot.data!.docs;
          List<Map<String, dynamic>> discountCodes = documents.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
          return ListView.builder(
            itemCount: discountCodes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Pass the selected discount code data back to the previous screen
                  Navigator.pop(context, discountCodes[index]);
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      discountCodes[index]['codeName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent.shade700,
                      ),
                    ),
                    subtitle: Text(
                      '${discountCodes[index]['percentage']}% off\nExpires: ${DateFormat.yMMMd().format(discountCodes[index]['expiryDate'].toDate())}',
                    ),
                    trailing: Icon(
                      Icons.local_offer,
                      color: Colors.pinkAccent.shade700,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
