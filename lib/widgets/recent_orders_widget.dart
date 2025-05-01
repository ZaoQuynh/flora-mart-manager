import 'package:flutter/material.dart';
import '../../app_colors.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // Import MainScreen

class RecentOrdersWidget extends StatelessWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const RecentOrdersWidget({
    super.key,
    required this.orders,
    required this.isLoading,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đơn hàng gần đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              TextButton(
                onPressed: isLoading 
                  ? null // Disable button when loading
                  : () {
                      // Sử dụng phương thức tĩnh để chuyển đến tab Đơn hàng
                      MainScreen.navigateToTab(context, 2); // Chuyển đến tab Đơn hàng (index 2)
                    },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: isLoading ? Colors.grey : AppColors.primary, // Change color when disabled
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Bạn chưa có đơn hàng nào'),
        ),
      );
    }

    // Lấy 3 đơn hàng gần nhất để hiển thị
    final recentOrders = orders.length > 3 ? orders.sublist(0, 3) : orders;

    return Container(
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentOrders.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return _buildOrderItem(context, recentOrders[index]);
        },
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Map<String, dynamic> order) {
    // Trích xuất thông tin từ đơn hàng
    final orderId = order['id']?.toString() ?? 'N/A';
    final customerName = order['customer']?['fullName'] ?? 'Không có tên';
    
    // Xử lý ngày tạo đơn hàng
    String formattedDate = 'N/A';
    if (order['createDate'] != null) {
      try {
        // API trả về chuỗi DateTime như "2025-04-25T10:30:00"
        final dateTime = DateTime.parse(order['createDate']);
        formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }
    
    // Tính tổng tiền từ các mặt hàng trong đơn
    double totalAmount = 0;
    if (order['orderItems'] != null && order['orderItems'] is List) {
      for (var item in order['orderItems']) {
        final qty = item['qty'] ?? 0;
        final price = item['currentPrice'] ?? 0.0;
        final discounted = item['discounted'] ?? 0.0;
        totalAmount += (price - discounted) * qty;
      }
    }
    
    // Format số tiền
    final formattedAmount = NumberFormat.currency(
      locale: 'vi_VN', 
      symbol: 'đ', 
      decimalDigits: 0
    ).format(totalAmount);
    
    // Trạng thái đơn hàng
    final status = order['status'] ?? 'PENDING';
    
    // Xác định màu trạng thái
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'DELIVERED':
        statusColor = Colors.green;
        statusText = 'Đã giao';
        break;
      case 'SHIPPING':
        statusColor = Colors.blue;
        statusText = 'Đang giao';
        break;
      case 'NEW':
        statusColor = Colors.orange;
        statusText = 'Mới';
        break;
      case 'CANCELED':
        statusColor = Colors.red;
        statusText = 'Đã huỷ';
        break;
      case 'CONFIRMED':
        statusColor = Colors.purple;
        statusText = 'Đã xác nhận';
        break;
      case 'PREPARING':
        statusColor = Colors.yellow;
        statusText = 'Đang chuẩn bị';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.toString();
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.receipt,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        'ĐH-$orderId - $customerName',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$formattedDate | $formattedAmount',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
      onTap: () {
        // Xử lý khi nhấn vào đơn hàng
        // Điều hướng đến trang chi tiết đơn hàng
        Navigator.pushNamed(
          context, 
          '/order-detail', 
          arguments: {'orderId': order['id']}
        );
      },
    );
  }
}