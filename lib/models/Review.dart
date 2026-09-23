import 'package:flutter/material.dart';
class Review {
  // final String worker;
  // final String workeremail;
  final String reviewer;
  final String comment;
  final num rating;
  final String date;

  Review({
    // required this.worker,
    // required this.workeremail,
    required this.reviewer,
    required this.comment,
    required this.rating,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewer: json['reviewer'] ?? '',
      comment: json['comment'] ?? '',
      rating: json['rating'] ?? 0,
      date: json['date'] ?? '',
    );
  }
}