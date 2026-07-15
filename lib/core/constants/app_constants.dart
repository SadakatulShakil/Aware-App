class AppConstants {
  AppConstants._();

  static const appName = 'AWARE';
  static const appFullName =
      'Advanced Warning & Analytics for Risk & Emergencies';
  static const orgName = 'Department of Disaster Management (DDM), MoDMR';

  // Emergency hotlines (source: rapid.ddm.gov.bd)
  static const hotlines = <Map<String, String>>[
    {'title': 'National Emergency', 'titleBn': 'জাতীয় জরুরি সেবা', 'number': '999'},
    {'title': 'Disaster Helpline', 'titleBn': 'দুর্যোগ হেল্পলাইন', 'number': '1090'},
    {'title': 'Fire Service', 'titleBn': 'ফায়ার সার্ভিস', 'number': '16163'},
    {'title': 'Medical Emergency', 'titleBn': 'স্বাস্থ্য বাতায়ন', 'number': '16263'},
    {'title': 'DDM Office', 'titleBn': 'ডিডিএম অফিস', 'number': '+8809611677777'},
  ];


  static const logoPath = 'assets/images/ddm_logo.png';
}
