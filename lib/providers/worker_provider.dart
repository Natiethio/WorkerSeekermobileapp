import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../API/all_worker_api.dart';
import '../models/WorkerDetail.dart';

// final workerApiProvider = Provider<allworkerApiProvider>((ref) {
//   return WorkerApi();
// });

final workerProvider=
FutureProvider<List<WorkerDetail>>((ref) async {
  final api = ref.read(allworkerApiProvider);

  return api.getWorkers();
});