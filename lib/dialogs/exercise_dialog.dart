import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_tracker/models/record.dart';
import 'package:life_tracker/theme/app_theme.dart';

class ExerciseDialog extends StatefulWidget {
  final void Function(Record) onSubmit;

  const ExerciseDialog({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context,
    void Function(Record) onSubmit,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ExerciseDialog(onSubmit: onSubmit),
    );
  }

  @override
  State<ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<ExerciseDialog> {
  final _typeController = TextEditingController();
  final _durationController = TextEditingController();
  int? _selectedDuration;

  static const _presets = [
    ('跑步', Icons.directions_run),
    ('散步', Icons.directions_walk),
    ('瑜伽', Icons.self_improvement),
    ('俯卧撑', Icons.fitness_center),
    ('深蹲', Icons.accessibility_new),
    ('拉伸', Icons.sports_gymnastics),
    ('游泳', Icons.pool),
    ('骑车', Icons.directions_bike),
    ('跳绳', Icons.sports),
  ];

  static const _durations = [15, 30, 45, 60];

  @override
  void dispose() {
    _typeController.dispose();
    _durationController.dispose();
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
              '运动',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Exercise presets grid
            Text('快速选择', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: _presets.map((preset) {
                final isSelected = _typeController.text == preset.$1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _typeController.text = preset.$1;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.emeraldGreen.withValues(alpha: 0.2)
                          : const Color(0xFF162030),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.emeraldGreen
                            : Colors.white12,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          preset.$2,
                          size: 16,
                          color: isSelected ? AppTheme.emeraldGreen : Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          preset.$1,
                          style: TextStyle(
                            color: isSelected ? AppTheme.emeraldGreen : Colors.white70,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom type input
            TextField(
              controller: _typeController,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '或自定义运动名称',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF162030),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Duration quick picks
            Text('时长', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
            const SizedBox(height: 12),
            Row(
              children: _durations.map((d) {
                final isSelected = _selectedDuration == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDuration = d;
                        _durationController.text = d.toString();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.emeraldGreen.withValues(alpha: 0.2)
                            : const Color(0xFF162030),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.emeraldGreen : Colors.white12,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        '${d}min',
                        style: TextStyle(
                          color: isSelected ? AppTheme.emeraldGreen : Colors.white54,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() => _selectedDuration = null),
              decoration: InputDecoration(
                hintText: '自定义分钟数',
                hintStyle: const TextStyle(color: Colors.white38),
                suffixText: 'min',
                suffixStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF162030),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final type = _typeController.text.trim();
    if (type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择或填写运动类型')),
      );
      return;
    }

    final durationText = _durationController.text.trim();
    final duration = durationText.isNotEmpty ? int.tryParse(durationText) : null;

    widget.onSubmit(Record(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: RecordType.exercise,
      origin: RecordOrigin.spontaneous,
      data: {
        'exerciseType': type,
        if (duration != null) 'duration': duration,
      },
    ));

    Navigator.of(context).pop();
  }
}
