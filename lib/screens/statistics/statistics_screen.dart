// lib/screens/statistics/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
import 'package:fl_chart/fl_chart.dart'; // Import package grafik
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // --- State untuk Filter Periode ---
  String _selectedPeriod = 'Bulanan'; // Default bulanan
  final List<String> _periods = ['Mingguan', 'Bulanan', 'Tahunan'];

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

  @override
  Widget build(BuildContext context) {
    // --- Hitung total pengeluaran untuk pie chart ---
    double totalExpenseForPie = expenseByCategory.values.fold(
      0.0,
      (sum, item) => sum + item,
    );
    // --- Siapkan data sections dengan memanggil helper yang sudah diperbaiki ---
    List<PieChartSectionData> pieChartSections = _buildPieChartSections(
      totalExpenseForPie,
    );

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
                items:
                    _periods.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPeriod = newValue!;
                  });
                  // TODO: Muat ulang data statistik berdasarkan periode baru
                },
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      // --- Implementasi Body ---
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: [
          // Ringkasan Pemasukan & Pengeluaran
          _buildSummaryCard('Pemasukan', totalIncome, AppColors.fontGreen),
          const SizedBox(height: 15),
          _buildSummaryCard('Pengeluaran', totalExpense, AppColors.error),
          const SizedBox(height: 25),

          // Grafik Pengeluaran per Kategori (Pie Chart)
          const Text(
            'Pengeluaran per Kategori',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15),
          // Cek jika tidak ada data pengeluaran sama sekali
          if (totalExpenseForPie <= 0)
            Container(
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
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex =
                                pieTouchResponse
                                    .touchedSection!
                                    .touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                      sections: pieChartSections, // Gunakan data sections
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          // Tampilkan Indikator hanya jika ada data
          if (totalExpenseForPie > 0) _buildPieChartIndicators(),
          const SizedBox(height: 25),

          // --- (Opsional) Grafik Tren ---
          // ... (Placeholder Line Chart dikomentari) ...
        ],
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Text(
              currencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Implementasi Helper Pie Chart Sections (SUDAH DIPERBAIKI) ---
  List<PieChartSectionData> _buildPieChartSections(double totalValue) {
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
  Widget _buildPieChartIndicators() {
    final List<Color> chartColors = [
      Colors.blue.shade400,
      Colors.red.shade400 /* ... palet warna sama ... */,
    ];
    int colorIndex = 0;

    return Wrap(
      spacing: 15.0,
      runSpacing: 8.0,
      children:
          expenseByCategory.entries.map((entry) {
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
