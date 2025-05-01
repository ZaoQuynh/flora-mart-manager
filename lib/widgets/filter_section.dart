import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'order_status.dart';

class FilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final DateTimeRange? dateFilter;
  final OrderStatus? statusFilter;
  final Function(String) onSearchChanged;
  final VoidCallback onDateFilterTap;
  final Function(OrderStatus?) onStatusSelected;
  final VoidCallback onClearFilters;

  const FilterSection({
    super.key,
    required this.searchController,
    required this.dateFilter,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onDateFilterTap,
    required this.onStatusSelected,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          _buildSearchRow(),
          const SizedBox(height: 8),
          _buildStatusFilterRow(),
          if (dateFilter != null) _buildDateFilterIndicator(),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên KH hoặc mã đơn',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              isDense: true,
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: onDateFilterTap,
          tooltip: 'Lọc theo ngày',
          style: IconButton.styleFrom(
            backgroundColor: dateFilter != null ? Colors.blue.shade100 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterRow() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status filter chips
                FilterChip(
                  label: const Text('Tất cả'),
                  selected: statusFilter == null,
                  onSelected: (selected) {
                    if (selected) {
                      onStatusSelected(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ...OrderStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: statusFilter == status,
                      selectedColor: status.color.withOpacity(0.2),
                      checkmarkColor: status.color,
                      onSelected: (selected) {
                        onStatusSelected(selected ? status : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: onClearFilters,
          tooltip: 'Xóa bộ lọc',
        ),
      ],
    );
  }

  Widget _buildDateFilterIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 4),
          Text(
            'Từ ${DateFormat('dd/MM/yyyy').format(dateFilter!.start)} đến ${DateFormat('dd/MM/yyyy').format(dateFilter!.end)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}