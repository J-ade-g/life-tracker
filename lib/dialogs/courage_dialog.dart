import 'package:flutter/material.dart';
import 'package:life_tracker/models/record.dart';

class CourageDialog extends StatefulWidget {
  final CourageType courageType;
  final void Function(Record) onSubmit;

  const CourageDialog({
    super.key,
    required this.courageType,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context,
    CourageType courageType,
    void Function(Record) onSubmit,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CourageDialog(courageType: courageType, onSubmit: onSubmit),
    );
  }

  @override
  State<CourageDialog> createState() => _CourageDialogState();
}

class _CourageDialogState extends State<CourageDialog> {
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.courageType;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${ct.emoji} ${ct.label}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 描述
            Text('发生了什么？*', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '描述一下这件事...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('保存'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写发生了什么')),
      );
      return;
    }

    widget.onSubmit(Record(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: RecordType.courage,
      origin: RecordOrigin.spontaneous,
      data: {
        'courageType': widget.courageType,
        'description': desc,
      },
    ));

    Navigator.of(context).pop();
  }
}
