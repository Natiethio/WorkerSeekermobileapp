import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:firstapp/models/service_category.dart';
import '../providers/worker_category_provider.dart';
import '../providers/worker_provider.dart';

class ServiceCategoryPage extends ConsumerStatefulWidget {
  const ServiceCategoryPage({super.key});

  @override
  ConsumerState<ServiceCategoryPage> createState() =>
      _ServiceCategoryPageState();
}

class _ServiceCategoryPageState extends ConsumerState<ServiceCategoryPage> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final workersAsync = ref.watch(workerProvider);

    final ServiceCategory category =
    ModalRoute
        .of(context)!
        .settings
        .arguments as ServiceCategory;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade200,

      appBar: AppBar(
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        backgroundColor: Colors.grey.shade200,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: RefreshIndicator(  //Only detects pull-down gestures from a scrollable widget such as GridView, ListView, or SingleChildScrollView
        backgroundColor: const Color(0xFF04B461),
        color: Colors.white,

        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(workerProvider);

          // Wait until both providers finish loading again
          await ref.read(categoriesProvider.future);
          await ref.read(workerProvider.future);
        },


      child: categoriesAsync.when(
        loading: () {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: const Center(
                  child: SpinKitThreeBounce(
                    color: Color(0xFF04B461),
                    size: 22,
                  ),
                ),
              ),
            ],
          );
        },

        error: (error, stackTrace) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Text(
                    "Failed to load category",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          );
        },

        data: (apiCategories) {
          // Find the category from the API
          final currentCategory = apiCategories.firstWhere(
                (item) => item.name == category.name,
            orElse: () => category,
          );

          return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==============================
                  // HERO IMAGE
                  // ==============================
                  SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          currentCategory.heroimage,
                          width: double.infinity,
                          fit: BoxFit.contain,

                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded || frame != null) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  child,

                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: 90,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.0),
                                            const Color(0xFF04B461)
                                                .withValues(alpha: 0.2),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: const ColoredBox(
                                color: Colors.white,
                              ),
                            );
                          },

                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==============================
                  // DESCRIPTION
                  // ==============================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        currentCategory.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==============================
                  // DETAIL
                  // ==============================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      currentCategory.detail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==============================
                  // WORKERS
                  // ==============================
                  workersAsync.when(
                    loading: () {
                      return const SizedBox(
                        height: 250,
                        child: Center(
                          child: SpinKitThreeBounce(
                            color: Color(0xFF04B461),
                            size: 22,
                          ),
                        ),
                      );
                    },

                    error: (error, stackTrace) {
                      return const SizedBox(
                        height: 250,
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
                        return worker.profession == currentCategory.name;
                      }).toList();

                      if (filteredWorkers.isEmpty) {
                        return SizedBox(
                          height: 400,
                          child: _buildEmptyState(currentCategory.name),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        // IMPORTANT:
                        // The page itself now scrolls.
                        // So the GridView must not scroll independently.
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: filteredWorkers.length,

                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),

                        itemBuilder: (context, index) {
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Profile image
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: Colors.grey.shade100,
                                        width: 4,
                                      ),
                                    ),

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),

                                      child: Image.network(
                                        worker.image,
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,

                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            worker.sex.toLowerCase() == 'female'
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

                                  const SizedBox(height: 8),

                                  // Name
                                  Text(
                                    worker.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // Profession
                                  Text(
                                    worker.profession,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const Spacer(),

                                  // Wage
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: worker.wage,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF04B461),
                                          ),
                                        ),

                                        TextSpan(
                                          text: "/hr",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
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
                      );
                    },
                  ),

                  // Extra bottom space
                  const SizedBox(height: 20),
                ],
              ),
            );

        },
      )

        // data: (apiCategories) {
        //   // Find the category from the API
        //   final currentCategory = apiCategories.firstWhere(
        //         (item) => item.name == category.name,
        //     orElse: () => category,
        //   );
        //
        //   return RefreshIndicator(
        //       backgroundColor:  const Color(0xFF04B461),
        //       color: Colors.white,
        //       onRefresh: () async {
        //         ref.invalidate(categoriesProvider);
        //         ref.invalidate(workerProvider);
        //       },
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           SizedBox(
        //             height: 280,
        //             width: double.infinity,
        //             child: Padding(
        //               padding: const EdgeInsets.all(8),
        //               child: ClipRRect(
        //                 borderRadius: BorderRadius.circular(15),
        //                 child: Image.network(
        //                   currentCategory.heroimage,
        //                   width: double.infinity,
        //                   fit: BoxFit.contain,
        //
        //                   frameBuilder:
        //                       (context, child, frame, wasSynchronouslyLoaded) {
        //                     if (wasSynchronouslyLoaded || frame != null) {
        //                       return Stack(
        //                         fit: StackFit.expand,
        //                         children: [
        //                           child,
        //
        //                           Positioned(
        //                             left: 0,
        //                             right: 0,
        //                             bottom: 0,
        //                             height: 90,
        //                             child: Container(
        //                               decoration: BoxDecoration(
        //                                 gradient: LinearGradient(
        //                                   begin: Alignment.topCenter,
        //                                   end: Alignment.bottomCenter,
        //                                   colors: [
        //                                     Colors.white.withValues(
        //                                       alpha: 0.0,
        //                                     ),
        //                                     const Color(
        //                                       0xFF04B461,
        //                                     ).withValues(alpha: 0.2),
        //                                   ],
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //                         ],
        //                       );
        //                     }
        //
        //                     return Shimmer.fromColors(
        //                       baseColor: Colors.grey.shade300,
        //                       highlightColor: Colors.grey.shade100,
        //                       child: const ColoredBox(color: Colors.white),
        //                     );
        //                   },
        //
        //                   errorBuilder: (context, error, stackTrace) {
        //                     return const Center(
        //                       child: Icon(
        //                         Icons.broken_image,
        //                         color: Colors.grey,
        //                         size: 40,
        //                       ),
        //                     );
        //                   },
        //                 ),
        //               ),
        //             ),
        //           ),
        //
        //           const SizedBox(height: 10),
        //
        //           Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 16),
        //             child: Align(
        //               alignment: Alignment.center,
        //               child: Text(
        //                 currentCategory.description,
        //                 textAlign: TextAlign.center,
        //                 style: const TextStyle(
        //                   fontSize: 20,
        //                   fontWeight: FontWeight.bold,
        //                   color: Colors.black,
        //                 ),
        //               ),
        //             ),
        //           ),
        //
        //           const SizedBox(height: 10),
        //
        //           Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 16),
        //             child: Text(
        //               currentCategory.detail,
        //               textAlign: TextAlign.center,
        //               style: const TextStyle(
        //                 fontSize: 15,
        //                 fontWeight: FontWeight.normal,
        //                 color: Colors.black54,
        //               ),
        //             ),
        //           ),
        //
        //           const SizedBox(height: 20),
        //
        //           /// ==============================
        //           /// WORKERS
        //           /// ==============================
        //           Expanded(
        //             child: workersAsync.when(
        //
        //               /// Loading
        //               loading: () {
        //                 return const Center(
        //                   child: SpinKitThreeBounce(
        //                     color: Color(0xFF04B461),
        //                     size: 22,
        //                   ),
        //                 );
        //               },
        //
        //               /// Error
        //               error: (error, stackTrace) {
        //                 return Center(
        //                   child: Text(
        //                     "Failed to load workers",
        //                     style: TextStyle(color: Colors.grey.shade600),
        //                   ),
        //                 );
        //               },
        //
        //               /// Workers loaded
        //               data: (workersdata) {
        //                 final filteredWorkers = workersdata.where((worker) {
        //                   return worker.profession == currentCategory.name;
        //                 }).toList();
        //
        //                 if (filteredWorkers.isEmpty) {
        //                   return _buildEmptyState(currentCategory.name);
        //                 }
        //
        //                 return GridView.builder(
        //                   padding: const EdgeInsets.symmetric(
        //                     horizontal: 16,
        //                     vertical: 10,
        //                   ),
        //                   itemCount: filteredWorkers.length,
        //
        //                   gridDelegate:
        //                   const SliverGridDelegateWithFixedCrossAxisCount(
        //                     crossAxisCount: 3,
        //                     crossAxisSpacing: 12,
        //                     mainAxisSpacing: 12,
        //                     childAspectRatio: 0.72,
        //                   ),
        //
        //                   itemBuilder: (context, index) {
        //                     final worker = filteredWorkers[index];
        //
        //                     return GestureDetector(
        //                       onTap: () {
        //                         print('Clicked: ${worker.name}');
        //
        //                         Navigator.pushNamed(
        //                           context,
        //                           '/workerdetail',
        //                           arguments: worker,
        //                         );
        //                       },
        //
        //                       child: Container(
        //                         decoration: BoxDecoration(
        //                           color: Colors.white60,
        //                           borderRadius: BorderRadius.circular(14),
        //                         ),
        //                         padding: const EdgeInsets.all(8),
        //
        //                         child: Column(
        //                           crossAxisAlignment: CrossAxisAlignment.center,
        //                           children: [
        //
        //                             /// Profile image
        //                             Container(
        //                               decoration: BoxDecoration(
        //                                 borderRadius: BorderRadius.circular(
        //                                     100),
        //                                 border: Border.all(
        //                                   color: Colors.grey.shade100,
        //                                   width: 4,
        //                                 ),
        //                               ),
        //
        //                               child: ClipRRect(
        //                                 borderRadius: BorderRadius.circular(
        //                                     100),
        //
        //                                 child: Image.network(
        //                                   worker.image,
        //                                   height: 70,
        //                                   width: 70,
        //                                   fit: BoxFit.cover,
        //
        //                                   errorBuilder: (context, error,
        //                                       stackTrace) {
        //                                     return Image.asset(
        //                                       worker.sex.toLowerCase() ==
        //                                           'female'
        //                                           ? 'assets/images/Profile-Default-Female.png'
        //                                           : 'assets/images/Profile-Default-Male.png',
        //
        //                                       height: 70,
        //                                       width: 70,
        //                                       fit: BoxFit.cover,
        //                                     );
        //                                   },
        //                                 ),
        //                               ),
        //                             ),
        //
        //                             const SizedBox(height: 8),
        //
        //                             /// Name
        //                             Text(
        //                               worker.name,
        //                               textAlign: TextAlign.center,
        //                               style: const TextStyle(
        //                                 fontWeight: FontWeight.w600,
        //                                 fontSize: 13,
        //                               ),
        //                             ),
        //
        //                             const SizedBox(height: 4),
        //
        //                             /// Profession
        //                             Text(
        //                               worker.profession,
        //                               style: TextStyle(
        //                                 fontSize: 11,
        //                                 color: Colors.grey.shade600,
        //                               ),
        //                             ),
        //
        //                             const Spacer(),
        //
        //                             /// Wage
        //                             RichText(
        //                               text: TextSpan(
        //                                 children: [
        //                                   TextSpan(
        //                                     text: worker.wage,
        //                                     style: const TextStyle(
        //                                       fontWeight: FontWeight.bold,
        //                                       fontSize: 13,
        //                                       color: Color(0xFF04B461),
        //                                     ),
        //                                   ),
        //                                   TextSpan(
        //                                     text: "/hr",
        //                                     style: TextStyle(
        //                                       fontWeight: FontWeight.w400,
        //                                       fontSize: 12,
        //                                       color: Colors.grey.shade600,
        //                                     ),
        //                                   ),
        //                                 ],
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                 );
        //               },
        //             ),
        //           ),
        //         ],
        //       )
        //   );
        // },
      ),
    );
  }

  Widget _buildEmptyState(String categoryName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://res.cloudinary.com/dgrj6cljo/image/upload/v1786531240/nodata_htouaj.png',
            width: 140,
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
            "Currently we do not have registered "
                "$categoryName workers",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
