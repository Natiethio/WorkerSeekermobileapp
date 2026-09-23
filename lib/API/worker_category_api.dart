import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/service_category.dart';

final workerApiProvider = Provider<WorkerApi>((ref) {
  return WorkerApi();
});

class WorkerApi {
  Future<List<ServiceCategory>> getCategories() async {

    print("========== API CALLED ==========");

    final url = Uri.parse(
      "http://10.0.2.2:5000/api/workerseekers/getallcategoriesname",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load categories");
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((e) => ServiceCategory.fromJson(e))
        .toList();
  }
}