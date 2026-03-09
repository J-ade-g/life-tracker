import 'package:flutter/material.dart';

import '../services/update_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _checking = false;

  Future<void> _checkForUpdates() async {
    setState(() => _checking = true);
    final info = await UpdateService.checkForUpdate();
    if (!mounted) return;
    setState(() => _checking = false);

    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已是最新版本 v$kCurrentVersion')),
      );
      return;
    }

    showUpdateDialog(context, info);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          ListTile(
            leading: const Icon(Icons.system_update_outlined),
            title: const Text('检查更新'),
            subtitle: const Text('当前版本 v$kCurrentVersion'),
            trailing: _checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _checking ? null : _checkForUpdates,
          ),
        ],
      ),
    );
  }
}

/// Shows the update dialog. Can be called from anywhere with a [BuildContext].
void showUpdateDialog(BuildContext context, UpdateInfo info) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateDialog(info: info),
  );
}

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo info;

  const _UpdateDialog({required this.info});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _downloading = false;
  double _progress = 0;

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _progress = 0;
    });
    try {
      await UpdateService.downloadAndInstall(
        widget.info.apkDownloadUrl,
        (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('发现新版本 ${widget.info.tagName}'),
      content: _downloading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                const SizedBox(height: 8),
                Text(
                  _progress > 0
                      ? '下载中 ${(_progress * 100).toStringAsFixed(0)}%'
                      : '准备下载...',
                ),
              ],
            )
          : Text('有新版本 v${widget.info.version}，是否更新？'),
      actions: _downloading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: _startDownload,
                child: const Text('立即更新'),
              ),
            ],
    );
  }
}
