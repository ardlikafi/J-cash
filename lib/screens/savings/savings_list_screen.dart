import 'package:flutter/material.dart';
import '../../models/savings_goal.dart';
import '../../services/savings_service.dart';
import 'add_savings_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/animation.dart';
import 'package:j_cash/utils/currency_formatter.dart';

String formatSavingsAmount(double amount) {
  if (amount >= 1000000000) {
    return 'Rp${(amount / 1000000000).toStringAsFixed(1)}M'.replaceAll(
      '.0',
      '',
    );
  }
  if (amount >= 1000000) {
    return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt'.replaceAll('.0', '');
  }
  if (amount >= 1000) return 'Rp${(amount / 1000).toStringAsFixed(0)}k';
  return 'Rp${amount.toStringAsFixed(0)}';
}

class SavingsListScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const SavingsListScreen({Key? key, this.onBackToHome}) : super(key: key);

  @override
  State<SavingsListScreen> createState() => _SavingsListScreenState();
}

class _SavingsListScreenState extends State<SavingsListScreen> {
  final SavingsService _savingsService = SavingsService();
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    setState(() {
      _isLoading = true;
    });
    final goals = await _savingsService.getSavings();
    setState(() {
      _savingsGoals = goals;
      _isLoading = false;
    });
  }

  Future<void> _updateProgress(SavingsGoal goal) async {
    final controller = TextEditingController(
      text: goal.currentAmount > 0 ? formatCurrency(goal.currentAmount) : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          decoration: const InputDecoration(
            labelText: 'Jumlah Saat Ini',
            prefixText: 'Rp ',
            hintText: '0',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final amount = parseCurrency(controller.text);
              if (amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _savingsService.updateProgress(goal.id, result);
      _loadSavings();
    }
  }

  Future<void> _deleteSavings(SavingsGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tabungan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus tabungan "${goal.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _savingsService.deleteSavings(goal.id);
      _loadSavings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabungan Saya'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            }
          },
        ),
      ),
      body: StreamBuilder<List<SavingsGoal>>(
        stream: _savingsService.getSavingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada tabungan.\nTap + untuk menambah tabungan baru.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          final savingsGoals = snapshot.data!;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: ListView.builder(
              key: ValueKey(savingsGoals.length),
              itemCount: savingsGoals.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final goal = savingsGoals[index];
                final progress = goal.progress ?? 0.0;
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: goal.color ?? Colors.blue,
                              radius: 28,
                              child: goal.iconPath.isNotEmpty
                                  ? Image.asset(goal.iconPath,
                                      height: 32, width: 32)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${currencyFormat.format(goal.currentAmount)} / ${currencyFormat.format(goal.targetAmount)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              tooltip: 'Edit',
                              onPressed: () async {
                                final result =
                                    await Navigator.push<SavingsGoal>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddSavingsScreen(editingGoal: goal),
                                  ),
                                );
                                if (result != null) {
                                  await _savingsService.updateSavings(result);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              tooltip: 'Hapus',
                              onPressed: () => _deleteSavings(goal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              goal.color ?? Colors.blue),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress: ${(progress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                            TextButton(
                              onPressed: () => _updateProgress(goal),
                              child: const Text('Update Progress'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<SavingsGoal>(
            context,
            MaterialPageRoute(builder: (context) => const AddSavingsScreen()),
          );
          if (result != null) {
            await _savingsService.addSavings(result);
            // Tidak perlu _loadSavings(); karena pakai stream
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
