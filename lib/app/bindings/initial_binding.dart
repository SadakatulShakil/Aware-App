import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/services/connectivity_service.dart';

/// Only ultra-light dependencies here. Everything heavy (prefs, Floor DB,
/// Firebase, location) is initialized in SplashController after first frame.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<ConnectivityService>(() => ConnectivityService()..init(),
        fenix: true);
  }
}
