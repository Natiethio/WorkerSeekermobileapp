import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/WorkerDetail.dart';
import '../models/Review.dart';
import '../providers/worker_provider.dart';

class WorkerDetailPage extends ConsumerStatefulWidget {
  const WorkerDetailPage({super.key});

  @override
  ConsumerState<WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends ConsumerState<WorkerDetailPage> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  WorkerDetail? _routeWorker;
  int _activeTabIndex = 0;
  bool _isFavorite = false;
  int _syncedImageCount = -1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeWorker == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is WorkerDetail) {
        _routeWorker = args;
      }
    }
  }

  void _syncAutoSlide(List<String> images) {
    if (_syncedImageCount == images.length) return;
    _syncedImageCount = images.length;
    _timer?.cancel();

    if (images.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.round() ?? _currentPage) + 1;
        if (nextPage >= images.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(workerProvider);
    try {
      await ref.read(workerProvider.future);
    } catch (_) {}
  }

  Widget _buildImage(
    String url, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    String? fallbackSex,
  }) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF04B461),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage(fallbackSex, width: width, height: height, fit: fit);
        },
      );
    } else if (url.isNotEmpty) {
      return Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage(fallbackSex, width: width, height: height, fit: fit);
        },
      );
    } else {
      return _buildFallbackImage(fallbackSex, width: width, height: height, fit: fit);
    }
  }

  Widget _buildFallbackImage(
    String? sex, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (sex != null && sex.isNotEmpty) {
      return Image.asset(
        sex.toLowerCase() == 'female'
            ? 'assets/images/Profile-Default-Female.png'
            : 'assets/images/Profile-Default-Male.png',
        width: width,
        height: height,
        fit: fit,
      );
    }
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 28),
      ),
    );
  }

  String _getLocationText(String location, String city) {
    if (location.isNotEmpty && city.isNotEmpty) {
      return "$location, $city";
    } else if (location.isNotEmpty) {
      return location;
    } else if (city.isNotEmpty) {
      return city;
    }
    return "Addis Ababa, Ethiopia";
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(workerProvider);

    WorkerDetail? workerdata;
    if (_routeWorker != null) {
      workerdata = workersAsync.maybeWhen(
        data: (workers) {
          try {
            return workers.firstWhere(
              (w) => w.name == _routeWorker!.name,
              orElse: () => _routeWorker!,
            );
          } catch (_) {
            return _routeWorker;
          }
        },
        orElse: () => _routeWorker,
      );
    } else {
      workerdata = workersAsync.maybeWhen(
        data: (workers) => workers.isNotEmpty ? workers.first : null,
        orElse: () => null,
      );
    }

    // if (workerdata == null) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: const Text("Worker Detail"),
    //       backgroundColor: Colors.white,
    //       foregroundColor: Colors.black,
    //       elevation: 0,
    //     ),
    //     body: workersAsync.when(
    //       loading: () => const Center(
    //         child: CircularProgressIndicator(color: Color(0xFF04B461)),
    //       ),
    //       error: (err, stack) => Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             const Icon(Icons.wifi_off, color: Colors.red, size: 40),
    //             const SizedBox(height: 10),
    //             const Text("Failed to load worker details"),
    //             const SizedBox(height: 10),
    //             ElevatedButton(
    //               style: ElevatedButton.styleFrom(
    //                 backgroundColor: const Color(0xFF04B461),
    //               ),
    //               onPressed: () => ref.invalidate(workerProvider),
    //               child: const Text("Retry", style: TextStyle(color: Colors.white)),
    //             ),
    //           ],
    //         ),
    //       ),
    //       data: (_) => const Center(child: Text("No worker found")),
    //     ),
    //   );
    // }

    if (workerdata == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Worker Detail"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        body: RefreshIndicator(
          backgroundColor: const Color(0xFF04B461),
          color: Colors.white,

          onRefresh: () async {
            ref.invalidate(workerProvider);

            await ref.read(workerProvider.future);
          },

          child: workersAsync.when(
            loading: () {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF04B461),
                      ),
                    ),
                  ),
                ],
              );
            },

            error: (err, stack) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.red,
                            size: 40,
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Failed to load worker details",
                          ),

                          const SizedBox(height: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF04B461),
                            ),
                            onPressed: () => ref.invalidate(workerProvider),
                            child: const Text(
                              "Retry",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },

            data: (_) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 500,
                    child: Center(
                      child: Text("No worker found"),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    final WorkerDetail currentWorker = workerdata;

    final images = currentWorker.previousworkimages.isNotEmpty
        ? currentWorker.previousworkimages
        : (currentWorker.heroimage.isNotEmpty
            ? [currentWorker.heroimage]
            : (currentWorker.defaultprevious.isNotEmpty
                ? [currentWorker.defaultprevious]
                : (currentWorker.image.isNotEmpty ? [currentWorker.image] : <String>[])));

    _syncAutoSlide(images);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 HERO SECTION (SCROLLABLE IMAGE SLIDER)
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: images.isEmpty
                      ? _buildFallbackImage(
                          currentWorker.sex,
                          width: double.infinity,
                          height: 300,
                        )
                      : PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return _buildImage(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              fallbackSex: currentWorker.sex,
                            );
                          },
                        ),
                ),

                // Top gradient overlay for action button contrast
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Top Actions Header (Back, Share, Favorite)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _circleIcon(Icons.arrow_back, () {
                            Navigator.pop(context);
                          }),
                          const SizedBox(width: 12),
                          const Text(
                            "Previous Works",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _circleIcon(Icons.share_outlined, () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Link copied to clipboard!"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }),
                          const SizedBox(width: 12),
                          _circleIcon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                            color: _isFavorite ? Colors.red : Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Overlay Thumbnail Slider at the bottom of the hero section
                if (images.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        height: 50,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final isSelected = _currentPage == index;
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF04B461)
                                        : Colors.white.withValues(alpha: 0.8),
                                    width: isSelected ? 2.5 : 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: _buildImage(
                                    images[index],
                                    fit: BoxFit.cover,
                                    fallbackSex: currentWorker.sex,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            /// 🔹 WORKER BASIC DETAILS
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profession Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF04B461).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currentWorker.profession,
                          style: const TextStyle(
                            color: Color(0xFF04B461),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                      // Rating display
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            currentWorker.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            " (${currentWorker.reviews.length} reviews)",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Worker Name
                  Text(
                    currentWorker.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Location Pin
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey.shade500, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _getLocationText(currentWorker.location, currentWorker.city),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// 🔹 TAB SEGMENT BAR
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tabHeader(0, "About"),
                  _tabHeader(1, "Other Services"),
                  _tabHeader(2, "Gallery"),
                  _tabHeader(3, "Reviews (${currentWorker.reviews.length})"),
                ],
              ),
            ),

            /// 🔹 SCROLLABLE CONTENT AREA (WITH PULL-DOWN REFRESH)
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: RefreshIndicator(
                  backgroundColor:  const Color(0xFF04B461),
                  color: Colors.white,
                  onRefresh: _handleRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: _buildActiveTabContent(currentWorker),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      /// 🔹 BOTTOM BOOKING BAR (WITH WAGE)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (currentWorker.wage.isNotEmpty) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Wage",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: "Poppins",
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: currentWorker.wage,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF04B461),
                            fontFamily: "Poppins",
                          ),
                        ),
                        TextSpan(
                          text: "/hr",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
            ],
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04B461),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Booking started with ${currentWorker.name}!"),
                      backgroundColor: const Color(0xFF04B461),
                    ),
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom tab bar button helper
  Widget _tabHeader(int index, String title) {
    final isSelected = _activeTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF04B461) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF04B461) : Colors.grey.shade600,
            fontFamily: "Poppins",
          ),
        ),
      ),
    );
  }

  /// Builds content dynamically based on current tab selection
  Widget _buildActiveTabContent(WorkerDetail workerdata) {
    switch (_activeTabIndex) {
      case 0:
        return _buildAboutContent(workerdata);
      case 1:
        return _buildServicesContent(workerdata);
      case 2:
        return _buildGalleryContent(workerdata);
      case 3:
        return _buildReviewsContent(workerdata);
      default:
        return _buildAboutContent(workerdata);
    }
  }

  /// 🔹 ABOUT TAB CONTENT
  Widget _buildAboutContent(WorkerDetail workerdata) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
        ),
        const SizedBox(height: 10),
        if (workerdata.experience.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF04B461).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF04B461).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 18,
                  color: Color(0xFF04B461),
                ),
                const SizedBox(width: 8),
                Text(
                  "${workerdata.experience} of experience",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF04B461),
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
          ),
        ],
        Text(
          workerdata.note.isNotEmpty
              ? workerdata.note
              : "I’m ${workerdata.name}, a dedicated ${workerdata.profession.toLowerCase()} with ${workerdata.experience} of hands-on experience. I focus on quality, reliability, and customer satisfaction.",
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.normal,
            height: 1.5,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 24),

        // Service Provider Section
        const Text(
          "Service Provider",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: _buildImage(
                  workerdata.image,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  fallbackSex: workerdata.sex,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workerdata.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Service Provider",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Call action button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Calling ${workerdata.name}..."),
                      backgroundColor: const Color(0xFF04B461),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04B461).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Color(0xFF04B461),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔹 SERVICES TAB CONTENT
  Widget _buildServicesContent(WorkerDetail workerdata) {
    final services = workerdata.other_professions;
    if (services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            "No additional services listed.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    final List<List<String>> columns = [];
    for (var i = 0; i < services.length; i += 3) {
      final end = (i + 3 < services.length) ? i + 3 : services.length;
      columns.add(services.sublist(i, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Services",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns.map((colItems) {
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: colItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Text(
                          "-  ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF04B461),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 🔹 GALLERY TAB CONTENT
  Widget _buildGalleryContent(WorkerDetail workerdata) {
    final images = workerdata.previousworkimages.isNotEmpty
        ? workerdata.previousworkimages
        : (workerdata.heroimage.isNotEmpty
            ? [workerdata.heroimage]
            : (workerdata.defaultprevious.isNotEmpty
                ? [workerdata.defaultprevious]
                : <String>[]));

    if (images.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            "No gallery images available.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gallery",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(
                images[index],
                fit: BoxFit.cover,
                fallbackSex: workerdata.sex,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 🔹 REVIEWS TAB CONTENT
  Widget _buildReviewsContent(WorkerDetail workerdata) {
    if (workerdata.reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            "No reviews yet.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reviews (${workerdata.reviews.length})",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workerdata.reviews.length,
          itemBuilder: (_, i) {
            final review = workerdata.reviews[i];
            return _reviewCard(review);
          },
        ),
      ],
    );
  }
}

Widget _circleIcon(IconData icon, VoidCallback onTap, {Color color = Colors.black}) {
  return GestureDetector(
    onTap: onTap,
    child: CircleAvatar(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      child: Icon(icon, color: color),
    ),
  );
}

Widget _reviewCard(Review review) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade100, width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...List.generate(
              review.rating.toInt(),
              (_) => const Icon(Icons.star, size: 14, color: Colors.amber),
            ),
            const SizedBox(width: 4),
            Text(
              review.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          review.comment,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage("assets/images/avatar.png"),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.reviewer,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "Satisfied Customer • ${review.date}",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
