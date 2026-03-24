import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_tracker/theme/app_theme.dart';
import 'package:life_tracker/models/record.dart';

/// Auto-formats time input: user types "1430" → becomes "14:30"
class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Strip non-digits
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length > 4) return oldValue;

    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buf.write(':');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

  // Date + time as text controllers
  late final TextEditingController _startDateCtrl;
  late final TextEditingController _startTimeCtrl;
  late final TextEditingController _endDateCtrl;
  late final TextEditingController _endTimeCtrl;

  final Set<GoalCategory> _selectedCategories = {};
  final Set<Principle> _selectedPrinciples = {};
  bool _showOptional = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    _startDateCtrl = TextEditingController(text: _fmtDate(oneHourAgo));
    _startTimeCtrl = TextEditingController(text: _fmtTime(oneHourAgo));
    _endDateCtrl = TextEditingController(text: _fmtDate(now));
    _endTimeCtrl = TextEditingController(text: _fmtTime(now));
  }

  @override
  void dispose() {
    _whatController.dispose();
    _optimizationController.dispose();
    _startDateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endDateCtrl.dispose();
    _endTimeCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime dt) => '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  String _fmtTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  DateTime? _parseDateTime(String date, String time) {
    try {
      final now = DateTime.now();
      final parts = date.split('-');
      final timeParts = time.split(':');
      if (parts.length != 2 || timeParts.length != 2) return null;
      return DateTime(now.year, int.parse(parts[0]), int.parse(parts[1]), int.parse(timeParts[0]), int.parse(timeParts[1]));
    } catch (_) {
      return null;
    }
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppTheme.textSecondary),
    filled: true,
    fillColor: AppTheme.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder, width: 2)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
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
            Text('📝 即时复盘', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),

            Text('做了什么？*', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _whatController,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: _inputDeco('描述你做了什么...'),
            ),
            const SizedBox(height: 20),

            Text('时间段 *', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: _startDateCtrl, style: const TextStyle(color: AppTheme.textPrimary), decoration: _inputDeco('MM-DD'), textAlign: TextAlign.center)),
                const SizedBox(width: 6),
                Expanded(child: TextField(controller: _startTimeCtrl, style: const TextStyle(color: AppTheme.textPrimary), decoration: _inputDeco('HH:MM'), textAlign: TextAlign.center, keyboardType: TextInputType.number, inputFormatters: [TimeTextInputFormatter()])),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('~', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16))),
                Expanded(child: TextField(controller: _endDateCtrl, style: const TextStyle(color: AppTheme.textPrimary), decoration: _inputDeco('MM-DD'), textAlign: TextAlign.center)),
                const SizedBox(width: 6),
                Expanded(child: TextField(controller: _endTimeCtrl, style: const TextStyle(color: AppTheme.textPrimary), decoration: _inputDeco('HH:MM'), textAlign: TextAlign.center, keyboardType: TextInputType.number, inputFormatters: [TimeTextInputFormatter()])),
              ],
            ),
            const SizedBox(height: 20),

            Text('目标分类 *（至少选一个）', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GoalCategory.values.map((cat) {
                final selected = _selectedCategories.contains(cat);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) _selectedCategories.remove(cat); else _selectedCategories.add(cat);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.emeraldGreen.withValues(alpha: 0.12) : AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppTheme.emeraldGreen : AppTheme.cardBorder, width: 2),
                    ),
                    child: Text('${cat.emoji} ${cat.label}', style: TextStyle(color: selected ? AppTheme.emeraldGreen : AppTheme.textSecondary, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => setState(() => _showOptional = !_showOptional),
              child: Row(
                children: [
                  Icon(_showOptional ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('可选：原则 & 优化方向', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),

            if (_showOptional) ...[
              const SizedBox(height: 12),
              Text('原则', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Principle.values.map((p) {
                  final selected = _selectedPrinciples.contains(p);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) _selectedPrinciples.remove(p); else _selectedPrinciples.add(p);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.plannedColor.withValues(alpha: 0.12) : AppTheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? AppTheme.plannedColor : AppTheme.cardBorder, width: 2),
                      ),
                      child: Text(p.label, style: TextStyle(color: selected ? AppTheme.plannedColor : AppTheme.textSecondary, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('优化方向', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _optimizationController,
                maxLines: 2,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: _inputDeco('下次可以怎么改进...'),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [const BoxShadow(color: AppTheme.darkGreen, blurRadius: 0, offset: Offset(0, 4))],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  onPressed: _submit,
                  child: const Text('提交复盘', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final what = _whatController.text.trim();
    if (what.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写做了什么')));
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择至少一个目标分类')));
      return;
    }
    final startDt = _parseDateTime(_startDateCtrl.text, _startTimeCtrl.text);
    final endDt = _parseDateTime(_endDateCtrl.text, _endTimeCtrl.text);
    if (startDt == null || endDt == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('时间格式不对，请用 MM-DD 和 HH:MM')));
      return;
    }

    widget.onSubmit(Record(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: RecordType.review,
      origin: RecordOrigin.spontaneous,
      data: {
        'what': what,
        'startTime': startDt,
        'endTime': endDt,
        'categories': _selectedCategories.toList(),
        'principles': _selectedPrinciples.toList(),
        'optimization': _optimizationController.text.trim(),
      },
    ));
    Navigator.of(context).pop();
  }
}
