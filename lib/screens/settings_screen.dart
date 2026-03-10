import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_tracker/theme/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/record.dart';
import '../providers/data_provider.dart';
import '../services/update_service.dart';

// ── Main settings screen ───────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _checking = false;
  late Future<PackageInfo> _packageInfoFuture;
  late TextEditingController _budgetController;
  bool _budgetSaved = false;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
    final dp = Provider.of<DataProvider>(context, listen: false);
    _budgetController = TextEditingController(
      text: dp.monthlyBudget.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    setState(() => _checking = true);
    final info = await UpdateService.checkForUpdate();
    if (!mounted) return;
    setState(() => _checking = false);
    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已是最新版本')),
      );
      return;
    }
    showUpdateDialog(context, info);
  }

  Future<void> _saveBudget() async {
    final value = double.tryParse(_budgetController.text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的预算金额')),
      );
      return;
    }
    await context.read<DataProvider>().setMonthlyBudget(value);
    if (!mounted) return;
    setState(() => _budgetSaved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _budgetSaved = false);
    });
  }

  Future<void> _exportData() async {
    final dp = context.read<DataProvider>();
    final json = dp.exportDataAsJson();
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final name =
        'life_tracker_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
    final file = File('${dir.path}/$name');
    await file.writeAsString(json);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已导出到:\n${file.path}'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _clearAllData() async {
    final dp = context.read<DataProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除所有数据'),
        content: const Text('此操作不可撤销，所有记录将被永久删除。确定继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await dp.clearAllData();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('所有数据已清除')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ── About ──────────────────────────────────────────────────────
          const _SectionHeader(title: '关于'),
          FutureBuilder<PackageInfo>(
            future: _packageInfoFuture,
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '未知';
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('当前版本'),
                trailing: Text(
                  'v$version',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.system_update_outlined),
            title: const Text('检查更新'),
            trailing: _checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _checking ? null : _checkForUpdates,
          ),

          const SizedBox(height: 20),

          // ── Budget ─────────────────────────────────────────────────────
          const _SectionHeader(title: '月度预算'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '设置本月支出上限',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _budgetController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            prefixText: '¥ ',
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) => _saveBudget(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _saveBudget,
                        child: Text(_budgetSaved ? '已保存 ✓' : '保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Data management ────────────────────────────────────────────
          const _SectionHeader(title: '数据管理'),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('导出数据'),
            subtitle: const Text('保存为 JSON 文件'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.redAccent,
            ),
            title: const Text(
              '清除所有数据',
              style: TextStyle(color: Colors.redAccent),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.redAccent,
            ),
            onTap: _clearAllData,
          ),


        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

// ── Update dialog (kept from original) ────────────────────────────────────────

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
                LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                ),
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
