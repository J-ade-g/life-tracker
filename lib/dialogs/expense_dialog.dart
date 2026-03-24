import 'package:flutter/material.dart';
import 'package:life_tracker/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:life_tracker/models/record.dart';
import 'package:life_tracker/providers/data_provider.dart';
import 'package:provider/provider.dart';

class ExpenseDialog extends StatefulWidget {
  final void Function(Record) onSubmit;
  const ExpenseDialog({super.key, required this.onSubmit});

  static Future<void> show(BuildContext context, void Function(Record) onSubmit) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ExpenseDialog(onSubmit: onSubmit),
    );
  }

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  bool _isExpense = true;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseCategory? _selectedExpenseCategory;
  IncomeCategory? _selectedIncomeCategory;
  String? _selectedCustomExpense; // "emoji|label"
  String? _selectedCustomIncome;

  @override
  void dispose() { _amountController.dispose(); _noteController.dispose(); super.dispose(); }

  InputDecoration _inputDeco(String hint, {String? prefix}) => InputDecoration(
    prefixText: prefix,
    hintText: hint,
    hintStyle: const TextStyle(color: AppTheme.textSecondary),
    filled: true,
    fillColor: AppTheme.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.cardBorder, width: 2)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  Widget _chip(String label, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.emeraldGreen.withValues(alpha: 0.12) : AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppTheme.emeraldGreen : AppTheme.cardBorder, width: 2),
      ),
      child: Text(label, style: TextStyle(color: selected ? AppTheme.emeraldGreen : AppTheme.textSecondary, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
    ),
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
            Text('💰 记账', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),

            // Toggle
            Row(
              children: [
                Expanded(child: GestureDetector(
                  onTap: () => setState(() { _isExpense = true; _selectedIncomeCategory = null; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isExpense ? AppTheme.heartRed.withValues(alpha: 0.12) : AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _isExpense ? AppTheme.heartRed : AppTheme.cardBorder, width: 2),
                    ),
                    child: Center(child: Text('支出', style: TextStyle(color: _isExpense ? AppTheme.heartRed : AppTheme.textSecondary, fontWeight: FontWeight.bold))),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: GestureDetector(
                  onTap: () => setState(() { _isExpense = false; _selectedExpenseCategory = null; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isExpense ? AppTheme.emeraldGreen.withValues(alpha: 0.12) : AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: !_isExpense ? AppTheme.emeraldGreen : AppTheme.cardBorder, width: 2),
                    ),
                    child: Center(child: Text('收入', style: TextStyle(color: !_isExpense ? AppTheme.emeraldGreen : AppTheme.textSecondary, fontWeight: FontWeight.bold))),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 20),

            Text('金额 *', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: _inputDeco('0.00', prefix: '¥ '),
            ),
            const SizedBox(height: 20),

            Text('分类 *', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (_isExpense)
              Wrap(spacing: 8, runSpacing: 8, children: [
                ...ExpenseCategory.values.map((cat) => _chip('${cat.emoji} ${cat.label}', _selectedExpenseCategory == cat && _selectedCustomExpense == null, () => setState(() { _selectedExpenseCategory = cat; _selectedCustomExpense = null; }))),
                ...context.watch<DataProvider>().customExpenseCategories.map((c) => _chip('${c.emoji} ${c.label}', _selectedCustomExpense == '${c.emoji}|${c.label}', () => setState(() { _selectedCustomExpense = '${c.emoji}|${c.label}'; _selectedExpenseCategory = null; }))),
                _addCategoryChip(() => _showAddCategoryDialog(isExpense: true)),
              ])
            else
              Wrap(spacing: 8, runSpacing: 8, children: [
                ...IncomeCategory.values.map((cat) => _chip('${cat.emoji} ${cat.label}', _selectedIncomeCategory == cat && _selectedCustomIncome == null, () => setState(() { _selectedIncomeCategory = cat; _selectedCustomIncome = null; }))),
                ...context.watch<DataProvider>().customIncomeCategories.map((c) => _chip('${c.emoji} ${c.label}', _selectedCustomIncome == '${c.emoji}|${c.label}', () => setState(() { _selectedCustomIncome = '${c.emoji}|${c.label}'; _selectedIncomeCategory = null; }))),
                _addCategoryChip(() => _showAddCategoryDialog(isExpense: false)),
              ]),
            const SizedBox(height: 20),

            Text('备注（可选）', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _noteController, style: const TextStyle(color: AppTheme.textPrimary), decoration: _inputDeco('添加备注...')),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: AppTheme.darkGreen, blurRadius: 0, offset: Offset(0, 4))]),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  onPressed: _submit,
                  child: const Text('确认', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addCategoryChip(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder, width: 2, style: BorderStyle.solid),
      ),
      child: const Text('+ 添加', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    ),
  );

  void _showAddCategoryDialog({required bool isExpense}) {
    final labelCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '📌');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isExpense ? '添加支出分类' : '添加收入分类'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emojiCtrl, decoration: const InputDecoration(labelText: 'Emoji（一个）'), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: '分类名称'), autofocus: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final label = labelCtrl.text.trim();
              final emoji = emojiCtrl.text.trim();
              if (label.isEmpty) return;
              final dp = context.read<DataProvider>();
              if (isExpense) {
                dp.addCustomExpenseCategory(emoji.isEmpty ? '📌' : emoji, label);
              } else {
                dp.addCustomIncomeCategory(emoji.isEmpty ? '📌' : emoji, label);
              }
              Navigator.pop(ctx);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入有效金额')));
      return;
    }
    if (_isExpense && _selectedExpenseCategory == null && _selectedCustomExpense == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择支出分类')));
      return;
    }
    if (!_isExpense && _selectedIncomeCategory == null && _selectedCustomIncome == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择收入分类')));
      return;
    }
    final data = <String, dynamic>{'amount': amount, 'note': _noteController.text.trim()};
    if (_isExpense) {
      if (_selectedExpenseCategory != null) {
        data['expenseCategory'] = _selectedExpenseCategory;
      } else if (_selectedCustomExpense != null) {
        data['customCategory'] = _selectedCustomExpense;
      }
    } else {
      if (_selectedIncomeCategory != null) {
        data['incomeCategory'] = _selectedIncomeCategory;
      } else if (_selectedCustomIncome != null) {
        data['customCategory'] = _selectedCustomIncome;
      }
    }
    widget.onSubmit(Record(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: _isExpense ? RecordType.expense : RecordType.income,
      origin: RecordOrigin.spontaneous,
      data: data,
    ));
    Navigator.of(context).pop();
  }
}
