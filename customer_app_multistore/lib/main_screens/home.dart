import 'package:flutter/material.dart';
import 'package:customer_app_multistore/galleries/accessories_gallery.dart';
import 'package:customer_app_multistore/galleries/bags_gallery.dart';
import 'package:customer_app_multistore/galleries/beauty_gallery.dart';
import 'package:customer_app_multistore/galleries/electronics_gallery.dart';
import 'package:customer_app_multistore/galleries/homegarden_gallery.dart';
import 'package:customer_app_multistore/galleries/kids_gallery.dart';
import 'package:customer_app_multistore/galleries/men_gallery.dart';
import 'package:customer_app_multistore/galleries/shoes_gallery.dart';
import 'package:customer_app_multistore/galleries/women_gallery.dart';
import 'package:customer_app_multistore/widgets/fake_search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade100.withOpacity(0.5),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const FakeSearch(),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.yellow,
            indicatorWeight: 8,
            tabs: [
              RepeatedTab(label: 'Men'),
              RepeatedTab(label: 'Women'),
              RepeatedTab(label: 'Shoes'),
              RepeatedTab(label: 'Bags'),
              RepeatedTab(label: 'Electronics'),
              RepeatedTab(label: 'Accessories'),
              RepeatedTab(label: 'Home & Garden'),
              RepeatedTab(label: 'Kids'),
              RepeatedTab(label: 'Beauty'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MenGalleryScreen(),
            WomenGalleryScreen(),
            ShoesGalleryScreen(),
            BagsGalleryScreen(),
            ElectronicsGalleryScreen(),
            AccessoriesGalleryScreen(),
            HomeGardenGalleryScreen(),
            KidsGalleryScreen(),
            BeautyGalleryScreen()
          ],
        ),
      ),
    );
  }
}

class RepeatedTab extends StatelessWidget {
  final String label;
  const RepeatedTab({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}
