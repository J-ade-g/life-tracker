import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

const String _kGithubApiUrl =
    'https://api.github.com/repos/J-ade-g/life-tracker/releases/latest';

class UpdateInfo {
  final String tagName;
  final String version;
  final String apkDownloadUrl;

  const UpdateInfo({
    required this.tagName,
    required this.version,
    required this.apkDownloadUrl,
  });
}

class UpdateService {
  /// Returns [UpdateInfo] if a newer version is available, otherwise null.
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http
          .get(Uri.parse(_kGithubApiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String;
      final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      if (!_isNewer(version, currentVersion)) return null;

      final assets = (data['assets'] as List).cast<Map<String, dynamic>>();
      String? apkUrl;
      for (final asset in assets) {
        if ((asset['name'] as String).endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String;
          break;
        }
      }
      if (apkUrl == null) return null;

      return UpdateInfo(
        tagName: tagName,
        version: version,
        apkDownloadUrl: apkUrl,
      );
    } catch (e) {
      debugPrint('Update check error: $e');
      return null;
    }
  }

  /// Downloads the APK and launches the system installer.
  /// [onProgress] receives a value between 0.0 and 1.0.
  static Future<void> downloadAndInstall(
    String url,
    void Function(double progress) onProgress,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/app_update.apk');

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await client.send(request);
      final total = streamedResponse.contentLength ?? 0;
      int received = 0;

      final sink = file.openWrite();
      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress(received / total);
      }
      await sink.close();
    } finally {
      client.close();
    }

    await OpenFile.open(file.path);
  }

  /// Returns true if [latest] is a higher semver than [current].
  static bool _isNewer(String latest, String current) {
    List<int> parse(String v) =>
        v.split('.').map((s) => int.tryParse(s) ?? 0).toList();

    final l = parse(latest);
    final c = parse(current);
    final len = l.length > c.length ? l.length : c.length;
    for (int i = 0; i < len; i++) {
      final lv = i < l.length ? l[i] : 0;
      final cv = i < c.length ? c[i] : 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }
}
