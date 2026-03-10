import 'package:flutter/material.dart';
import 'package:life_tracker/theme/app_theme.dart';
import 'package:life_tracker/models/record.dart';

class CourageDialog extends StatefulWidget {
  final CourageType courageType;
  final void Function(Record) onSubmit;

  const CourageDialog({super.key, required this.courageType, required this.onSubmit});

  static Future<void> show(BuildContext context, CourageType courageType, void Function(Record) onSubmit) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => CourageDialog(courageType: courageType, onSubmit: onSubmit),
    );
  }

  @override
  State<CourageDialog> createState() => _CourageDialogState();
}

class _CourageDialogState extends State<CourageDialog> {
  final _descController = TextEditingController();

  @override
  void dispose() { _descController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ct = widget.courageType;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.cardBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('${ct.emoji} ${ct.label}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),
            Text('发生了什么？*', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: '描述一下这件事...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder, width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: AppTheme.darkGreen, blurRadius: 0, offset: Offset(0, 4))]),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  onPressed: _submit,
                  child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写发生了什么')));
      return;
    }
    widget.onSubmit(Record(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: RecordType.courage,
      origin: RecordOrigin.spontaneous,
      data: {'courageType': widget.courageType, 'description': desc},
    ));
    Navigator.of(context).pop();
  }
}
