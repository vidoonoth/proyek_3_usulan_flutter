import 'dart:convert';
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

  Future<void> fetchUserData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

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
      } else {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? 'Failed to load profile data';
        logger.e('Failed to fetch user data', 
          error: errorData,
          stackTrace: StackTrace.current
        );
      }
    } catch (e) {
      errorMessage = 'Connection error: ${e.toString()}';
      logger.e('Exception while fetching user data',
        error: e,
        stackTrace: StackTrace.current
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
        errorMessage = errorData['message'] ?? 'Update failed: ${response.statusCode}';
        
        logger.e('Profile update failed',
          error: {
            'statusCode': response.statusCode,
            'errorData': errorData,
            'sentData': data,
          },
          stackTrace: StackTrace.current
        );
        
        return false;
      }
    } catch (e) {
      errorMessage = 'Connection error: ${e.toString()}';
      logger.e('Exception during profile update',
        error: e,
        stackTrace: StackTrace.current
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}