import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;
  final List<dynamic>? vouchers;

  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.vouchers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin thanh toán',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tạm tính:'),
              Text(_formatCurrency(subtotal)),
            ],
          ),
          if (discount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Giảm giá:'),
                Text(
                  '- ${_formatCurrency(discount)}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ],
          if (vouchers != null && vouchers!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Vouchers áp dụng:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            ...vouchers!.map((voucher) => _buildVoucherItem(voucher)).toList(),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _formatCurrency(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherItem(dynamic voucher) {
    final discountValue = voucher['discount'] ?? 0.0;
    final code = voucher['code'] ?? '';
    final name = voucher['name'] ?? 'Voucher';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.discount_outlined, size: 14, color: Colors.amber.shade800),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '$name${code.isNotEmpty ? ' ($code)' : ''}',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '-${discountValue.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }
}