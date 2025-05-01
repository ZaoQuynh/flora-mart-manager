import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'order_status.dart';
import 'order_item.dart';
import '../screens/order_details_screen.dart'; // Import the details screen

class OrderList extends StatelessWidget {
  final List<dynamic> orders;
  final Function(int, OrderStatus) onUpdateStatus;

  const OrderList({
    super.key,
    required this.orders,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final order = orders[index];
        final orderId = order['id'];
        final customerName = order['customer']?['fullName'] ?? 'Không rõ';
        final customerPhone = order['customer']?['phone'] ?? '';
        final orderDate = DateTime.parse(order['createDate']);
        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(orderDate);
        final currentStatus = OrderStatusExtension.fromString(order['status']);
        final itemCount = order['orderItems']?.length ?? 0;

        return OrderCard(
          order: order,
          orderId: orderId,
          customerName: customerName,
          customerPhone: customerPhone,
          formattedDate: formattedDate,
          currentStatus: currentStatus,
          itemCount: itemCount,
          onUpdateStatus: onUpdateStatus,
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final dynamic order;
  final int orderId;
  final String customerName;
  final String customerPhone;
  final String formattedDate;
  final OrderStatus currentStatus;
  final int itemCount;
  final Function(int, OrderStatus) onUpdateStatus;

  const OrderCard({
    super.key,
    required this.order,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.formattedDate,
    required this.currentStatus,
    required this.itemCount,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final (_, _, total) = _calculateOrderAmounts(order);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Row(
          children: [
            Text(
              'ĐH-$orderId',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: currentStatus),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (customerPhone.isNotEmpty) ...[
                  const Text(' - '),
                  Text(customerPhone),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(formattedDate),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              '$itemCount sản phẩm',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        children: [
          OrderItemsList(order: order),
          
          // Order Summary with Voucher Information
          const SizedBox(height: 12),
          StatusUpdateSection(
            currentStatus: currentStatus,
            onUpdateStatus: onUpdateStatus,
            orderId: orderId,
          ),
          
          // View Details Button
          const SizedBox(height: 16),
          _buildViewDetailsButton(context),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(
                orderId: orderId,
                initialOrderData: order, // Pass the existing order data to avoid re-fetching
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Xem chi tiết',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Calculates order amounts and returns a tuple with (subtotal, discount, total)
  (double, double, double) _calculateOrderAmounts(dynamic order) {
    double subtotal = 0.0;
    double discount = 0.0;
    
    // Calculate items subtotal
    if (order['orderItems'] != null && order['orderItems'].isNotEmpty) {
      for (var item in order['orderItems']) {
        final qty = item['qty'] ?? 0;
        final price = item['currentPrice'] ?? 0.0;
        final itemDiscount = item['discounted'] ?? 0.0;
        
        // Apply item-level discount if available
        final effectivePrice = price - itemDiscount;
        subtotal += qty * effectivePrice;
      }
    }
    
    double total = subtotal;
    
    // Apply voucher discounts if any - now always applying as percentage
    if (order['vouchers'] != null && order['vouchers'].isNotEmpty) {
      for (var voucher in order['vouchers']) {
        final discountValue = voucher['discount'] ?? 0.0;
        final minOrderAmount = voucher['minOrderAmount'] ?? 0.0;
        final maxDiscount = voucher['maxDiscount'];
        
        if (total >= minOrderAmount) {
          // Always apply as percentage regardless of type
          double discountAmount = total * (discountValue / 100);
          
          // Apply max discount cap if specified
          if (maxDiscount != null && discountAmount > maxDiscount) {
            discountAmount = maxDiscount;
          }
          
          discount += discountAmount;
          total -= discountAmount;
        }
      }
    }
    
    if (total < 0) total = 0;
    
    return (subtotal, discount, total);
  }
  
  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }
}