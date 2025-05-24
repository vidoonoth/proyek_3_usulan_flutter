import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perpus_flutter/config/config.dart';

class UserProvider with ChangeNotifier {
  String? name;
  String? email;
  String? nik;
  String? numberphone;
  String? gender;
  String? joinedAt;
  String? profileImage;

  bool isLoading = true;
  Future<void> fetchUserData() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(Config.baseUrl('profile')),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      name = data['name'];
      email = data['email'];
      nik = data['nik'];
      numberphone = data['numberphone'];
      gender = data['gender'];
      joinedAt = data['created_at'];
      profileImage = data['profileImage'];

      isLoading = false;
      notifyListeners();
    } else {
      isLoading = false;
      notifyListeners();
    }
  }
}
