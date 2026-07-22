import 'package:get/get.dart';

import '../../../../core/utils/app_logger.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';

class ServiceController extends GetxController {
  final ServiceRepository _repo;

  ServiceController(this._repo);

  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      services.assignAll(await _repo.getServices());
    } catch (e) {
      AppLogger.e('Service load failed', e);
    } finally {
      isLoading.value = false;
    }
  }
}
