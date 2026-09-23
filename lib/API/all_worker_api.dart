import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/WorkerDetail.dart';

final allworkerApiProvider = Provider<AllWorkerApi>((ref) {
  return AllWorkerApi();
});

class AllWorkerApi {
  Future<List<WorkerDetail>> getWorkers() async {
    final url = Uri.parse(
      "http://10.0.2.2:5000/api/workerseekers/getallworkers",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load workers");
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((worker) => WorkerDetail.fromJson(worker))
        .toList();
  }
}



