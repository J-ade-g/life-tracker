import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Multiple URLs to try for update check (fallback chain for China access)
const List<String> _kUpdateUrls = [
  // Raw GitHub (sometimes works in China)
  'https://raw.githubusercontent.com/J-ade-g/life-tracker/main/update.json',
  // GitHub CDN mirrors that may work in China
  'https://raw.gitmirror.com/J-ade-g/life-tracker/main/update.json',
  'https://ghp.ci/https://raw.githubusercontent.com/J-ade-g/life-tracker/main/update.json',
  // Original GitHub API as last resort
  'https://api.github.com/repos/J-ade-g/life-tracker/releases/latest',
];

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
  /// Tries multiple mirror URLs for China compatibility.
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Try each URL until one works
      for (final url in _kUpdateUrls) {
        try {
          final info = url.contains('api.github.com')
              ? await _checkGithubApi(url, currentVersion)
              : await _checkUpdateJson(url, currentVersion);
          if (info != null) return info;
          // If info is null but request succeeded, version is current
          return null;
        } catch (_) {
          continue; // Try next mirror
        }
      }
      return null;
    } catch (e) {
      debugPrint('Update check error: $e');
      return null;
    }
  }

  /// Check update from our simple update.json file
  static Future<UpdateInfo?> _checkUpdateJson(
    String url,
    String currentVersion,
  ) async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

    final data = json.decode(response.body) as Map<String, dynamic>;
    final version = data['version'] as String;

    if (!_isNewer(version, currentVersion)) return null;

    return UpdateInfo(
      tagName: data['tag'] as String? ?? 'v$version',
      version: version,
      apkDownloadUrl: data['apk_url'] as String,
    );
  }

  /// Check update from GitHub API (original method)
  static Future<UpdateInfo?> _checkGithubApi(
    String url,
    String currentVersion,
  ) async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

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
    if (apkUrl == null) throw Exception('No APK asset');

    return UpdateInfo(
      tagName: tagName,
      version: version,
      apkDownloadUrl: apkUrl,
    );
  }

  /// Downloads the APK and launches the system installer.
  /// Also tries mirror URLs for download if direct fails.
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
