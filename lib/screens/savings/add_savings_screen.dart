import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/savings_goal.dart';
import '../../services/savings_service.dart';
import 'package:j_cash/widgets/icon_picker_dialog.dart';
import 'package:j_cash/constants/savings_icons.dart';
import 'package:j_cash/utils/currency_formatter.dart';

class AddSavingsScreen extends StatefulWidget {
  final SavingsGoal? editingGoal;

  const AddSavingsScreen({super.key, this.editingGoal});

  @override
  State<AddSavingsScreen> createState() => _AddSavingsScreenState();
}

class _AddSavingsScreenState extends State<AddSavingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  Color _selectedColor = Colors.blue;
  String _selectedIconPath = SavingsIcons.icons[0].path;

  @override
  void initState() {
    super.initState();
    if (widget.editingGoal != null) {
      _titleController.text = widget.editingGoal!.title;
      _targetAmountController.text =
          widget.editingGoal!.targetAmount.toString();
      _currentAmountController.text =
          widget.editingGoal!.currentAmount.toString();
      _selectedColor = widget.editingGoal!.color ?? Colors.blue;
      _selectedIconPath = widget.editingGoal!.iconPath;
    }
  }

  Future<void> _pickIcon() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => IconPickerDialog(
        selectedIconPath: _selectedIconPath,
        selectedColor: _selectedColor,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedIconPath = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editingGoal != null ? 'Edit Tabungan' : 'Tambah Tabungan',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Tabungan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Jumlah',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Target jumlah tidak boleh kosong';
                  }
                  if (int.tryParse(value.replaceAll('.', '')) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentAmountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Saat Ini',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah saat ini tidak boleh kosong';
                  }
                  if (int.tryParse(value.replaceAll('.', '')) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Pilih Warna',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Colors.blue,
                  Colors.green,
                  Colors.purple,
                  Colors.orange,
                  Colors.red,
                  Colors.teal,
                  Colors.pink,
                  Colors.indigo,
                ].map((color) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pilih Ikon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickIcon,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        _selectedIconPath,
                        height: 24,
                        width: 24,
                        color: _selectedColor,
                        errorBuilder: (context, error, stackTrace) {
                          final icon = SavingsIcons.icons.firstWhere(
                            (icon) => icon.path == _selectedIconPath,
                            orElse: () => SavingsIcons.icons[0],
                          );
                          return Icon(
                            icon.fallbackIcon,
                            size: 24,
                            color: _selectedColor,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text('Pilih Ikon'),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_drop_down, color: _selectedColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSavingsGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.editingGoal != null ? 'Update' : 'Simpan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSavingsGoal() {
    if (_formKey.currentState!.validate()) {
      final goal = SavingsGoal(
        id: widget.editingGoal?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        targetAmount:
            double.parse(_targetAmountController.text.replaceAll('.', '')),
        currentAmount:
            double.parse(_currentAmountController.text.replaceAll('.', '')),
        color: _selectedColor,
        iconPath: _selectedIconPath,
      );
      Navigator.pop(context, goal);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }
}
