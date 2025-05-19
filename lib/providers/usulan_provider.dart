import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usulan.dart';
import 'package:logger/logger.dart';

class UsulanProvider with ChangeNotifier {
  var logger = Logger();
  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  List<UsulanModel> _riwayatUsulan = [];
  List<UsulanModel> get riwayatUsulan => _riwayatUsulan;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get success => _success;

  Future<void> kirimUsulan({
    required String bookTitle,
    required String genre,
    required String isbn,
    required String author,
    required String publisher,
    required String publicationYear,
    required String date,
    File? bookImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _success = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _errorMessage = 'Token tidak ditemukan, silakan login ulang.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final uri = Uri.parse('http://192.168.1.22:8000/api/pengusulan');
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['bookTitle'] = bookTitle
          ..fields['genre'] = genre
          ..fields['isbn'] = isbn
          ..fields['author'] = author
          ..fields['publicationYear'] = publicationYear
          ..fields['publisher'] = publisher
          ..fields['date'] = date
          ..fields['description'] = 'Deskripsi default'
          ..fields['synopsis'] = 'Sinopsis default';

    if (bookImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('bookImage', bookImage.path),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _success = true;
      } else {
        _errorMessage =
            'Gagal mengirim usulan (${response.statusCode}): $responseBody';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRiwayatUsulan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _errorMessage = 'Token tidak ditemukan.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('http://192.168.1.22:8000/api/riwayat-usulan');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      logger.i("Response Riwayat Usulan: $data");

      if (response.statusCode == 200) {
        final List<dynamic> usulanList = data['data'];

        for (var item in usulanList) {
          logger.i('Item to parse: $item');
        }

        _riwayatUsulan =
            usulanList
                .map((item) {
                  try {
                    return UsulanModel.fromJson(item);
                  } catch (e, stackTrace) {
                    logger.e('❌ Error parsing item: $e');
                    logger.e('🧾 Item menyebabkan error: $item');
                    logger.e('📌 Stack trace:\n$stackTrace');
                    return null;
                  }
                })
                .whereType<UsulanModel>()
                .toList();

        notifyListeners();
      } else {
        _errorMessage = 'Gagal memuat data: ${data['message']}';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
