import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:perpus_flutter/config/config.dart';
import '../models/book.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  var logger = Logger();

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(Config.baseUrl('koleksi')),
        headers: {'Accept': 'application/json'},
      );
      final data = jsonDecode(response.body);
      logger.i("📥 Response Koleksi buku: $data");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _books = jsonData.map((book) => Book.fromJson(book)).toList();
        _errorMessage = null;

        // Simpan ke cache
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('cached_books', json.encode(jsonData));
      } else {
        _errorMessage = 'Gagal memuat buku: ${response.statusCode}';
        _books = [];
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _books = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBooksFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_books');
    if (cached != null) {
      final List<dynamic> jsonData = json.decode(cached);
      _books = jsonData.map((book) => Book.fromJson(book)).toList();
      notifyListeners();
    }
  }
}
