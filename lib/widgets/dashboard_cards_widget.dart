import 'package:flutter/material.dart';
import '../../app_colors.dart';
import 'package:intl/intl.dart'; // Import for number formatting

class DashboardCardsWidget extends StatelessWidget {
  final bool isLoading;
  final int orderCount;
  final int productCount;
  final int customerCount;
  final double totalRevenue;

  const DashboardCardsWidget({
    super.key,
    this.isLoading = false,
    this.orderCount = 0,
    this.productCount = 0,
    this.customerCount = 0,
    this.totalRevenue = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          isLoading 
          ? _buildLoadingCards() 
          : _buildDataCards(),
        ],
      ),
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              icon: Icons.shopping_bag,
              title: 'Tổng đơn hàng',
              value: '...',
              color: Colors.blue,
              isLoading: true,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.inventory_2,
              title: 'Loại cây',
              value: '...',
              color: Colors.green,
              isLoading: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              icon: Icons.people,
              title: 'Khách hàng',
              value: '...',
              color: Colors.orange,
              isLoading: true,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.money,
              title: 'Doanh thu',
              value: '...',
              color: Colors.purple,
              isLoading: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataCards() {
    // Format currency (Vietnamese Dong)
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
    final formattedRevenue = currencyFormatter.format(totalRevenue);
    
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              icon: Icons.shopping_bag,
              title: 'Tổng đơn hàng',
              value: orderCount.toString(),
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.inventory_2,
              title: 'Loại cây',
              value: productCount.toString(),
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              icon: Icons.people,
              title: 'Khách hàng',
              value: customerCount.toString(),
              color: Colors.orange,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.money,
              title: 'Doanh thu',
              value: '$formattedRevenueđ',
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isLoading = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            isLoading
            ? SizedBox(
                height: 20,
                width: 60,
                child: Center(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              )
            : Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}