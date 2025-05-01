// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum OrderStatus {
  NEW,
  CONFIRMED,
  PREPARING,
  SHIPPING,
  SHIPPED,
  DELIVERED,
  CANCELED
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.NEW:
        return 'Mới';
      case OrderStatus.CONFIRMED:
        return 'Đã xác nhận';
      case OrderStatus.PREPARING:
        return 'Đang chuẩn bị';
      case OrderStatus.SHIPPING:
        return 'Đang giao';
      case OrderStatus.SHIPPED:
        return 'Đã vận chuyển';
      case OrderStatus.DELIVERED:
        return 'Đã giao';
      case OrderStatus.CANCELED:
        return 'Đã huỷ';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.NEW:
        return Colors.blue;
      case OrderStatus.CONFIRMED:
        return Colors.amber;
      case OrderStatus.PREPARING:
        return Colors.orange;
      case OrderStatus.SHIPPING:
        return Colors.deepPurple;
      case OrderStatus.SHIPPED:
        return Colors.indigo;
      case OrderStatus.DELIVERED:
        return Colors.green;
      case OrderStatus.CANCELED:
        return Colors.red;
    }
  }

  List<OrderStatus> get allowedTransitions {
    switch (this) {
      case OrderStatus.NEW:
        return [OrderStatus.CONFIRMED, OrderStatus.CANCELED];
      case OrderStatus.CONFIRMED:
        return [OrderStatus.PREPARING, OrderStatus.CANCELED];
      case OrderStatus.PREPARING:
        return [OrderStatus.SHIPPING, OrderStatus.CANCELED];
      case OrderStatus.SHIPPING:
        return [OrderStatus.SHIPPED, OrderStatus.CANCELED];
      case OrderStatus.SHIPPED:
        return [OrderStatus.DELIVERED, OrderStatus.CANCELED];
      case OrderStatus.DELIVERED:
        return [];
      case OrderStatus.CANCELED:
        return [];
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => OrderStatus.NEW,
    );
  }
}

class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  
  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color, width: 1),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class StatusUpdateSection extends StatelessWidget {
  final OrderStatus currentStatus;
  final Function(int, OrderStatus) onUpdateStatus;
  final int orderId;
  
  const StatusUpdateSection({
    super.key, 
    required this.currentStatus,
    required this.onUpdateStatus,
    required this.orderId,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cập nhật trạng thái:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: currentStatus.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Hiện tại: ${currentStatus.displayName}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: currentStatus.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (currentStatus.allowedTransitions.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: currentStatus.allowedTransitions
                .where((status) => status != OrderStatus.CANCELED) // Remove cancel option
                .map((nextStatus) {
              String buttonText;
              IconData iconData;
              
              // Customize button based on transition type
              if (currentStatus == OrderStatus.NEW && nextStatus == OrderStatus.CONFIRMED) {
                buttonText = 'Xác nhận đơn';
                iconData = Icons.check_circle_outline;
              } else if (currentStatus == OrderStatus.CONFIRMED && nextStatus == OrderStatus.PREPARING) {
                buttonText = 'Bắt đầu chuẩn bị';
                iconData = Icons.inventory_2_outlined;
              } else if (currentStatus == OrderStatus.PREPARING && nextStatus == OrderStatus.SHIPPING) {
                buttonText = 'Bắt đầu giao hàng';
                iconData = Icons.local_shipping_outlined;
              } else if (currentStatus == OrderStatus.SHIPPING && nextStatus == OrderStatus.SHIPPED) {
                buttonText = 'Đánh dấu đã vận chuyển';
                iconData = Icons.move_to_inbox_outlined;
              } else if (nextStatus == OrderStatus.DELIVERED) {
                buttonText = 'Đánh dấu đã giao';
                iconData = Icons.task_alt_outlined;
              } else {
                buttonText = 'Chuyển sang ${nextStatus.displayName}';
                iconData = Icons.arrow_forward;
              }
              
              return ElevatedButton.icon(
                icon: Icon(iconData, size: 18),
                label: Text(buttonText),
                onPressed: () => onUpdateStatus(orderId, nextStatus),
                style: ElevatedButton.styleFrom(
                  backgroundColor: nextStatus.color.withOpacity(0.1),
                  foregroundColor: nextStatus.color,
                  elevation: 0,
                  side: BorderSide(color: nextStatus.color.withOpacity(0.5)),
                ),
              );
            }).toList(),
          )
        else
          const Text(
            'Không có hành động nào có thể thực hiện cho trạng thái này.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
      ],
    );
  }
}