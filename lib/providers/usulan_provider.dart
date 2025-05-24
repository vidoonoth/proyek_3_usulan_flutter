import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usulan.dart';
import 'package:logger/logger.dart';
import 'package:perpus_flutter/config/config.dart';

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

  UsulanModel? _selectedUsulan;
  UsulanModel? get selectedUsulan => _selectedUsulan;

  void setSelectedUsulan(UsulanModel usulan) {
    _selectedUsulan = usulan;
    notifyListeners();
  }

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
    final userId = prefs.getInt('user_id');

    if (token == null || userId == null) {
      _errorMessage =
          'Token atau user ID tidak ditemukan. Silakan login ulang.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final uri = Uri.parse(Config.baseUrl('pengusulan'));
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
          ..fields['synopsis'] = 'Sinopsis default'
          ..fields['user_id'] = userId.toString();

    if (bookImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('bookImage', bookImage.path),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      logger.i('📤 Response Kirim Usulan: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _success = true;
      } else {
        _errorMessage =
            'Gagal mengirim usulan (${response.statusCode}): $responseBody';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat mengirim usulan: $e';
      logger.e('❌ Exception: $e');
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

    final url = Uri.parse(Config.baseUrl('riwayat-usulan'));

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      logger.i("📥 Response Riwayat Usulan: $data");

      if (response.statusCode == 200) {
        final List<dynamic> usulanList = data['data'];

        _riwayatUsulan =
            usulanList
                .map((item) {
                  try {
                    return UsulanModel.fromJson(item);
                  } catch (e, stackTrace) {
                    logger.e('❌ Error parsing item: $e');
                    logger.e('🧾 Item error: $item');
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
      logger.e('❌ Exception saat fetch: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUsulan({
    required int usulanId,
    required String bookTitle,
    required String genre,
    required String isbn,
    required String author,
    required String publisher,
    required String publicationYear,
    File? bookImage,
    required bool removeImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _success = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final uri = Uri.parse(Config.baseUrl('pengusulan/$usulanId'));
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..headers['Accept'] = 'application/json'
          ..fields['bookTitle'] = bookTitle
          ..fields['genre'] = genre
          ..fields['isbn'] = isbn
          ..fields['author'] = author
          ..fields['publisher'] = publisher
          ..fields['publicationYear'] = publicationYear
          ..fields['_method'] = 'PUT';

    // Tambahkan ini untuk menghapus gambar
    if (removeImage) {
      request.fields['remove_image'] = '1';
    }

    if (bookImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('bookImage', bookImage.path),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        _success = true;

        // Perbaikan path gambar dari response
        if (responseData['data']['bookImage'] != null) {
          String imagePath = responseData['data']['bookImage'];
          if (imagePath.contains('usulan/usulan/')) {
            imagePath = imagePath.replaceFirst('usulan/usulan/', 'usulan/');
            responseData['data']['bookImage'] = imagePath;
          }
        }

        await fetchRiwayatUsulan();
      }
    } catch (e) {
      logger.e("Error updating usulan: $e");
    }
  }

  // Add these to your UsulanProvider class
  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;
  Future<void> deleteUsulan(int usulanId) async {
    _isDeleting = true;
    _errorMessage = null;
    _success = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
      _isDeleting = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse(Config.baseUrl('pengusulan/$usulanId'));

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _success = true;
        _riwayatUsulan.removeWhere((usulan) => usulan.id == usulanId);
      } else {
        _errorMessage = responseData['message'] ?? 'Gagal menghapus usulan';
      }
    } on SocketException {
      _errorMessage =
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } on TimeoutException {
      _errorMessage = 'Waktu koneksi habis. Silakan coba lagi.';
    } on FormatException {
      _errorMessage = 'Terjadi kesalahan dalam memproses data.';
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<void> deleteAllUsulan() async {
    _isDeleting = true;
    _errorMessage = null;
    _success = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    if (token == null || userId == null) {
      _errorMessage =
          'Token atau user ID tidak ditemukan. Silakan login ulang.';
      _isDeleting = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse(Config.baseUrl('pengusulan/delete-all/$userId'));

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _success = true;
        _riwayatUsulan.clear();
      } else {
        _errorMessage =
            responseData['message'] ?? 'Gagal menghapus semua usulan';
      }
    } on SocketException {
      _errorMessage =
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } on TimeoutException {
      _errorMessage = 'Waktu koneksi habis. Silakan coba lagi.';
    } on FormatException {
      _errorMessage = 'Terjadi kesalahan dalam memproses data.';
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
