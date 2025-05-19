import 'package:flutter/material.dart';

class CategoryChipsCustom extends StatelessWidget {
  const CategoryChipsCustom({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['Fiksi', 'Novel', 'Drama', 'Non-Fiksi'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categories
          .map(
            (category) => Chip(
              label: Text(category),
              backgroundColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(
                  color: Color.fromARGB(255, 240, 240, 240),
                  width: 2,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
