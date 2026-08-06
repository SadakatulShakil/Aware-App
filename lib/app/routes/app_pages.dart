import 'package:get/get.dart';

import '../../features/drawer/presentation/pages/about_page.dart';
import '../../features/incident_report/data/models/incident_report_model.dart';
import '../../features/incident_report/pages/add_incident_report_page.dart';
import '../../features/drawer/presentation/pages/contact_us_page.dart';
import '../../features/drawer/presentation/pages/feedback_page.dart';
import '../../features/incident_report/pages/incident_report_details_page.dart';
import '../../features/incident_report/pages/incident_report_page.dart';
import '../../features/incident_report/pages/incident_report_success_page.dart';
import '../../features/incident_report/pages/my_incident_posts_page.dart';
import '../../features/drawer/presentation/pages/privacy_policy_page.dart';
import '../../features/drawer/presentation/pages/risk_information_page.dart';
import '../../features/emergency/presentation/pages/emergency_page.dart';
import '../../features/hazard/presentation/pages/hazard_webview_page.dart';
import '../../features/home/presentation/pages/notification_page.dart';
import '../../features/main_nav/presentation/bindings/main_nav_binding.dart';
import '../../features/main_nav/presentation/pages/main_nav_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/splash/presentation/bindings/splash_binding.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavPage(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: AppRoutes.emergency,
      page: () => const EmergencyPage(),
    ),
    GetPage(
      name: AppRoutes.hazardDetails,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return HazardWebViewPage(
          title: args['title'] as String? ?? '',
          url: args['url'] as String? ?? '',
        );
      },
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsPage(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationPage(),
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutPage(),
    ),
    GetPage(
      name: AppRoutes.riskInformation,
      page: () => const RiskInformationPage(),
    ),
    GetPage(
      name: AppRoutes.addIncidentReport,
      page: () => const AddIncidentReportPage(),
    ),
    GetPage(
      name: AppRoutes.incidentReport,
      page: () => const IncidentReportPage(),
    ),
    GetPage(
      name: AppRoutes.incidentReportDetails,
      page: () => IncidentReportDetailsPage(
        incident: Get.arguments as IncidentReportModel,
      ),
    ),
    GetPage(
      name: AppRoutes.incidentReportSuccess,
      page: () => IncidentReportSuccessPage(
        report: Get.arguments as IncidentReportModel,
      ),
    ),
    GetPage(
      name: AppRoutes.myIncidentPosts,
      page: () => MyIncidentPostsPage(
        mobile: Get.arguments as String,
      ),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
    ),
    GetPage(
      name: AppRoutes.contactUs,
      page: () => const ContactUsPage(),
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackPage(),
    ),
  ];
}
