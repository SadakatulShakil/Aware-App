import 'dart:convert';

import 'package:http/http.dart' as http;

const _url = 'https://rapid.ddm.gov.bd/api/hazard/list';

class ProbeResult {
  final String name;
  final Map<String, String> headersSent;
  final String? firstTitle;
  final String? error;

  ProbeResult(this.name, this.headersSent, {this.firstTitle, this.error});

  String get verdict {
    if (error != null) return 'ERROR';
    if (firstTitle == null) return 'NO DATA';
    // Bangla hazard titles are non-ASCII; English ones are plain ASCII.
    final isAscii = firstTitle!.codeUnits.every((c) => c < 128);
    return isAscii ? 'EN' : 'BN';
  }
}

Future<ProbeResult> runProbe(String name, Map<String, String> headers) async {
  try {
    final res = await http.get(Uri.parse(_url), headers: headers);
    if (res.statusCode != 200) {
      return ProbeResult(name, headers, error: 'HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }
    // http package auto-decodes gzip/deflate; body is already text here.
    // MUST jsonDecode (not regex the raw text) - otherwise a Bangla title's
    // JSON-escaped form (literal characters \, u, 0, 9, 9, 8...) reads as
    // plain ASCII and gets misclassified as English.
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final result = json['result'] as List;
    final title = result.isNotEmpty ? (result.first['title'] as String? ?? '(null title)') : '(empty result)';
    return ProbeResult(name, headers, firstTitle: title);
  } catch (e) {
    return ProbeResult(name, headers, error: e.toString());
  }
}

void printProbe(ProbeResult r) {
  print('--- ${r.name} ---');
  print('Headers sent: ${r.headersSent}');
  if (r.error != null) {
    print('ERROR: ${r.error}');
  } else {
    print('First title: ${r.firstTitle}   => ${r.verdict}');
  }
  print('');
}

void main() async {
  final results = <ProbeResult>[];

  // ── PROBE 1: baseline reproduction ──
  final p1en = await runProbe('Probe 1a: baseline, Accept-Language=en', {
    'Accept-Language': 'en',
  });
  printProbe(p1en);
  results.add(p1en);

  final p1bn = await runProbe('Probe 1b: baseline, Accept-Language=bn', {
    'Accept-Language': 'bn',
  });
  printProbe(p1bn);
  results.add(p1bn);

  // ── PROBE 2: User-Agent test ──
  final p2chrome = await runProbe('Probe 2a: Accept-Language=en + Chrome UA', {
    'Accept-Language': 'en',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36',
  });
  printProbe(p2chrome);
  results.add(p2chrome);

  final p2postman = await runProbe('Probe 2b: Accept-Language=en + PostmanRuntime UA', {
    'Accept-Language': 'en',
    'User-Agent': 'PostmanRuntime/7.54.0',
  });
  printProbe(p2postman);
  results.add(p2postman);

  // ── PROBE 3: full header parity with Postman ──
  // NOTE: 'br' (Brotli) dropped from Accept-Encoding - package:http's
  // built-in decoder only auto-handles gzip/deflate, so leaving br in can
  // produce garbled/undecoded output that isn't a language signal at all.
  final p3 = await runProbe('Probe 3: full Postman header parity (br dropped, see note)', {
    'Accept-Language': 'en',
    'User-Agent': 'PostmanRuntime/7.54.0',
    'Accept': '*/*',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
    'Host': 'rapid.ddm.gov.bd',
  });
  printProbe(p3);
  results.add(p3);

  // ── PROBE 4: summary table + raw headers actually sent on Probe 1 ──
  print('=== SUMMARY ===');
  for (final r in results) {
    print('${r.verdict.padRight(8)} <- ${r.name}');
  }
  print('');
  print('=== Probe 1a headers as constructed by this script ===');
  print(p1en.headersSent);
  print('(package:http / dart:io will additionally auto-attach its own '
      'default headers not listed here - e.g. Host, Accept-Encoding, and '
      'potentially its own User-Agent like "Dart/<version> (dart:io)" if '
      'not overridden above.)');
}
