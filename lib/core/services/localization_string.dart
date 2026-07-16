import 'package:get/get.dart';

/// GetX translations - ported pattern from BMD's LocalizationString.
/// Keys are used as `'key'.tr` and switch automatically on Get.updateLocale().
class LocalizationString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          // Location permission dialogs
          'loc_permission_title': 'Location Permission',
          'loc_permission_body':
              'We need your location to show accurate local weather forecasts for your area. Please allow location access.',
          'not_now': 'Not Now',
          'allow': 'Allow',
          'location_disabled_title': 'Location Disabled',
          'location_disabled_body':
              'Your device location service is turned off. Please enable location to get accurate weather for your area.',
          'later': 'Later',
          'open_settings': 'Open Settings',
          'permission_denied_title': 'Permission Denied',
          'permission_denied_body':
              'Location permission has been permanently denied. Please go to app settings and enable location permission.',
          'app_settings': 'App Settings',

          // Location selection page
          'location_not_found_title': 'Location not found',
          'location_not_found_body':
              "To see your area's weather, please select your Upazila or District from the list.",
          'ok': 'OK',
          'select_location_title': 'Select Location',
          'no_results_found': 'No results found',
          'search_upazila_hint': 'Search upazila or district...',

          // Location picker bottom sheet
          'location_list_title': 'Location list',
          'no_data': 'No data',
          'add_location': 'Add Location',
          'rename_location': 'Rename location',
          'cancel': 'Cancel',
          'save': 'Save',
          'edit': 'Edit',
          'delete': 'Delete',

          // Weather header
          'feels_like_label': 'Feels like',
          'temp_unit_full': '°C',
          'temp_unit_short': 'C',
          'banner_allow_location': 'Allow location to see weather for your area',
          'banner_turn_on_location': 'Turn on location for accurate local weather',
          'enable': 'Enable',
          'no_data_available': 'No Data Available',
          'check_internet_connection':
              'Please check your internet connection to load data',
          'resolving_location': 'Finding your location...',
          'loading_weather': 'Loading weather...',
          'retry': 'Retry',
          'switching_location': 'Switching location...',
          'incident_report': 'Incident Report',
          'incident_report_coming_soon': 'Coming soon',

          // Notification settings page
          'notification_settings': 'Notification Settings',
          'notification_settings_subtitle': 'Manage your notification preferences',
          'alert_notifications': 'Alert Notifications',
          'alert_notifications_desc': 'Severe weather & disaster alerts',
          'general_notifications': 'General Notifications',
          'general_notifications_desc': 'Updates and general information',
          'vibration': 'Vibration',
          'vibration_locked_desc': 'Always vibrates - cannot be disabled',
          'vibration_general_desc': 'Enable vibration for general notifications',
          'locked': 'Locked',
          'ringtone': 'Ringtone',
          'ringtone_alert_tone': 'Alert Tone',
          'ringtone_system_default': 'System Default',
          'full_screen_alert': 'Full Screen Alert',
          'full_screen_alert_desc': 'Show alert in full screen on lock screen',
          'emergency_bypass': 'Emergency Sound Bypass',
          'emergency_bypass_desc': 'Alert sounds even in silent/vibrate mode',
          'emergency_bypass_on_info':
              'Emergency bypass ON - alerts sound even in silent or vibrate mode.',
          'emergency_bypass_off_info':
              'Emergency bypass OFF - follows the phone\'s ring/silent setting.',
          'test': 'Test',
          'test_alert': 'Test Alert',
          'test_general': 'Test General',
          'test_alert_title': 'Test Alert',
          'test_alert_body': 'Heavy rain expected in your area',
          'test_general_title': 'Test Notification',
          'test_general_body': 'Partly cloudy weather tomorrow',
          'test_alert_sent': 'Alert notification sent',
          'test_general_sent': 'General notification sent',

          // Bottom nav
          'nav_home': 'Home',
          'nav_hazard': 'Hazard',
          'nav_services': 'Services',
          'nav_settings': 'Settings',

          // Notification page
          'notifications': 'Notifications',
          'no_notifications': 'No notifications',
          'failed_to_load': 'Failed to load data',
          'no_title': 'No Title',
          'alert': 'Alert',
        },
        'bn': {
          'loc_permission_title': 'অবস্থান অনুমতি',
          'loc_permission_body':
              'আপনার সঠিক আবহাওয়ার তথ্য পেতে আমাদের আপনার বর্তমান অবস্থান জানা দরকার। অনুগ্রহ করে অবস্থান অনুমতি প্রদান করুন।',
          'not_now': 'এখন না',
          'allow': 'অনুমতি দিন',
          'location_disabled_title': 'লোকেশন বন্ধ',
          'location_disabled_body':
              'আপনার ডিভাইসের লোকেশন সার্ভিস বন্ধ আছে। সঠিক আবহাওয়া দেখতে লোকেশন চালু করুন।',
          'later': 'পরে করব',
          'open_settings': 'সেটিংস খুলুন',
          'permission_denied_title': 'অনুমতি প্রত্যাখ্যাত',
          'permission_denied_body':
              'লোকেশন অনুমতি স্থায়ীভাবে বন্ধ করা হয়েছে। সেটিংসে গিয়ে অবস্থান অনুমতি চালু করুন।',
          'app_settings': 'অ্যাপ সেটিংস',

          'location_not_found_title': 'লোকেশন পাওয়া যায়নি',
          'location_not_found_body':
              'আপনার এলাকার আবহাওয়া দেখার জন্য দয়া করে তালিকা থেকে আপনার উপজেলা বা জেলাটি খুঁজে নিন।',
          'ok': 'ঠিক আছে',
          'select_location_title': 'লোকেশন নির্বাচন করুন',
          'no_results_found': 'কোন ফলাফল পাওয়া যায়নি',
          'search_upazila_hint': 'উপজেলা বা জেলা খুঁজুন...',

          'location_list_title': 'অবস্থানের তালিকা',
          'no_data': 'কোনো তথ্য নেই',
          'add_location': 'লোকেশন যোগ করুন',
          'rename_location': 'নাম পরিবর্তন করুন',
          'cancel': 'বাতিল',
          'save': 'সংরক্ষণ',
          'edit': 'সম্পাদনা',
          'delete': 'মুছুন',

          'feels_like_label': 'অনুভূত হচ্ছে',
          'temp_unit_full': '°সে',
          'temp_unit_short': 'সে',
          'banner_allow_location': 'সঠিক আবহাওয়া দেখতে অবস্থান অনুমতি দিন',
          'banner_turn_on_location': 'সঠিক আবহাওয়া দেখতে লোকেশন চালু করুন',
          'enable': 'চালু করুন',
          'no_data_available': 'কোন তথ্য পাওয়া যায়নি',
          'check_internet_connection': 'অনুগ্রহ করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন',
          'resolving_location': 'আপনার অবস্থান খুঁজে বের করা হচ্ছে...',
          'loading_weather': 'আবহাওয়া লোড হচ্ছে...',
          'retry': 'পুনরায় চেষ্টা করুন',
          'switching_location': 'লোকেশন পরিবর্তন হচ্ছে...',
          'incident_report': 'ঘটনা রিপোর্ট',
          'incident_report_coming_soon': 'শীঘ্রই আসছে',

          'notification_settings': 'নোটিফিকেশন সেটিংস',
          'notification_settings_subtitle': 'আপনার নোটিফিকেশন পছন্দ পরিচালনা করুন',
          'alert_notifications': 'সতর্কতা নোটিফিকেশন',
          'alert_notifications_desc': 'তীব্র আবহাওয়া ও দুর্যোগ সতর্কবার্তা',
          'general_notifications': 'সাধারণ নোটিফিকেশন',
          'general_notifications_desc': 'আপডেট ও সাধারণ তথ্য',
          'vibration': 'কম্পন',
          'vibration_locked_desc': 'সর্বদা কম্পিত হবে - বন্ধ করা যাবে না',
          'vibration_general_desc': 'সাধারণ নোটিফিকেশনে কম্পন চালু করুন',
          'locked': 'লক',
          'ringtone': 'রিংটোন',
          'ringtone_alert_tone': 'অ্যালার্ট টোন',
          'ringtone_system_default': 'সিস্টেম ডিফল্ট',
          'full_screen_alert': 'ফুল স্ক্রিন সতর্কতা',
          'full_screen_alert_desc': 'লক স্ক্রিনে সতর্কতা পূর্ণ পর্দায় দেখাবে',
          'emergency_bypass': 'জরুরি সাউন্ড বাইপাস',
          'emergency_bypass_desc': 'সাইলেন্ট/ভাইব্রেট মোডেও সতর্কতা বাজবে',
          'emergency_bypass_on_info':
              'জরুরি বাইপাস চালু - সাইলেন্ট বা ভাইব্রেট মোডেও সতর্কতা বাজবে।',
          'emergency_bypass_off_info':
              'জরুরি বাইপাস বন্ধ - ফোনের রিং/সাইলেন্ট সেটিং মেনে চলবে।',
          'test': 'পরীক্ষা করুন',
          'test_alert': 'পরীক্ষামূলক সতর্কতা',
          'test_general': 'পরীক্ষামূলক সাধারণ',
          'test_alert_title': 'পরীক্ষামূলক সতর্কতা',
          'test_alert_body': 'আপনার এলাকায় ভারী বৃষ্টির সম্ভাবনা রয়েছে',
          'test_general_title': 'পরীক্ষামূলক বিজ্ঞপ্তি',
          'test_general_body': 'আগামীকাল আংশিক মেঘলা আবহাওয়া থাকবে',
          'test_alert_sent': 'সতর্কতা বিজ্ঞপ্তি পাঠানো হয়েছে',
          'test_general_sent': 'সাধারণ বিজ্ঞপ্তি পাঠানো হয়েছে',

          // Bottom nav
          'nav_home': 'হোম',
          'nav_hazard': 'দুর্যোগ',
          'nav_services': 'সেবা',
          'nav_settings': 'সেটিংস',

          // Notification page
          'notifications': 'নোটিফিকেশন',
          'no_notifications': 'কোনো নোটিফিকেশন নেই',
          'failed_to_load': 'তথ্য লোড করতে সমস্যা হয়েছে',
          'no_title': 'শিরোনাম নেই',
          'alert': 'সতর্কতা',
        },
      };
}
