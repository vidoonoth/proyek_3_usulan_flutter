// import 'package:perpus_flutter/config/config.dart';

class UsulanModel {
  final int id;
  final String bookTitle;
  final String genre;
  final String isbn;
  final String author;
  final int publicationYear;
  final String publisher;
  final String date;
  final String? bookImage; // nullable
  final String status;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UsulanModel({
    required this.id,
    required this.bookTitle,
    required this.genre,
    required this.isbn,
    required this.author,
    required this.publicationYear,
    required this.publisher,
    required this.date,
    this.bookImage,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
  factory UsulanModel.fromJson(Map<String, dynamic> json) {
    return UsulanModel(
      id: json['id'],
      bookTitle: json['bookTitle'],
      genre: json['genre'],
      isbn: json['isbn'],
      author: json['author'],
      publicationYear: json['publicationYear'],
      publisher: json['publisher'],
      date: json['date'],
      // Jangan proses URL di sini jika backend sudah mengembalikan URL lengkap
      bookImage: json['bookImage'], // langsung ambil nilai dari JSON
      status: json['status'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
