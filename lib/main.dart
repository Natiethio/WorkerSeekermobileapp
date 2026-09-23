import 'package:flutter/material.dart';
import 'package:firstapp/Pages/service_category_page.dart';
import 'package:firstapp/screens/todo_home.dart';
import 'package:firstapp/screens/teststate.dart';
import 'package:firstapp/screens/services.dart';
import 'package:firstapp/screens/trials.dart';
import 'package:firstapp/Pages/worker_detail_page.dart';
import 'package:firstapp/Pages/allservices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: WorkersHomePage(),
      routes: {
        '/service': (context) => const ServiceCategoryPage(),
        '/workerdetail': (context) => const WorkerDetailPage(),
        '/allservices': (context) => const AllServices(),
      },
    );
  }
}

