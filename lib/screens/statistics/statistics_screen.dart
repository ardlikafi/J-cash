// lib/screens/statistics/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
import 'package:fl_chart/fl_chart.dart'; // Import package grafik
import 'package:intl/intl.dart';
import 'package:j_cash/services/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // --- State untuk Filter Periode ---
  String _selectedPeriod = 'Bulanan'; // Default bulanan
  final List<String> _periods = ['Mingguan', 'Bulanan', 'Tahunan', 'Custom'];

  // --- Placeholder Data Statistik ---
  // Nanti data ini dihitung dari transaksi berdasarkan periode terpilih
  double totalIncome = 15000000.0; // Contoh
  double totalExpense = 8575000.0; // Contoh
  // Data untuk Pie Chart (Kategori Pengeluaran & Jumlahnya)
  Map<String, double> expenseByCategory = {
    'Makanan': 2500000.0,
    'Transportasi': 1200000.0,
    'Belanja': 3100000.0,
    'Tagihan': 875000.0,
    'Hiburan': 900000.0,
    // Pastikan data ini tidak semuanya 0 atau kosong
  };
  // -----------------------------

  // Helper untuk format currency
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // State untuk Pie Chart
  int touchedIndex = -1; // Menyimpan index bagian pie yg disentuh

  DateTime? _customStart;
  DateTime? _customEnd;

  DateTime get _periodStart {
    final now = DateTime.now();
    if (_selectedPeriod == 'Mingguan') {
      return now.subtract(Duration(days: now.weekday - 1));
    } else if (_selectedPeriod == 'Bulanan') {
      return DateTime(now.year, now.month, 1);
    } else if (_selectedPeriod == 'Tahunan') {
      return DateTime(now.year, 1, 1);
    } else if (_selectedPeriod == 'Custom' && _customStart != null) {
      return _customStart!;
    } else {
      return DateTime(now.year, now.month, 1);
    }
  }

  DateTime get _periodEnd {
    final now = DateTime.now();
    if (_selectedPeriod == 'Mingguan') {
      return now;
    } else if (_selectedPeriod == 'Bulanan') {
      return DateTime(now.year, now.month + 1, 0);
    } else if (_selectedPeriod == 'Tahunan') {
      return DateTime(now.year, 12, 31);
    } else if (_selectedPeriod == 'Custom' && _customEnd != null) {
      return _customEnd!;
    } else {
      return now;
    }
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStart != null && _customEnd != null
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _customStart = picked.start;
        _customEnd = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsService = StatisticsService();
    return Scaffold(
      // --- Implementasi AppBar ---
      appBar: AppBar(
        title: const Text(
          'Statistik',
          style: TextStyle(
            color: AppColors.fontGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                items: _periods.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  if (newValue == 'Custom') {
                    await _pickCustomDateRange();
                  }
                  setState(() {
                    _selectedPeriod = newValue!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      // --- Implementasi Body ---
      body: FutureBuilder(
        future: Future.wait([
          // 0: totalIncome (periode)
          statsService.getTotalAmount(
            startDate: _periodStart,
            endDate: _periodEnd,
            isExpense: false,
          ),
          // 1: totalExpense (periode)
          statsService.getTotalAmount(
            startDate: _periodStart,
            endDate: _periodEnd,
            isExpense: true,
          ),
          // 2: expenseByCategory (periode)
          statsService.getAmountByCategory(
            startDate: _periodStart,
            endDate: _periodEnd,
            isExpense: true,
          ),
          // 3: incomeByDay (periode)
          statsService.getAmountByDay(
            startDate: _periodStart,
            endDate: _periodEnd,
            isExpense: false,
          ),
          // 4: expenseByDay (periode)
          statsService.getAmountByDay(
            startDate: _periodStart,
            endDate: _periodEnd,
            isExpense: true,
          ),
          // 5: totalIncomeAll (keseluruhan)
          statsService.getTotalAmount(
            startDate: DateTime(2000),
            endDate: DateTime.now(),
            isExpense: false,
          ),
          // 6: totalExpenseAll (keseluruhan)
          statsService.getTotalAmount(
            startDate: DateTime(2000),
            endDate: DateTime.now(),
            isExpense: true,
          ),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Tidak ada data statistik'));
          }
          final totalIncome = snapshot.data![0] as double;
          final totalExpense = snapshot.data![1] as double;
          final expenseByCategory = snapshot.data![2] as Map<String, double>;
          final incomeByDay = snapshot.data![3] as Map<DateTime, double>;
          final expenseByDay = snapshot.data![4] as Map<DateTime, double>;
          final totalIncomeAll = snapshot.data![5] as double;
          final totalExpenseAll = snapshot.data![6] as double;
          double totalExpenseForPie =
              expenseByCategory.values.fold(0.0, (sum, item) => sum + item);
          List<PieChartSectionData> pieChartSections =
              _buildPieChartSections(expenseByCategory, totalExpenseForPie);
          final netAll = totalIncomeAll - totalExpenseAll;

          return ListView(
            padding: const EdgeInsets.all(15.0),
            children: [
              // Statistik Keseluruhan
              Card(
                color: Colors.grey[100],
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 18),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Statistik Keseluruhan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.arrow_downward,
                              color: AppColors.error, size: 22),
                          const SizedBox(width: 6),
                          Text('Total Pengeluaran:',
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Text(currencyFormatter.format(totalExpenseAll),
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.arrow_upward,
                              color: AppColors.fontGreen, size: 22),
                          const SizedBox(width: 6),
                          Text('Total Pemasukan:',
                              style: TextStyle(
                                  color: AppColors.fontGreen,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Text(currencyFormatter.format(totalIncomeAll),
                              style: TextStyle(
                                  color: AppColors.fontGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                              netAll >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: netAll >= 0
                                  ? AppColors.fontGreen
                                  : AppColors.error,
                              size: 22),
                          const SizedBox(width: 6),
                          Text('Selisih:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Text(currencyFormatter.format(netAll),
                              style: TextStyle(
                                  color: netAll >= 0
                                      ? AppColors.fontGreen
                                      : AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Ringkasan Periode Saat Ini
              Card(
                color: Colors.white,
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 18),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text('Periode saat ini',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                                'Pemasukan', totalIncome, AppColors.fontGreen),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryCard(
                                'Pengeluaran', totalExpense, AppColors.error),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Grafik Tren Pemasukan & Pengeluaran
              const Text(
                'Grafik Tren Pemasukan & Pengeluaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              _buildLineChart(incomeByDay, expenseByDay),
              const SizedBox(height: 25),
              // Grafik Pengeluaran per Kategori (Pie Chart)
              const Text(
                'Pengeluaran per Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              if (totalExpenseForPie <= 0)
                SizedBox(
                  height: 200, // Beri tinggi agar terlihat
                  child: Center(
                    child: Text(
                      "Belum ada data pengeluaran",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else // Tampilkan Chart jika ada data
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: StatefulBuilder(
                        builder: (context, pieSetState) {
                          return PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback:
                                    (FlTouchEvent event, pieTouchResponse) {
                                  pieSetState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = pieTouchResponse
                                        .touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 45,
                              sections: pieChartSections,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              // Tampilkan Indikator hanya jika ada data
              if (totalExpenseForPie > 0)
                _buildPieChartIndicators(expenseByCategory),
              const SizedBox(height: 25),
            ],
          );
        },
      ),
    );
  }

  // --- Grafik Tren Pemasukan & Pengeluaran (Line Chart) ---
  Widget _buildLineChart(
      Map<DateTime, double> incomeByDay, Map<DateTime, double> expenseByDay) {
    // Gabungkan semua tanggal unik dalam periode, isi nol jika tidak ada transaksi
    final allDates = <DateTime>[];
    DateTime d = _periodStart;
    while (!d.isAfter(_periodEnd)) {
      allDates.add(DateTime(d.year, d.month, d.day));
      d = d.add(const Duration(days: 1));
    }
    if (allDates.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('Belum ada data tren')),
      );
    }
    // Buat spots untuk line chart
    final incomeSpots = allDates
        .map((date) => FlSpot(
              date.millisecondsSinceEpoch.toDouble(),
              incomeByDay[date] ?? 0.0,
            ))
        .toList();
    final expenseSpots = allDates
        .map((date) => FlSpot(
              date.millisecondsSinceEpoch.toDouble(),
              expenseByDay[date] ?? 0.0,
            ))
        .toList();
    // Cek jika semua data nol
    final isAllZero = incomeSpots.every((s) => s.y == 0) &&
        expenseSpots.every((s) => s.y == 0);
    if (isAllZero) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('Belum ada transaksi pada periode ini')),
      );
    }
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text(DateFormat('d/M').format(date),
                      style: const TextStyle(fontSize: 10));
                },
                reservedSize: 32,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: AppColors.fontGreen,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: AppColors.error,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // --- Implementasi Helper Widget Card Ringkasan ---
  Widget _buildSummaryCard(String title, double amount, Color amountColor) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  // --- Implementasi Helper Pie Chart Sections (SUDAH DIPERBAIKI) ---
  List<PieChartSectionData> _buildPieChartSections(
      Map<String, double> expenseByCategory, double totalValue) {
    final List<Color> chartColors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.yellow.shade700,
      Colors.teal.shade400,
      Colors.pink.shade300,
    ];
    int colorIndex = 0;
    int currentSectionIndex = 0;

    // --- PENGECEKAN totalValue ---
    if (totalValue <= 0) {
      // Jika total 0, kembalikan list kosong agar chart tidak error
      return [];
      // Atau bisa kembalikan 1 section abu-abu jika ingin placeholder
      // return [ PieChartSectionData(color: Colors.grey.shade300, value: 1, title: '', radius: 50.0) ];
    }
    // --- AKHIR PENGECEKAN ---

    // Jika totalValue > 0, lanjutkan membuat sections
    return expenseByCategory.entries.map((entry) {
      final isTouched = currentSectionIndex == touchedIndex;
      final fontSize = isTouched ? 14.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = chartColors[colorIndex % chartColors.length];
      colorIndex++;

      // --- Perhitungan persentase sudah aman ---
      final double percentage = (entry.value / totalValue) * 100;
      final String title =
          percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '';

      final int sectionIndexForData = currentSectionIndex;
      currentSectionIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: title,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2),
          ],
        ),
      );
    }).toList();
  }

  // --- Implementasi Helper Indikator Pie Chart ---
  Widget _buildPieChartIndicators(Map<String, double> expenseByCategory) {
    final List<Color> chartColors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.yellow.shade700,
      Colors.teal.shade400,
      Colors.pink.shade300,
    ];
    int colorIndex = 0;

    return Wrap(
      spacing: 15.0,
      runSpacing: 8.0,
      children: expenseByCategory.entries.map((entry) {
        final color = chartColors[colorIndex % chartColors.length];
        colorIndex++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(width: 12, height: 12, color: color),
            const SizedBox(width: 4),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        );
      }).toList(),
    );
  }
} // Akhir class _StatisticsScreenState
