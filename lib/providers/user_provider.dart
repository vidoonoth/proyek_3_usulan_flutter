import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perpus_flutter/config/config.dart';
import 'package:logger/logger.dart';

class UserProvider with ChangeNotifier {
  String? id;
  String? username;
  String? name;
  String? email;
  String? nik;
  String? numberphone;
  String? gender;
  String? joinedAt;
  String? profileImage;
  bool isLoading = true;
  String? errorMessage;

  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  Future<void> loadUserFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    // Ambil user_id sebagai int, lalu konversi ke String
    final intId = prefs.getInt('user_id');
    id = intId != null ? intId.toString() : null;
    username = prefs.getString('user_username');
    name = prefs.getString('user_name');
    email = prefs.getString('user_email');
    nik = prefs.getString('user_nik');
    numberphone = prefs.getString('user_numberphone');
    gender = prefs.getString('user_gender');
    joinedAt = prefs.getString('user_joinedAt');
    profileImage = prefs.getString('user_profileImage');
    notifyListeners();
  }

  Future<void> saveUserToCache() async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan user_id sebagai int jika bisa di-parse, jika tidak kosongkan
    if (id != null && int.tryParse(id!) != null) {
      await prefs.setInt('user_id', int.parse(id!));
    } else {
      await prefs.remove('user_id');
    }
    await prefs.setString('user_username', username ?? '');
    await prefs.setString('user_name', name ?? '');
    await prefs.setString('user_email', email ?? '');
    await prefs.setString('user_nik', nik ?? '');
    await prefs.setString('user_numberphone', numberphone ?? '');
    await prefs.setString('user_gender', gender ?? '');
    await prefs.setString('user_joinedAt', joinedAt ?? '');
    await prefs.setString('user_profileImage', profileImage ?? '');
  }

  Future<void> fetchUserData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Load cache dulu sebelum fetch
      await loadUserFromCache();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      logger.d('Fetching user data...');
      final response = await http.get(
        Uri.parse(Config.baseUrl('profile')),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        id = data['id'].toString();
        username = data['username'];
        name = data['name'];
        email = data['email'];
        nik = data['nik'];
        numberphone = data['numberphone'];
        gender = data['gender'];
        joinedAt = data['created_at'];
        profileImage = data['profile_image_url'];
        errorMessage = null;
        logger.i('User data fetched successfully');
        // Simpan ke cache
        await saveUserToCache();
      } else {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? 'Failed to load profile data';
        logger.e(
          'Failed to fetch user data',
          error: errorData,
          stackTrace: StackTrace.current,
        );
      }
    } catch (e) {
      errorMessage = 'Connection error: ${e.toString()}';
      logger.e(
        'Exception while fetching user data',
        error: e,
        stackTrace: StackTrace.current,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      logger.d('Attempting to update profile with data: $data');

      // Handle image upload separately if exists
      if (data.containsKey('profileImage')) {
        logger.d('Profile image update detected (not implemented)');
        // Implementation for image upload would go here
        // This requires multipart request
      }

      final response = await http.put(
        Uri.parse(Config.baseUrl('profile/$id')),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      logger.d('Update response status: ${response.statusCode}');
      logger.d('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        logger.i('Profile updated successfully');
        await fetchUserData();
        return true;
      } else {
        final errorData = json.decode(response.body);
        errorMessage =
            errorData['message'] ?? 'Update failed: ${response.statusCode}';

        logger.e(
          'Profile update failed',
          error: {
            'statusCode': response.statusCode,
            'errorData': errorData,
            'sentData': data,
          },
          stackTrace: StackTrace.current,
        );

        return false;
      }
    } catch (e) {
      errorMessage = 'Connection error: ${e.toString()}';
      logger.e(
        'Exception during profile update',
        error: e,
        stackTrace: StackTrace.current,
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfileWithImage(
    Map<String, dynamic> data, {
    File? imageFile,
    bool removeImage = false,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var uri = Uri.parse(Config.baseUrl('profile/$id'));
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['_method'] = 'PUT';

      // Tambahkan field lain
      data.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          request.fields[key] = value.toString();
        }
      });

      // Jika ingin menghapus gambar
      if (removeImage) {
        request.fields['removeProfileImage'] = 'true';
      }
      // Jika ada gambar baru
      else if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profileImage', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      logger.d('Update response status: ${response.statusCode}');
      logger.d('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        logger.i('Profile updated successfully');
        await fetchUserData();
        return true;
      } else {
        final errorData = json.decode(response.body);
        errorMessage =
            errorData['message'] ?? 'Update failed: ${response.statusCode}';
        logger.e(
          'Profile update failed',
          error: {
            'statusCode': response.statusCode,
            'errorData': errorData,
            'sentData': data,
          },
          stackTrace: StackTrace.current,
        );
        return false;
      }
    } catch (e) {
      errorMessage = 'Connection error: ${e.toString()}';
      logger.e(
        'Exception during profile update',
        error: e,
        stackTrace: StackTrace.current,
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
