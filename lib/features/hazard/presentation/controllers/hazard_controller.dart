import 'package:get/get.dart';

import '../../../../core/utils/app_logger.dart';
import '../../data/models/hazard_entity.dart';
import '../../data/repositories/hazard_repository.dart';

class HazardController extends GetxController {
  final HazardRepository _repo;

  HazardController(this._repo);

  final RxList<HazardEntity> hazards = <HazardEntity>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      hazards.assignAll(await _repo.getHazards());
    } catch (e) {
      AppLogger.e('Hazard load failed', e);
    } finally {
      isLoading.value = false;
    }
  }
}
