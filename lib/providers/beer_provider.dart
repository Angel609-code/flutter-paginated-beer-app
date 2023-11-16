import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Beer {
  final int id;
  final String name;
  final String imageUrl;

  Beer({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Beer.fromJson(Map<String, dynamic> json) {
    return Beer(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}

class BeerProvider with ChangeNotifier {
  final List<Beer> _beers = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isDataLoaded = false;

  List<Beer> get beers => _beers;
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  bool get isDataLoaded => _isDataLoaded;

  final _totalPages = 4;

  Future<void> fetchData() async {
    if (_isLoading || _currentPage > _totalPages) return;

    _isLoading = true;

    try {
      final response = await http.get(Uri.parse('https://api.punkapi.com/v2/beers?page=$_currentPage&per_page=20'));

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> beerData = List<Map<String, dynamic>>.from(json.decode(response.body));
        _beers.addAll(beerData.map((beer) => Beer.fromJson(beer)));
        _currentPage++;

        _isDataLoaded = true;
        
      } else {
        throw Exception('Failed to load data');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    // Reset the state
    _beers.clear();
    _currentPage = 1;
    _isDataLoaded = false;
    notifyListeners();

    // Fetch data for the first page again
    await fetchData();
  }
}
