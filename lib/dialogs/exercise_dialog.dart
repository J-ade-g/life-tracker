import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_tracker/models/record.dart';
import 'package:life_tracker/theme/app_theme.dart';

class ExercisePreset {
  final String name;
  final String icon; // emoji

  const ExercisePreset({required this.name, required this.icon});

  Map<String, dynamic> toJson() => {'name': name, 'icon': icon};
  factory ExercisePreset.fromJson(Map<String, dynamic> json) =>
      ExercisePreset(name: json['name'] as String, icon: json['icon'] as String);
}

/// Manages exercise presets in Hive
class ExercisePresetStore {
  static const _boxName = 'exercise_presets';
  static const _key = 'presets';

  static final List<ExercisePreset> _defaults = [
    ExercisePreset(name: '跑步', icon: '🏃'),
    ExercisePreset(name: '散步', icon: '🚶'),
    ExercisePreset(name: '瑜伽', icon: '🧘'),
    ExercisePreset(name: '俯卧撑', icon: '💪'),
    ExercisePreset(name: '深蹲', icon: '🦵'),
    ExercisePreset(name: '拉伸', icon: '🤸'),
    ExercisePreset(name: '游泳', icon: '🏊'),
    ExercisePreset(name: '骑车', icon: '🚴'),
    ExercisePreset(name: '跳绳', icon: '⏭️'),
    ExercisePreset(name: '网球', icon: '🎾'),
    ExercisePreset(name: '爬山', icon: '⛰️'),
  ];

  static Box<String>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  static List<ExercisePreset> getPresets() {
    final raw = _box?.get(_key);
    if (raw == null) return List.from(_defaults);
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => ExercisePreset.fromJson(e as Map<String, dynamic>))
          .toList();
      return list.isEmpty ? List.from(_defaults) : list;
    } catch (_) {
      return List.from(_defaults);
    }
  }

  static Future<void> savePresets(List<ExercisePreset> presets) async {
    await _box?.put(_key, jsonEncode(presets.map((p) => p.toJson()).toList()));
  }

  static Future<void> resetToDefaults() async {
    await _box?.delete(_key);
  }
}

class ExerciseDialog extends StatefulWidget {
  final void Function(Record) onSubmit;

  const ExerciseDialog({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context,
    void Function(Record) onSubmit,
  ) async {
    await ExercisePresetStore.init();
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
  late List<ExercisePreset> _presets;

  static const _durations = [15, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _presets = ExercisePresetStore.getPresets();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showEditPresets() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditPresetsSheet(
        presets: List.from(_presets),
        onSave: (newPresets) {
          ExercisePresetStore.savePresets(newPresets);
          setState(() => _presets = newPresets);
        },
      ),
    );
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
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.cardBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('运动', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: _showEditPresets,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: AppTheme.emeraldGreen, size: 14),
                        const SizedBox(width: 4),
                        Text('自定义', style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('快速选择', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: _presets.map((preset) {
                final isSelected = _typeController.text == preset.name;
                return GestureDetector(
                  onTap: () => setState(() => _typeController.text = preset.name),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.emeraldGreen.withValues(alpha: 0.2) : AppTheme.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.emeraldGreen : AppTheme.cardBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(preset.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          preset.name,
                          style: TextStyle(
                            color: isSelected ? AppTheme.emeraldGreen : AppTheme.textSecondary,
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
            TextField(
              controller: _typeController,
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '或自定义运动名称',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Text('时长', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: _durations.map((d) {
                final isSelected = _selectedDuration == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() { _selectedDuration = d; _durationController.text = d.toString(); }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.emeraldGreen.withValues(alpha: 0.2) : AppTheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppTheme.emeraldGreen : AppTheme.cardBorder, width: isSelected ? 1.5 : 1),
                      ),
                      child: Text('${d}min', style: TextStyle(color: isSelected ? AppTheme.emeraldGreen : AppTheme.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
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
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged: (_) => setState(() => _selectedDuration = null),
              decoration: InputDecoration(
                hintText: '自定义分钟数',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                suffixText: 'min',
                suffixStyle: const TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择或填写运动类型')));
      return;
    }
    final durationText = _durationController.text.trim();
    final duration = durationText.isNotEmpty ? int.tryParse(durationText) : null;
    widget.onSubmit(Record(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: RecordType.exercise,
      origin: RecordOrigin.spontaneous,
      data: {'exerciseType': type, if (duration != null) 'duration': duration},
    ));
    Navigator.of(context).pop();
  }
}

/// Sheet for editing exercise presets
class _EditPresetsSheet extends StatefulWidget {
  final List<ExercisePreset> presets;
  final void Function(List<ExercisePreset>) onSave;

  const _EditPresetsSheet({required this.presets, required this.onSave});

  @override
  State<_EditPresetsSheet> createState() => _EditPresetsSheetState();
}

class _EditPresetsSheetState extends State<_EditPresetsSheet> {
  late List<ExercisePreset> _presets;
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();

  static const _emojiOptions = ['🏃','🚶','🧘','💪','🦵','🤸','🏊','🚴','⏭️','🎾','⛰️','⚽','🏸','🥊','💃','🧗','🛹','🏋️','🤾','⛷️'];

  @override
  void initState() {
    super.initState();
    _presets = List.from(widget.presets);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _addPreset() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final emoji = _emojiController.text.trim().isEmpty ? '🏃' : _emojiController.text.trim();
    setState(() {
      _presets.add(ExercisePreset(name: name, icon: emoji));
      _nameController.clear();
      _emojiController.clear();
    });
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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.cardBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('编辑运动选项', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            // Current presets as reorderable chips
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _presets.length,
              onReorder: (old, newIdx) {
                setState(() {
                  if (newIdx > old) newIdx--;
                  final item = _presets.removeAt(old);
                  _presets.insert(newIdx, item);
                });
              },
              itemBuilder: (context, i) {
                final p = _presets[i];
                return ListTile(
                  key: ValueKey('${p.name}_$i'),
                  leading: Text(p.icon, style: const TextStyle(fontSize: 20)),
                  title: Text(p.name, style: const TextStyle(color: AppTheme.textPrimary)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
                    onPressed: () => setState(() => _presets.removeAt(i)),
                  ),
                  tileColor: Colors.transparent,
                );
              },
            ),
            const Divider(color: AppTheme.cardBorder),
            const SizedBox(height: 8),
            Text('添加新运动', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                // Emoji picker
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _emojiController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '🏃',
                      hintStyle: const TextStyle(fontSize: 20),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: '运动名称',
                      hintStyle: const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _addPreset(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addPreset,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppTheme.emeraldGreen, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quick emoji options
            Wrap(
              spacing: 6,
              children: _emojiOptions.map((e) => GestureDetector(
                onTap: () => setState(() => _emojiController.text = e),
                child: Text(e, style: const TextStyle(fontSize: 22)),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ExercisePresetStore.resetToDefaults();
                      setState(() => _presets = ExercisePresetStore.getPresets());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('恢复默认'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(_presets);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
