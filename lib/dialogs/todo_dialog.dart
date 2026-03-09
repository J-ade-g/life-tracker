import 'package:flutter/material.dart';
import 'package:life_tracker/models/record.dart';

class TodoDialog {
  static Future<void> show(
    BuildContext context,
    void Function(Record) onSave,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TodoForm(onSave: onSave),
    );
  }
}

class _TodoForm extends StatefulWidget {
  final void Function(Record) onSave;
  const _TodoForm({required this.onSave});

  @override
  State<_TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<_TodoForm> {
  final _titleController = TextEditingController();
  TimeOfDay? _targetTime;
  GoalCategory? _category;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPadding),
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
            '添加计划',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '任务标题（必填）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: Text(
              _targetTime == null
                  ? '目标时间（可选）'
                  : '${_targetTime!.hour.toString().padLeft(2, '0')}:${_targetTime!.minute.toString().padLeft(2, '0')}',
            ),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _targetTime ?? TimeOfDay.now(),
              );
              if (t != null) setState(() => _targetTime = t);
            },
            trailing: _targetTime != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() => _targetTime = null),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            '目标分类',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GoalCategory.values.map((cat) {
              final selected = _category == cat;
              return ChoiceChip(
                label: Text('${cat.emoji} ${cat.label}'),
                selected: selected,
                onSelected: (v) =>
                    setState(() => _category = v ? cat : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入任务标题')),
      );
      return;
    }

    final now = DateTime.now();
    DateTime? targetDateTime;
    if (_targetTime != null) {
      targetDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _targetTime!.hour,
        _targetTime!.minute,
      );
    }

    widget.onSave(Record(
      id: now.millisecondsSinceEpoch.toString(),
      timestamp: now,
      type: RecordType.todo,
      origin: RecordOrigin.planned,
      data: {
        'title': title,
        if (targetDateTime != null) 'targetTime': targetDateTime,
        if (_category != null) 'category': _category,
        'completed': false,
      },
    ));

    Navigator.pop(context);
  }
}
