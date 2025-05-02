import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../app_colors.dart';
import '../models/product.dart';
// import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final List<Product> _products = [];
  final List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productsData = await ProductService.getAllProducts();
      if (productsData != null) {
        setState(() {
          _products.clear();
          for (var productData in productsData) {
            _products.add(Product.fromJson(productData));
          }
          _applyFilters();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Không thể tải danh sách sản phẩm');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Lỗi: $e');
    }
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredProducts.clear();
      _filteredProducts.addAll(_products);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredProducts.clear();
      _filteredProducts.addAll(_products.where((product) {
        final plantName = product.plant?.name?.toLowerCase() ?? '';
        final price = product.price?.toString() ?? '';
        return plantName.contains(query) || price.contains(query);
      }));
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductFormScreen(title: 'Thêm sản phẩm'),
      ),
    );

    if (result == true) {
      _showSuccessSnackBar('Thêm sản phẩm thành công');
      _fetchProducts();
    }
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(
          title: 'Sửa sản phẩm',
          product: product,
        ),
      ),
    );

    if (result == true) {
      _showSuccessSnackBar('Cập nhật sản phẩm thành công');
      _fetchProducts();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.plant?.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Thay đổi trạng thái isDeleted thành true thay vì xóa hoàn toàn
        product.isDeleted = true;
        await ProductService.deleteProduct(product.id!);
        
        _showSuccessSnackBar('Xóa sản phẩm thành công');
        _fetchProducts();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Lỗi: $e');
      }
    }
  }

  void _viewProductDetails(Product product) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ProductDetailScreen(product: product),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Quản lý sản phẩm',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _addProduct,
            tooltip: 'Thêm sản phẩm mới',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchProducts,
            tooltip: 'Làm mới danh sách',
          ),
        ],
      ),
      body: Column(
        children: [
          // Phần tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          
          // Kết quả lọc
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Tổng số: ${_filteredProducts.length} sản phẩm',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                // Có thể thêm các bộ lọc khác ở đây nếu cần
              ],
            ),
          ),
          
          // Danh sách sản phẩm
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'Không có sản phẩm nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final name = product.plant?.name ?? 'Không có tên';
    final imageUrl = product.plant?.img ?? '';
    final price = product.price ?? 0.0;
    final discount = product.discount ?? 0.0;
    final stockQty = product.stockQty ?? 0;
    final soldQty = product.soldQty ?? 0;
    
    final hasDiscount = discount > 0;
    final discountedPrice = price - (price * discount / 100);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _viewProductDetails(product),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh sản phẩm
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),
              
              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        hasDiscount
                            ? Row(
                                children: [
                                  Text(
                                    '${discountedPrice.toStringAsFixed(0)} đ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${price.toStringAsFixed(0)} đ',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                '${price.toStringAsFixed(0)} đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                        if (hasDiscount)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${discount.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.inventory, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Tồn kho: $stockQty',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.shopping_bag, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Đã bán: $soldQty',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Menu thao tác
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Thao tác',
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Xem chi tiết'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      _viewProductDetails(product);
                      break;
                    case 'edit':
                      _editProduct(product);
                      break;
                    case 'delete':
                      _deleteProduct(product);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}