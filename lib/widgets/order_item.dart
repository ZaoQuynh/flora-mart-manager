import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderItemsList extends StatelessWidget {
  final dynamic order;

  const OrderItemsList({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Sản phẩm trong đơn:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        if (order['orderItems'] != null && order['orderItems'].isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order['orderItems'].length,
            itemBuilder: (context, idx) {
              final item = order['orderItems'][idx];
              return OrderItemCard(item: item);
            },
          )
        else if (order['items'] != null && order['items'].isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order['items'].length,
            itemBuilder: (context, idx) {
              final item = order['items'][idx];
              return LegacyOrderItemCard(item: item);
            },
          )
        else
          const Text('Không có sản phẩm nào'),
      ],
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final dynamic item;

  const OrderItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final product = item['product'] ?? {};
    final plant = product['plant'] ?? {};
    final productName = plant['name'] ?? 'Sản phẩm không xác định';
    final quantity = item['qty'] ?? 0;
    final price = item['currentPrice'] ?? 0.0;
    final discounted = item['discounted'] ?? 0.0;
    final effectivePrice = price - discounted;
    final total = effectivePrice * quantity;
    final imageUrl = plant['img'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Product image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? const Icon(Icons.image_not_supported, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Text(
                        'SL: $quantity × ',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      if (discounted > 0) ...[
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(effectivePrice),
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Total price
            Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(total),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class LegacyOrderItemCard extends StatelessWidget {
  final dynamic item;

  const LegacyOrderItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final productName = item['product']?['name'] ?? 'Sản phẩm không xác định';
    final quantity = item['quantity'] ?? 0;
    final price = item['price'] ?? 0;
    final total = price * quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                '$quantity',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                productName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(total),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}