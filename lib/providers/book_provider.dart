import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/book.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.22:8000/api/koleksi'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _books = jsonData.map((book) => Book.fromJson(book)).toList();
        _errorMessage = null;
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
}
