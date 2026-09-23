import 'package:flutter/material.dart';
import './Review.dart';
class WorkerDetail {
  final String name;
  final String profession;
  final List<String> other_professions;
  final String city;
  final String location;
  final String heroimage;
  final String image;
  final String experience;
  final String note;
  final String wage;
  final num rating;
  final String defaultprevious;
  final List<String> previousworkimages;
  final List<Review> reviews;
  final String sex;


  WorkerDetail({
    required this.name,
    required this.profession,
    required this.other_professions,
    required this.city,
    required this.location,
    required this.heroimage,
    required this.image,
    required this.experience,
    required this.note,
    required this.wage,
    required this.rating,
    required this.previousworkimages,
    required this.defaultprevious,
    required this.reviews,
    required this.sex,

  });

  factory WorkerDetail.fromJson(Map<String, dynamic> json) {
    return WorkerDetail(
      name: json['name'] ?? '',
      profession: json['profession'] ?? '',
      other_professions:
      List<String>.from(json['other_professions'] ?? []),
      city: json['city'] ?? '',
      location: json['location'] ?? '',
      heroimage: json['heroimage'] ?? '',
      image: json['image'] ?? '',
      experience: json['experience'] ?? '',
      note: json['note'] ?? '',
      wage: json['wage'] ?? '',
      rating: json['rating'] ?? 0,
      defaultprevious: json['defaultprevious'] ?? '',
      previousworkimages:
      List<String>.from(json['previousworkimages'] ?? []),
      reviews: (json['reviews'] as List? ?? [])
          .map((review) => Review.fromJson(review))
          .toList(),
      sex: json['sex'] ?? '',
    );
  }
}
