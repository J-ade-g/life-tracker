import 'package:flutter/material.dart';
import 'package:life_tracker/models/record.dart';

class ReviewDialog extends StatefulWidget {
  final void Function(Record) onSubmit;

  const ReviewDialog({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context,
    void Function(Record) onSubmit,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReviewDialog(onSubmit: onSubmit),
    );
  }

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _whatController = TextEditingController();
  final _optimizationController = TextEditingController();

  DateTime _startTime = DateTime.now().subtract(const Duration(hours: 1));
  DateTime _endTime = DateTime.now();

  final Set<GoalCategory> _selectedCategories = {};
  final Set<Principle> _selectedPrinciples = {};
  bool _showOptional = false;

  @override
  void dispose() {
    _whatController.dispose();
    _optimizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              '即时复盘',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 做了什么
            Text('做了什么？*',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _whatController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '描述你做了什么...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 时间段
            Text('时间段 *', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text(_fmtTime(_startTime)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('~'),
                ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text(_fmtTime(_endTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 目标分类
            Text('目标分类 *（至少选一个）',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GoalCategory.values.map((cat) {
                final selected = _selectedCategories.contains(cat);
                return FilterChip(
                  label: Text('${cat.emoji} ${cat.label}'),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedCategories.add(cat);
                      } else {
                        _selectedCategories.remove(cat);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 可选内容折叠
            GestureDetector(
              onTap: () => setState(() => _showOptional = !_showOptional),
              child: Row(
                children: [
                  Icon(
                    _showOptional
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '可选：原则 & 优化方向',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),

            if (_showOptional) ...[
              const SizedBox(height: 12),
              Text('原则', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Principle.values.map((p) {
                  final selected = _selectedPrinciples.contains(p);
                  return FilterChip(
                    label: Text(p.label),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedPrinciples.add(p);
                        } else {
                          _selectedPrinciples.remove(p);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('优化方向', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _optimizationController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: '下次可以怎么改进...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('提交复盘'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted || picked == null) return;
    final now = DateTime.now();
    final dt =
        DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    setState(() {
      if (isStart) {
        _startTime = dt;
      } else {
        _endTime = dt;
      }
    });
  }

  void _submit() {
    final what = _whatController.text.trim();
    if (what.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写做了什么')),
      );
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择至少一个目标分类')),
      );
      return;
    }

    widget.onSubmit(Record(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: RecordType.review,
      origin: RecordOrigin.spontaneous,
      data: {
        'what': what,
        'startTime': _startTime,
        'endTime': _endTime,
        'categories': _selectedCategories.toList(),
        'principles': _selectedPrinciples.toList(),
        'optimization': _optimizationController.text.trim(),
      },
    ));

    Navigator.of(context).pop();
  }
}
