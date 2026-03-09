import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_tracker/models/record.dart';

class ExpenseDialog extends StatefulWidget {
  final void Function(Record) onSubmit;

  const ExpenseDialog({super.key, required this.onSubmit});

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

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
              '记账',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 支出/收入 toggle
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('支出')),
                    selected: _isExpense,
                    onSelected: (_) => setState(() {
                      _isExpense = true;
                      _selectedIncomeCategory = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('收入')),
                    selected: !_isExpense,
                    onSelected: (_) => setState(() {
                      _isExpense = false;
                      _selectedExpenseCategory = null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 金额
            Text('金额 *', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                prefixText: '¥ ',
                hintText: '0.00',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 分类
            Text('分类 *', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            if (_isExpense)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((cat) {
                  return ChoiceChip(
                    label: Text('${cat.emoji} ${cat.label}'),
                    selected: _selectedExpenseCategory == cat,
                    onSelected: (_) =>
                        setState(() => _selectedExpenseCategory = cat),
                  );
                }).toList(),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IncomeCategory.values.map((cat) {
                  return ChoiceChip(
                    label: Text('${cat.emoji} ${cat.label}'),
                    selected: _selectedIncomeCategory == cat,
                    onSelected: (_) =>
                        setState(() => _selectedIncomeCategory = cat),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),

            // 备注（可选）
            Text('备注（可选）',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: '添加备注...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('确认'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }

    if (_isExpense && _selectedExpenseCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择支出分类')),
      );
      return;
    }

    if (!_isExpense && _selectedIncomeCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择收入分类')),
      );
      return;
    }

    widget.onSubmit(Record(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: _isExpense ? RecordType.expense : RecordType.income,
      origin: RecordOrigin.spontaneous,
      data: {
        'amount': amount,
        if (_isExpense) 'expenseCategory': _selectedExpenseCategory,
        if (!_isExpense) 'incomeCategory': _selectedIncomeCategory,
        'note': _noteController.text.trim(),
      },
    ));

    Navigator.of(context).pop();
  }
}
