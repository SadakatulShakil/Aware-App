import 'package:get/get.dart';

import '../../../../core/services/user_pref_service.dart';
import '../../data/models/upazila_list_model.dart';
import '../../data/repositories/location_repository.dart';

class LocationPickController extends GetxController {
  final LocationRepository _repository = Get.find<LocationRepository>();
  final UserPrefService userService = Get.find<UserPrefService>();

  final upazilas = <UpazilaData>[].obs;
  final filteredUpazilas = <UpazilaData>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUpazilas();
  }

  Future<void> loadUpazilas() async {
    isLoading.value = true;
    try {
      final list = await _repository.getUpazilas();
      upazilas.value = list;
      filteredUpazilas.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      filteredUpazilas.value = upazilas;
      return;
    }
    final q = query.toLowerCase();
    filteredUpazilas.value = upazilas.where((item) {
      final name = (item.name ?? '').toLowerCase();
      final nameBn = (item.nameBn ?? '').toLowerCase();
      final district = (item.district ?? '').toLowerCase();
      final districtBn = (item.districtBn ?? '').toLowerCase();
      return name.contains(q) ||
          nameBn.contains(q) ||
          district.contains(q) ||
          districtBn.contains(q);
    }).toList();
  }
}
