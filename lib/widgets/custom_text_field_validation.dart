import 'package:flutter/material.dart';

class CustomTextFieldValidation extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final int? maxLength;
  final TextInputType? keyboardType;

  const CustomTextFieldValidation({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    this.maxLength,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: keyboardType,
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
              errorText: errorText,
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}