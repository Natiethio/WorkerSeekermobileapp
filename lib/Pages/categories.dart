import 'package:flutter/material.dart';
import '../data/worker_detail_data.dart';
import '../models/service_category.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/worker_category_provider.dart';
import '../providers/worker_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

class Workers extends ConsumerStatefulWidget {
  const Workers({super.key});

  @override
  ConsumerState<Workers> createState() => _WorkersState();
}

class _WorkersState extends ConsumerState<Workers> {

  final ScrollController _categoryScrollController =
  ScrollController();

  Timer? _categoryTimer;

  @override
  void initState() { //Set things up before this page starts being used so used We use it to start the automatic scrolling timer:
    super.initState();

    _categoryTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => _scrollToNextCategory(), // called evey 7 seconds
    );
  }

  // 3. Scroll
  void _scrollToNextCategory() {
    if (!_categoryScrollController.hasClients) return;

    final maxScroll =
        _categoryScrollController.position.maxScrollExtent;

    final currentScroll =
        _categoryScrollController.offset;

    if (currentScroll >= maxScroll - 10) {
      _categoryScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    } else {
      _categoryScrollController.animateTo(
        currentScroll + 180,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }


  String selectedCategory = "All";

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  double maxPrice = 500; // slider max
  double selectedMaxPrice = 500; // user-selected value

  //change wage string to number

  double _parseWage(String wage) {
    return double.tryParse(wage.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  void _openPriceFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter by price",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Up to ${selectedMaxPrice.toInt()} ETB",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF04B461),
                    ),
                  ),

                  Slider(
                    min: 50,
                    max: maxPrice,
                    divisions: 9,
                    // 50,100,150...
                    value: selectedMaxPrice,
                    activeColor: const Color(0xFF04B461),
                    label: "${selectedMaxPrice.toInt()} ETB",
                    onChanged: (value) {
                      setModalState(() {
                        selectedMaxPrice = value; // updates slider UI
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF04B461),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {}); // refresh grid
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Apply",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    final workersAsync = ref.watch(workerProvider);

    final Widget workersSliver = workersAsync.when(
      loading: () {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: SpinKitThreeBounce(
              color: Color(0xFF04B461),
              size: 22,
            ),
          ),
        );
      },

      error: (error, stackTrace) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              "Failed to load workers",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        );
      },

      data: (workersdata) {
        final filteredWorkers = workersdata.where((worker) {
          final matchesCategory =
              selectedCategory == "All"
                  ? true
                  : worker.profession == selectedCategory;

          final matchesSearch =
              searchQuery.isEmpty
                  ? true
                  : worker.name
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      worker.profession
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());

          final matchesPrice =
              _parseWage(worker.wage) <= selectedMaxPrice;

          return matchesCategory &&
              matchesSearch &&
              matchesPrice;
        }).toList();

        if (filteredWorkers.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final worker = filteredWorkers[index];

                return GestureDetector(
                  onTap: () {
                    print('Clicked: ${worker.name}');

                    Navigator.pushNamed(
                      context,
                      '/workerdetail',
                      arguments: worker,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.grey.shade100,
                              width: 4,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(100),
                            child: Image.network(
                              worker.image,
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Image.asset(
                                  worker.sex.toLowerCase() ==
                                          'female'
                                      ? 'assets/images/Profile-Default-Female.png'
                                      : 'assets/images/Profile-Default-Male.png',
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          worker.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          worker.profession,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const Spacer(),

                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: worker.wage,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF04B461),
                                ),
                              ),
                              TextSpan(
                                text: "/hr",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: filteredWorkers.length,
            ),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: RefreshIndicator(
        backgroundColor: const Color(0xFF04B461),
        color: Colors.white,
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(workerProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "Search for workers..",
                                border: InputBorder.none,
                                icon: Icon(Icons.search),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _openPriceFilter,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF04B461),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.tune, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  //workers filter section
                  categoriesAsync.when(
                    loading: () => buildCategoryShimmer(),
                    error: (error, stackTrace) => buildErrorWidget(),
                    data: (apiCategories) {
                      final sortedApiCategories = List<ServiceCategory>.from(apiCategories)
                        ..sort((a, b) => a.order.compareTo(b.order));

                      final uiCategories = [
                        ServiceCategory(
                          name: "All",
                          icon: "https://res.cloudinary.com/dgrj6cljo/image/upload/v1786440968/menu_cegyfc.png",
                          iconwhite: "https://res.cloudinary.com/dgrj6cljo/image/upload/v1786440963/menuwhite_ipwekv.png",
                          description: "",
                          heroimage: "",
                          images: const [],
                          detail: '',
                        ),
                        ...sortedApiCategories,
                      ];

                      return SizedBox(
                        height: 48,
                        child: ListView.builder(
                          controller: _categoryScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: uiCategories.length,
                          itemBuilder: (context, index) {
                            final category = uiCategories[index];
                            final isSelected = selectedCategory == category.name;

                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategory = category.name;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF04B461)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        isSelected
                                            ? category.iconwhite
                                            : category.icon,
                                        width: 16,
                                        height: 16,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.category,
                                            size: 16,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black54,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            workersSliver,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://res.cloudinary.com/dgrj6cljo/image/upload/v1786531240/nodata_htouaj.png', // your image path
            width: 140, // logical UI size
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            "No workers found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Try changing the filter or search keyword",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget buildErrorWidget() {
    return SizedBox(
      height: 50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.wifi_off, color: Colors.red, size: 20),
            SizedBox(height: 5),
            Text("Something went wrong"),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryShimmer() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // ✅ fixed spacing
                Column(
                  mainAxisAlignment: MainAxisAlignment.center, // ✅ vertical align
                  crossAxisAlignment: CrossAxisAlignment.start, // ✅ left align text
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 10,
                        width: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 10,
                        width: 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _categoryTimer?.cancel();
    _categoryScrollController.dispose();
    super.dispose();
  }
}
