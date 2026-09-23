import 'package:flutter/material.dart';
import '../models/service_category.dart';
import '../data/worker_detail_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/worker_category_provider.dart';

class ServicesHome extends ConsumerStatefulWidget {
  const ServicesHome({super.key});

  @override
  ConsumerState<ServicesHome> createState() => _ServicesHomePageState();
}

class _ServicesHomePageState extends ConsumerState<ServicesHome> {
  // bool isLoading = true;
  // bool hasError = true;
  // List<ServiceCategory> apiCategories = [];


  final topRatedWorkers = workersdata
      .where((worker) => worker.rating >= 4.5)
      .toList();



  void fetchCategories() async {
    try{
      final categoriesAPI = await fetchCategoriesFromAPI();
      setState(() {
        // apiCategories = categoriesAPI;
        // isLoading = false;
        // hasError = false;
      });
    }
    catch (e) {
      setState(() {
        // isLoading = false;
        // hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey avatarKey = GlobalKey();

    final categoriesAsync = ref.watch(categoriesProvider);

    // print(categoriesAsync);

    print("Home build");

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade200,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            //............Banner Section..........
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF04B461),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      // --- Decorative Shapes (Patterns) ---
                      Positioned(
                        top: -30,
                        right: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -10,
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 130,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE27A).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      // --- Main Content (Text) ---
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: const TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Get Discount \nUp to ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            height: 1.2,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "30%",
                                          style: TextStyle(
                                            fontSize: 24,
                                            height: 1.2,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFE27A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "on your first worker order",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1F3E56),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Get Started",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                      ),

                      // --- Hero Image (Positioned to Bottom Edge) ---
                      Positioned(
                        bottom: 0,
                        right: 15,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: 120,
                              width: 130,
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Image.asset(
                              "assets/images/heroasset.png",
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ------------ CATEGORY TITLE & SEE ALL ---------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Popular Services",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/allservices');
                    },
                    child: Row(
                      children: const [
                        Text(
                          "See all",
                          style: TextStyle(
                            color: Color(0xFF5C5C5C),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios,
                          fontWeight: FontWeight.w600,
                          size: 15,
                            color: Color(0xFF292929),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // ------------ POPULAR SERVICES GRID ---------------
            categoriesAsync.when(
              loading: () => buildCategoryShimmer(),
              error: (error, stackTrace) {
                return buildErrorWidget();
              },
              data: (apiCategories) {
                final displayCategories = apiCategories
                    .where((c) => c.order >= 1 && c.order <= 8)
                    .toList()
                  ..sort((a, b) => a.order.compareTo(b.order));
                final itemCount = displayCategories.length;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemCount,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final category = displayCategories[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/service',
                            arguments: category,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E4E4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                category.icon,
                                width: 45,
                                height: 45,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.category,
                                    size: 45,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  category.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Poppins",
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),


            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Top Rated Workers",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
                physics: const BouncingScrollPhysics(),
                itemCount: topRatedWorkers.length,
                itemBuilder: (context, index) {
                final worker = topRatedWorkers[index];

                return GestureDetector(
                  onTap: () {
                    print('Clicked: ${worker.name}');
                    Navigator.pushNamed(
                      context,
                      '/workerdetail',
                      arguments: worker,
                    );
                  },
                    child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              worker.image,
                              height: 55,
                              width: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  worker.sex.toLowerCase() == 'female'
                                      ? 'assets/images/Profile-Default-Female.png'
                                      : 'assets/images/Profile-Default-Male.png',
                                  height: 55,
                                  width: 55,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  worker.profession,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < worker.rating.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 16,
                                      color: Colors.orange,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  Future<List<ServiceCategory>> fetchCategoriesFromAPI() async {
    final url = Uri.parse(
        "http://10.0.2.2:5000/api/workerseekers/getallcategoriesname"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);


      return data
          .map((jsonItem) => ServiceCategory.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Widget buildCategoryShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildErrorWidget() {
    return SizedBox(
      height: 105,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.wifi_off, color: Colors.red, size: 30),
            SizedBox(height: 5),
            Text("Something went wrong"),
          ],
        ),
      ),
    );
  }
}
