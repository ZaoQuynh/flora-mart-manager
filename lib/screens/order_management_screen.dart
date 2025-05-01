// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import '../widgets/order_list.dart';
import '../services/order_service.dart';
import '../widgets/order_status.dart';
import '../widgets/filter_section.dart';
import '../widgets/pagination_controls.dart';
import '../app_colors.dart';

class OrderManagementScreen extends StatefulWidget {
  final List<dynamic> orders;
  final bool shouldFetchOrders;

  const OrderManagementScreen({
    super.key,
    required this.orders,
    this.shouldFetchOrders = true,
  });

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  List<dynamic> _allOrders = [];
  List<dynamic> _filteredOrders = [];
  List<dynamic> _displayedOrders = [];
  bool _isLoading = false;
  String? _error;

  // Pagination
  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalPages = 0;
  
  // Filter values
  OrderStatus? _statusFilter;
  DateTimeRange? _dateFilter;
  String? _searchQuery;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    if (widget.shouldFetchOrders) {
      _fetchOrders();
    } else {
      _processInitialOrders();
    }
  }

  void _processInitialOrders() {
    setState(() {
      _allOrders = widget.orders;
      _applyFilters();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await OrderService.getAllOrders();
      setState(() {
        _allOrders = orders ?? [];
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    // Apply all filters
    _filteredOrders = _allOrders.where((order) {
      bool matchesStatus = true;
      bool matchesDate = true;
      bool matchesSearch = true;
      
      // Filter by status
      if (_statusFilter != null) {
        matchesStatus = order['status'] == _statusFilter.toString().split('.').last;
      }
      
      // Filter by date range
      if (_dateFilter != null) {
        final orderDate = DateTime.parse(order['createDate']);
        matchesDate = (orderDate.isAfter(_dateFilter!.start) || 
                      orderDate.isAtSameMomentAs(_dateFilter!.start)) && 
                      (orderDate.isBefore(_dateFilter!.end) || 
                      orderDate.isAtSameMomentAs(_dateFilter!.end));
      }
      
      // Filter by search (customer name or order ID)
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final orderId = order['id'].toString();
        final customerName = order['customer']?['fullName']?.toString().toLowerCase() ?? '';
        matchesSearch = orderId.contains(_searchQuery!) || 
                       customerName.contains(_searchQuery!.toLowerCase());
      }
      
      return matchesStatus && matchesDate && matchesSearch;
    }).toList();
    
    // Sort by date (newest first)
    _filteredOrders.sort((a, b) {
      final dateA = DateTime.parse(a['createDate']);
      final dateB = DateTime.parse(b['createDate']);
      return dateB.compareTo(dateA);
    });
    
    // Calculate total pages
    _totalPages = (_filteredOrders.length / _pageSize).ceil();
    
    // Ensure current page is valid
    if (_currentPage >= _totalPages) {
      _currentPage = _totalPages > 0 ? _totalPages - 1 : 0;
    }
    
    // Apply pagination
    _updateDisplayedOrders();
  }
  
  void _updateDisplayedOrders() {
    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;
    
    if (_filteredOrders.isEmpty) {
      _displayedOrders = [];
    } else {
      _displayedOrders = _filteredOrders.sublist(
        startIndex, 
        endIndex < _filteredOrders.length ? endIndex : _filteredOrders.length
      );
    }
  }

  Future<void> _updateStatus(int orderId, OrderStatus newStatus) async {
    try {
      final result = await OrderService.updateOrderStatus(orderId);

      if (result != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật trạng thái thành ${newStatus.displayName}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (widget.shouldFetchOrders) {
          await _fetchOrders(); // reload from server
        } else {
          // Update in local list
          setState(() {
            for (var i = 0; i < _allOrders.length; i++) {
              if (_allOrders[i]['id'] == orderId) {
                _allOrders[i]['status'] = newStatus.toString().split('.').last;
                break;
              }
            }
            _applyFilters();
          });
        }
      } else {
        throw 'Không thể cập nhật trạng thái';
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _dateFilter ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateFilter = picked;
        _applyFilters();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _dateFilter = null;
      _searchQuery = null;
      _searchController.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý đơn hàng'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchOrders,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Quản lý đơn hàng',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: widget.shouldFetchOrders ? _fetchOrders : null,
            tooltip: 'Làm mới dữ liệu',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.shouldFetchOrders ? _fetchOrders : () async {},
        child: Column(
          children: [
            FilterSection(
              searchController: _searchController,
              dateFilter: _dateFilter,
              statusFilter: _statusFilter,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
              onDateFilterTap: _showDateRangePicker,
              onStatusSelected: (status) {
                setState(() {
                  _statusFilter = status;
                  _applyFilters();
                });
              },
              onClearFilters: _clearFilters,
            ),
            const Divider(height: 1),
            Expanded(
              child: _filteredOrders.isEmpty
                  ? const Center(child: Text('Không có đơn hàng nào'))
                  : OrderList(
                      orders: _displayedOrders,
                      onUpdateStatus: _updateStatus,
                    ),
            ),
            PaginationControls(
              currentPage: _currentPage,
              totalPages: _totalPages,
              filteredOrdersCount: _filteredOrders.length,
              displayedOrdersCount: _displayedOrders.length,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                  _updateDisplayedOrders();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}