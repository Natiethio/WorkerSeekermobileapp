import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firstapp/models/service_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/worker_category_provider.dart';


class AllServices extends ConsumerStatefulWidget  {

  const AllServices({super.key});

  @override
  ConsumerState<AllServices> createState() => _AllServicesState();

}

class  _AllServicesState extends ConsumerState<AllServices> {

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text(
          "All Services",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        backgroundColor: Colors.grey.shade200,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: const Color(0xFF04B461),
        color: Colors.white,
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          await ref.read(categoriesProvider.future);
        },
        child: categoriesAsync.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: buildCategoryShimmer(),
              ),
            ],
          ),

          error: (error, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: buildErrorWidget(),
              ),
            ],
          ),

          data: (apiCategories) {
            final sortedCategories = List<ServiceCategory>.from(apiCategories)
              ..sort((a, b) => a.order.compareTo(b.order));

            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              itemCount: sortedCategories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final category = sortedCategories[index];

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
                          width: 46,
                          height: 46,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.category,
                              size: 46,
                              color: Colors.grey,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            category.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
            );
          },
        ),
      ),
    );
  }

  Widget buildCategoryShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
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
            Icon(Icons.error, color: Colors.red, size: 30),
            SizedBox(height: 5),
            Text("Something went wrong"),
          ],
        ),
      ),
    );
  }
}