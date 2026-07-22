import 'package:get/get.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../hazard/data/repositories/hazard_repository.dart';
import '../../../hazard/presentation/controllers/hazard_controller.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../../home/data/repositories/location_repository.dart';
import '../../../home/data/repositories/weather_local_repository.dart';
import '../../../home/data/repositories/weather_repository.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../services/data/repositories/service_repository.dart';
import '../../../services/presentation/controllers/service_controller.dart';
import '../controllers/main_nav_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavController>(() => MainNavController(), fenix: true);

    // Repositories
    Get.lazyPut<HomeRepository>(
        () => HomeRepository(Get.find<ApiClient>()),
        fenix: true);
    Get.lazyPut<HazardRepository>(
        () => HazardRepository(
            Get.isRegistered<AppDatabase>() ? Get.find<AppDatabase>() : null,
            Get.find<ApiClient>()),
        fenix: true);
    Get.lazyPut<WeatherRepository>(
        () => WeatherRepository(Get.find<ApiClient>()),
        fenix: true);
    Get.lazyPut<WeatherLocalRepository>(
        () => WeatherLocalRepository(Get.isRegistered<AppDatabase>()
            ? Get.find<AppDatabase>()
            : null),
        fenix: true);
    Get.lazyPut<LocationRepository>(() => LocationRepository(), fenix: true);
    Get.lazyPut<ServiceRepository>(
        () => ServiceRepository(
            Get.isRegistered<AppDatabase>() ? Get.find<AppDatabase>() : null,
            Get.find<ApiClient>()),
        fenix: true);

    // Tab controllers
    Get.lazyPut<HomeController>(
        () => HomeController(
              Get.find<HomeRepository>(),
              Get.find<HazardRepository>(),
              Get.find<WeatherRepository>(),
              Get.find<WeatherLocalRepository>(),
            ),
        fenix: true);
    Get.lazyPut<HazardController>(
        () => HazardController(Get.find<HazardRepository>()),
        fenix: true);
    Get.lazyPut<ServiceController>(
        () => ServiceController(Get.find<ServiceRepository>()),
        fenix: true);
  }
}
