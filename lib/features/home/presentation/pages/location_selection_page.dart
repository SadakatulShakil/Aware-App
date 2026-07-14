import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/theme/app_fonts.dart';
import '../../data/models/upazila_list_model.dart';
import '../../data/repositories/location_repository.dart';
import '../controllers/location_pick_controller.dart';

/// Ported from BMD's SelectLocationPage - search upazila/district over
/// assets/json/location_list.json, pop the selected item via Get.back(result:).
class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  late final LocationPickController controller;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LocationRepository>()) {
      Get.put<LocationRepository>(LocationRepository());
    }
    controller = Get.put(LocationPickController());

    if (controller.userService.lat == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showExplainDialog());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<LocationPickController>();
    super.dispose();
  }

  void _showExplainDialog() {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/json/find_location.json'),
              const SizedBox(height: 12),
              Text(
                'location_not_found_title'.tr,
                style: AppFonts.style(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'location_not_found_body'.tr,
                textAlign: TextAlign.center,
                style: AppFonts.style(fontSize: 14),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Get.back(),
                  child: Text('ok'.tr, style: AppFonts.style(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = controller.userService.isBangla;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(8.w, 50.h, 16.w, 16.h),
              height: 150.h,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B8CBE), Color(0xFF09228F)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.w, top: 11.h, bottom: 12.h),
                      child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'select_location_title'.tr,
                      style: AppFonts.style(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 100.h,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  topLeft: Radius.circular(16.r),
                ),
                child: Container(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onChanged: controller.search,
                            style: AppFonts.style(fontSize: 16, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'search_upazila_hint'.tr,
                              hintStyle: AppFonts.style(fontSize: 16, color: Colors.grey),
                              suffixIcon: const Icon(Icons.search),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (controller.filteredUpazilas.isEmpty) {
                              return Center(
                                child: Text(
                                  'no_results_found'.tr,
                                  style: AppFonts.style(fontSize: 16, color: Colors.black54),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: EdgeInsets.only(top: 5.h),
                              itemCount: controller.filteredUpazilas.length,
                              itemBuilder: (context, index) {
                                final item = controller.filteredUpazilas[index];
                                return _tile(item, isBangla);
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _tile(UpazilaData item, bool isBangla) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        title: Text(
          isBangla ? (item.nameBn ?? '') : (item.name ?? ''),
          style: AppFonts.style(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
        ),
        subtitle: Text(
          isBangla ? (item.districtBn ?? '') : (item.district ?? ''),
          style: AppFonts.style(fontSize: 14, color: Colors.black54),
        ),
        trailing: SvgPicture.asset(
          'assets/svg/location_icon.svg',
          width: 16.w,
          height: 20.h,
          colorFilter: const ColorFilter.mode(Color(0xFF1B5E9E), BlendMode.srcIn),
        ),
        onTap: () => Get.back(result: item),
      ),
    );
  }
}
