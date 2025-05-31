import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(246, 0, 0, 0)),
          filled: true,
          fillColor: Colors.blueGrey[50],
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey[100]!),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey[200]!),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}