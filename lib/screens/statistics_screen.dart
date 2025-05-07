import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/order_service.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<int, List<double>> revenueDataByYear = {};
  int selectedYear = DateTime.now().year;
  final List<int> availableYears = [2020, 2021, 2022, 2023, 2024, 2025];

  @override
  void initState() {
    super.initState();
    _fetchRevenueData();
  }

  Future<void> _fetchRevenueData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await OrderService.getRevenueData();
      debugPrint('Revenue data is: $data');

      if (data != null && data.isNotEmpty) {
        setState(() {
          revenueDataByYear = data.map(
            (key, value) => MapEntry(
              key,
              value
                  .map((e) => (e as num).toDouble())
                  .toList(), // Ép kiểu từng phần tử
            ),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No revenue data available.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch revenue error: $e');
      setState(() {
        _error = 'Failed to load revenue data.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = revenueDataByYear[selectedYear] ?? [];
    final double totalRevenue = revenueDataByYear.values
        .expand((list) => list)
        .fold(0.0, (sum, item) => sum + item);
    final formattedRevenue = NumberFormat('#,###', 'vi_VN').format(totalRevenue * 1000000);
    debugPrint('Data for selected year $selectedYear: $data');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống kê',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatisticCard(
                  label: 'Doanh thu toàn hệ thống',
                  value: '$formattedRevenue đ',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Biểu đồ doanh thu (tháng)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: selectedYear,
                  items: availableYears
                      .map((year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: 25,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 5,
                        getTitlesWidget: (value, _) =>
                            Text('${value.toInt()}tr'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final months = [
                            'T1',
                            'T2',
                            'T3',
                            'T4',
                            'T5',
                            'T6',
                            'T7',
                            'T8',
                            'T9',
                            'T10',
                            'T11',
                            'T12'
                          ];
                          if (value.toInt() >= 0 && value.toInt() < 12) {
                            return Text(months[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey),
                  ),
                  gridData: FlGridData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                        (index) => FlSpot(index.toDouble(), data[index]),
                      ),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Biểu đồ doanh thu (năm)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  maxY: 500,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 100,
                        getTitlesWidget: (value, _) =>
                            Text('${value.toInt()}tr'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final years = availableYears
                              .map((year) => year.toString())
                              .toList();
                          if (value.toInt() >= 0 &&
                              value.toInt() < years.length) {
                            return Text(years[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey),
                  ),
                  barGroups: List.generate(availableYears.length, (index) {
                    final year = availableYears[index];
                    final revenue =
                        revenueDataByYear[year]?.reduce((a, b) => a + b) ?? 0;
                    return BarChartGroupData(x: index, barRods: [
                      BarChartRodData(
                          width: 15,
                          toY: revenue.toDouble(),
                          color: AppColors.primary)
                    ]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
