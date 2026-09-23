import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../API/worker_category_api.dart';
import '../models/service_category.dart';

final categoriesProvider =
FutureProvider<List<ServiceCategory>>((ref) async {
  final api = ref.read(workerApiProvider);

  return api.getCategories();
});