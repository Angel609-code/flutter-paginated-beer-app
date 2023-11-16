import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/beer_provider.dart';

class BeerList extends StatefulWidget {
  const BeerList({Key? key}) : super(key: key);

  @override
  BeerListState createState() => BeerListState();
}

class BeerListState extends State<BeerList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final beerProvider = Provider.of<BeerProvider>(context, listen: false);
    if (_scrollController.position.pixels >= (_scrollController.position.extentAfter * 0.5)) {
      //Load next page when the last card is almost visible
      beerProvider.fetchData();
    }
  }

  Future<void> _onRefresh() async {
    final beerProvider = Provider.of<BeerProvider>(context, listen: false);
    beerProvider.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beer List'),
      ),
      body: Consumer<BeerProvider>(
        builder: (context, beerProvider, child) {
          if (!beerProvider.isDataLoaded) {
            beerProvider.fetchData();
          }

          if (beerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (beerProvider.beers.isEmpty) {
            return const Center(child: Text('No beers available.'));
          } else {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: beerProvider.beers.length,
                itemBuilder: (context, index) {
                  final beer = beerProvider.beers[index];
                  return GestureDetector(
                    onTap: () {
                      log('Beer ID: ${beer.id}');
                    },
                    child: Card(
                      child: ListTile(
                        leading: Image.network(beer.imageUrl),
                        title: Text(beer.name),
                        subtitle: Text('ID: ${beer.id}'),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
