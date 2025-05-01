import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import '../widgets/order_status.dart';
import '../widgets/order_item.dart';
import '../widgets/order_summary.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final dynamic initialOrderData;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    this.initialOrderData,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = true;
  dynamic _orderData;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrderData != null) {
      setState(() {
        _orderData = widget.initialOrderData;
        _isLoading = false;
      });
    } else {
      _fetchOrderDetails();
    }
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderDetails = await OrderService.getOrderById(widget.orderId);
      setState(() {
        _orderData = orderDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await OrderService.updateOrderStatus(widget.orderId);

      if (result != null) {
        // Refresh data after update
        await _fetchOrderDetails();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật trạng thái thành ${newStatus.displayName}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw 'Không thể cập nhật trạng thái';
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Chi tiết đơn hàng #${widget.orderId}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chi tiết đơn hàng #${widget.orderId}')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchOrderDetails,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final orderStatus = OrderStatusExtension.fromString(_orderData['status']);
    final customer = _orderData['customer'] ?? {};
    final orderDate = DateTime.parse(_orderData['createDate']);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(orderDate);
    final payment = _orderData['payment'] ?? {};
    final paymentType = payment['type'] ?? 'Không xác định';
    final paymentStatus = payment['status'] ?? 'Không xác định';
    final address = _orderData['address'] ?? 'Không có địa chỉ';
    
    // Calculate totals
    final (subtotal, discount, total) = _calculateOrderAmounts(_orderData);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrderDetails,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status banner
            _buildStatusBanner(orderStatus),
            const SizedBox(height: 20),
            
            // Customer information
            _buildSectionTitle('Thông tin khách hàng'),
            _buildInfoCard([
              _buildInfoRow(Icons.person, 'Tên khách hàng', customer['fullName'] ?? 'Không xác định'),
              _buildInfoRow(Icons.phone, 'Số điện thoại', customer['phoneNumber'] ?? 'Không có'),
              _buildInfoRow(Icons.email, 'Email', customer['email'] ?? 'Không có'),
            ]),
            const SizedBox(height: 20),

            // Order information
            _buildSectionTitle('Thông tin đơn hàng'),
            _buildInfoCard([
              _buildInfoRow(Icons.numbers, 'Mã đơn hàng', '#${widget.orderId}'),
              _buildInfoRow(Icons.calendar_today, 'Ngày đặt hàng', formattedDate),
              _buildInfoRow(Icons.local_shipping, 'Địa chỉ giao hàng', address),
            ]),
            const SizedBox(height: 20),

            // Payment information
            _buildSectionTitle('Thông tin thanh toán'),
            _buildInfoCard([
              _buildInfoRow(Icons.payment, 'Phương thức thanh toán', _formatPaymentType(paymentType)),
              _buildInfoRow(Icons.lock_clock, 'Trạng thái thanh toán', _formatPaymentStatus(paymentStatus)),
            ]),
            const SizedBox(height: 20),

            // Order items
            _buildSectionTitle('Sản phẩm'),
            OrderItemsList(order: _orderData),
            const SizedBox(height: 20),

            // Order summary
            OrderSummary(
              subtotal: subtotal,
              discount: discount,
              total: total,
              vouchers: _orderData['vouchers'],
            ),
            const SizedBox(height: 30),

            // Status update options
            _buildSectionTitle('Cập nhật trạng thái'),
            StatusUpdateSection(
              currentStatus: orderStatus,
              onUpdateStatus: (_, status) => _updateStatus(status),
              orderId: widget.orderId,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(OrderStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(status),
            color: status.color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: status.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getStatusDescription(status),
                  style: TextStyle(
                    color: status.color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.NEW:
        return Icons.fiber_new;
      case OrderStatus.CONFIRMED:
        return Icons.check_circle;
      case OrderStatus.PREPARING:
        return Icons.inventory_2;
      case OrderStatus.SHIPPING:
        return Icons.local_shipping;
      case OrderStatus.SHIPPED:
        return Icons.delivery_dining;
      case OrderStatus.DELIVERED:
        return Icons.task_alt;
      case OrderStatus.CANCELED:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.NEW:
        return 'Đơn hàng mới, chờ xác nhận';
      case OrderStatus.CONFIRMED:
        return 'Đơn hàng đã được xác nhận';
      case OrderStatus.PREPARING:
        return 'Đơn hàng đang được chuẩn bị';
      case OrderStatus.SHIPPING:
        return 'Đơn hàng đang được giao đến khách hàng';
      case OrderStatus.SHIPPED:
        return 'Đơn hàng đã vận chuyển, chờ xác nhận giao hàng';
      case OrderStatus.DELIVERED:
        return 'Đơn hàng đã được giao thành công';
      case OrderStatus.CANCELED:
        return 'Đơn hàng đã bị hủy';
    }
  }

  String _formatPaymentType(String type) {
    switch (type) {
      case 'CASH':
        return 'Tiền mặt khi nhận hàng';
      case 'BANK_TRANSFER':
        return 'Chuyển khoản ngân hàng';
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng';
      case 'MOMO':
        return 'Ví MoMo';
      case 'VNPAY':
        return 'Ví VNPay';
      default:
        return 'Không xác định';
    }
  }

  String _formatPaymentStatus(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'COMPLETED':
        return 'Đã thanh toán';
      case 'FAILED':
        return 'Thanh toán thất bại';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return 'Không xác định';
    }
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
    
    // Apply voucher discounts if any
    if (order['vouchers'] != null && order['vouchers'].isNotEmpty) {
      for (var voucher in order['vouchers']) {
        final discountValue = voucher['discount'] ?? 0.0;
        final minOrderAmount = voucher['minOrderAmount'] ?? 0.0;
        final maxDiscount = voucher['maxDiscount'];
        
        if (total >= minOrderAmount) {
          // Always apply as percentage
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
}