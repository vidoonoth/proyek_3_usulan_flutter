// import 'package:perpus_flutter/config/config.dart';

class Book {
  final String title;
  final String genre;
  final String isbn;
  final String author;
  final String publicationYear;
  final String publisher;
  final String description;
  final String synopsis;
  final String? image;

  Book({
    required this.title,
    required this.genre,
    required this.isbn,
    required this.author,
    required this.publicationYear,
    required this.publisher,
    required this.description,
    required this.synopsis,
    this.image,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['bookTitle'] ?? 'Tanpa Judul',
      genre: json['genre'] ?? '-',
      isbn: json['isbn'] ?? '-',
      author: json['author'] ?? 'Tidak diketahui',
      publicationYear: json['publicationYear'] ?? '-',
      publisher: json['publisher'] ?? '-',
      description: json['description'] ?? '-',
      synopsis: json['synopsis'] ?? '-',
      image: json['bookImage'],
    );
  }
}