import 'package:flora_manager/models/attribute_group.dart';
import 'package:flora_manager/models/description_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../models/product.dart';
import '../services/description_service_group.dart';
import '../services/attribute_services_group.dart';
import '../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final String title;
  final Product? product;

  const ProductFormScreen({
    super.key,
    required this.title,
    this.product,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isUpdating = false;

  // Controllers cho các trường nhập liệu
  final _plantNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockQtyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  // Danh sách các mô tả sản phẩm
  final List<TextEditingController> _descriptionControllers = [];
  final List<bool> _isExistingDescription = [];
  final List<int?> _descriptionIds = [];
  
  // Danh sách các thuộc tính sản phẩm
  final List<Map<String, dynamic>> _attributeControllers = [];

  // Data từ API
  List<DescriptionGroupDTO> _descriptionGroups = [];
  List<AttributeGroupDTO> _attributeGroups = [];

  @override
  void initState() {
    super.initState();
    _isUpdating = widget.product != null;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // Tải danh sách nhóm mô tả
      final descriptionGroupsData = await DescriptionGroupService.getDescriptionGroups();
      if (descriptionGroupsData != null) {
        _descriptionGroups = descriptionGroupsData
            .map((group) => DescriptionGroupDTO.fromJson(group))
            .toList();
      }

      // Tải danh sách nhóm thuộc tính
      final attributeGroupsData = await AttributeGroupService.getAttributeGroups();
      if (attributeGroupsData != null) {
        _attributeGroups = attributeGroupsData
            .map((group) => AttributeGroupDTO.fromJson(group))
            .toList();
      }

      if (_isUpdating) {
        _loadProductData();
      } else {
        // Thêm một mô tả trống mặc định
        _addDescriptionField(isExisting: false);
        
        // Thêm một thuộc tính trống mặc định
        _addAttributeField(isExisting: false);
      }
    } catch (e) {
      _showErrorSnackBar('Không thể tải dữ liệu: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockQtyController.dispose();
    _imageUrlController.dispose();
    
    // Giải phóng bộ nhớ cho các controllers
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    
    for (var attribute in _attributeControllers) {
      attribute['nameController']?.dispose();
      attribute['iconController']?.dispose();
    }
    
    super.dispose();
  }

  void _loadProductData() {
    final product = widget.product!;
    
    // Thiết lập giá trị cho các controllers
    _plantNameController.text = product.plant?.name ?? '';
    _priceController.text = product.price?.toString() ?? '0';
    _discountController.text = product.discount?.toString() ?? '0';
    _stockQtyController.text = product.stockQty?.toString() ?? '0';
    _imageUrlController.text = product.plant?.img ?? '';
    
    // Tải các mô tả
    if (product.plant != null && product.plant!.descriptions.isNotEmpty) {
      for (var description in product.plant!.descriptions) {
        final controller = TextEditingController(text: description.name ?? '');
        _descriptionControllers.add(controller);
        _descriptionIds.add(description.id);
        
        // Kiểm tra xem mô tả có thuộc nhóm mô tả nào không
        bool isExisting = false;
        for (var group in _descriptionGroups) {
          for (var desc in group.descriptions) {
            if (desc.id == description.id) {
              isExisting = true;
              break;
            }
          }
          if (isExisting) break;
        }
        _isExistingDescription.add(isExisting);
      }
    } else {
      _addDescriptionField(isExisting: false);
    }
    
    // Tải các thuộc tính
    if (product.plant != null && product.plant!.attributes.isNotEmpty) {
      for (var attribute in product.plant!.attributes) {
        final nameController = TextEditingController(text: attribute.name ?? '');
        final iconController = TextEditingController(text: attribute.icon ?? '');
        
        // Kiểm tra xem thuộc tính có thuộc nhóm thuộc tính nào không
        bool isExisting = false;
        AttributeGroupDTO? selectedGroup;
        for (var group in _attributeGroups) {
          for (var attr in group.attributes) {
            if (attr.id == attribute.id) {
              isExisting = true;
              selectedGroup = group;
              break;
            }
          }
          if (isExisting) break;
        }
        
        _attributeControllers.add({
          'nameController': nameController,
          'iconController': iconController,
          'id': attribute.id,
          'isExisting': isExisting,
          'selectedGroup': selectedGroup,
          'selectedAttribute': isExisting ? attribute : null,
        });
      }
    } else {
      _addAttributeField(isExisting: false);
    }
  }

  void _addDescriptionField({required bool isExisting, DescriptionGroupDTO? group, dynamic description}) {
    setState(() {
      final controller = TextEditingController();
      if (isExisting && description != null) {
        controller.text = description.name ?? '';
      }
      
      _descriptionControllers.add(controller);
      _isExistingDescription.add(isExisting);
      _descriptionIds.add(isExisting ? description?.id : null);
    });
  }

  void _removeDescriptionField(int index) {
    setState(() {
      _descriptionControllers[index].dispose();
      _descriptionControllers.removeAt(index);
      _isExistingDescription.removeAt(index);
      _descriptionIds.removeAt(index);
    });
  }

  void _addAttributeField({required bool isExisting, AttributeGroupDTO? group, dynamic attribute}) {
    setState(() {
      final nameController = TextEditingController();
      final iconController = TextEditingController();
      
      if (isExisting && attribute != null) {
        nameController.text = attribute.name ?? '';
        iconController.text = attribute.icon ?? '';
      }
      
      _attributeControllers.add({
        'nameController': nameController,
        'iconController': iconController,
        'id': isExisting ? attribute?.id : null,
        'isExisting': isExisting,
        'selectedGroup': group,
        'selectedAttribute': isExisting ? attribute : null,
      });
    });
  }

  void _removeAttributeField(int index) {
    setState(() {
      _attributeControllers[index]['nameController']?.dispose();
      _attributeControllers[index]['iconController']?.dispose();
      _attributeControllers.removeAt(index);
    });
  }

  // The error is in the _saveProduct method where you're handling IDs
// Here's the corrected version of that method:

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Xây dựng danh sách mô tả
      final descriptions = [];
      for (int i = 0; i < _descriptionControllers.length; i++) {
        if (_descriptionControllers[i].text.isNotEmpty) {
          final descData = {
            'name': _descriptionControllers[i].text,
          };
          
          // Thêm ID nếu đây là mô tả đã tồn tại
          if (_isExistingDescription[i] && _descriptionIds[i] != null) {
            // Fix: Convert int to String if needed or keep the original type
            descData['id'] = _descriptionIds[i]?.toString() ?? '';
          }
          
          descriptions.add(descData);
        }
      }
      
      // Xây dựng danh sách thuộc tính
      final attributes = [];
      for (var attribute in _attributeControllers) {
        if (attribute['nameController'].text.isNotEmpty) {
          final attrData = {
            'name': attribute['nameController'].text,
            'icon': attribute['iconController'].text,
          };
          
          // Thêm ID nếu đây là thuộc tính đã tồn tại
          if (attribute['isExisting'] && attribute['id'] != null) {
            // Fix: Use the ID with its original type, not as a casted String
            attrData['id'] = attribute['id'];
          }
          
          attributes.add(attrData);
        }
      }

      // Xây dựng đối tượng Plant
      final plantData = {
        'name': _plantNameController.text,
        'img': _imageUrlController.text,
        'descriptions': descriptions,
        'attributes': attributes,
      };

      // Thêm ID nếu đang cập nhật Plant
      if (_isUpdating && widget.product?.plant?.id != null) {
        // Fix: Keep the original type of the ID
        plantData['id'] = widget.product!.plant!.id as Object;
      }

      // Xây dựng đối tượng Product
      final productData = {
        'plant': plantData,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'discount': double.tryParse(_discountController.text) ?? 0.0,
        'stockQty': int.tryParse(_stockQtyController.text) ?? 0,
        'isDeleted': false,
        'soldQty': _isUpdating ? (widget.product?.soldQty ?? 0) : 0,
      };

      // Thêm ID nếu đang cập nhật Product
      if (_isUpdating && widget.product?.id != null) {
        // Fix: Keep the original type of the ID
        productData['id'] = widget.product!.id as Object;
      }

      Map<String, dynamic>? result;
      if (_isUpdating) {
        // Cập nhật sản phẩm
        result = await ProductService.updateProduct(
          widget.product!.id!,
          productData,
        );
      } else {
        // Thêm sản phẩm mới
        result = await ProductService.addProduct(productData);
      }

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        if (!mounted) return;
        Navigator.pop(context, true); // Trả về true để báo thành công
      } else {
        _showErrorSnackBar(
          _isUpdating ? 'Không thể cập nhật sản phẩm' : 'Không thể thêm sản phẩm',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Lỗi: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveProduct,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.save, color: AppColors.primary),
            label: const Text(
              'Lưu',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin cơ bản của sản phẩm
                    const Text(
                      'Thông tin sản phẩm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Tên cây
                    TextFormField(
                      controller: _plantNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên cây *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.eco),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên cây';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // URL hình ảnh
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL hình ảnh',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Dòng chứa giá và chiết khấu
                    Row(
                      children: [
                        // Giá
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Giá (VNĐ) *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập giá';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Chiết khấu
                        Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Chiết khấu (%)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.discount),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Số lượng tồn kho
                    TextFormField(
                      controller: _stockQtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Số lượng tồn kho *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số lượng tồn kho';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Phần mô tả sản phẩm
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mô tả sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showAddDescriptionDialog(),
                              icon: const Icon(Icons.list),
                              label: const Text('Chọn mô tả'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _addDescriptionField(isExisting: false),
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm mới'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Danh sách các trường mô tả
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _descriptionControllers.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          color: _isExistingDescription[index] ? AppColors.lightGreen : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                if (_isExistingDescription[index])
                                  const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                                Expanded(
                                  child: TextFormField(
                                    controller: _descriptionControllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Mô tả ${index + 1}',
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.description),
                                      enabled: !_isExistingDescription[index],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    if (_descriptionControllers.length > 1) {
                                      _removeDescriptionField(index);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Cần ít nhất một mô tả'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Phần thuộc tính sản phẩm
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thuộc tính sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showAddAttributeDialog(),
                              icon: const Icon(Icons.list),
                              label: const Text('Chọn thuộc tính'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _addAttributeField(isExisting: false),
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm mới'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Danh sách các trường thuộc tính
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _attributeControllers.length,
                      itemBuilder: (context, index) {
                        final attribute = _attributeControllers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          color: attribute['isExisting'] ? AppColors.lightGreen : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (attribute['isExisting'])
                                      const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                                    Text(
                                      attribute['isExisting']
                                          ? 'Thuộc tính có sẵn từ: ${attribute['selectedGroup']?.name ?? "Không xác định"}'
                                          : 'Thuộc tính mới',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        if (_attributeControllers.length > 1) {
                                          _removeAttributeField(index);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Cần ít nhất một thuộc tính'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: attribute['nameController'],
                                  decoration: const InputDecoration(
                                    labelText: 'Tên thuộc tính',
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: !attribute['isExisting'],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: attribute['iconController'],
                                  decoration: const InputDecoration(
                                    labelText: 'Icon thuộc tính (URL)',
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: !attribute['isExisting'],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Nút lưu ở cuối form
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                _isUpdating ? 'Cập nhật sản phẩm' : 'Thêm sản phẩm',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showAddDescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn mô tả có sẵn'),
          content: SizedBox(
            width: double.maxFinite,
            child: _descriptionGroups.isEmpty
                ? const Center(child: Text('Không có mô tả nào có sẵn'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _descriptionGroups.length,
                    itemBuilder: (context, groupIndex) {
                      final group = _descriptionGroups[groupIndex];
                      return ExpansionTile(
                        title: Text(group.name ?? 'Nhóm không tên'),
                        children: group.descriptions.map((description) {
                          return ListTile(
                            title: Text(description.name ?? ''),
                            leading: const Icon(Icons.description),
                            onTap: () {
                              _addDescriptionField(
                                isExisting: true,
                                group: group,
                                description: description,
                              );
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _showAddAttributeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn thuộc tính có sẵn'),
          content: SizedBox(
            width: double.maxFinite,
            child: _attributeGroups.isEmpty
                ? const Center(child: Text('Không có thuộc tính nào có sẵn'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _attributeGroups.length,
                    itemBuilder: (context, groupIndex) {
                      final group = _attributeGroups[groupIndex];
                      return ExpansionTile(
                        title: Text(group.name ?? 'Nhóm không tên'),
                        leading: group.icon != null && group.icon!.isNotEmpty
                            ? Image.network(
                                group.icon!,
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              )
                            : const Icon(Icons.category),
                        children: group.attributes.map((attribute) {
                          return ListTile(
                            title: Text(attribute.name ?? ''),
                            leading: attribute.icon != null && attribute.icon!.isNotEmpty
                                ? Image.network(
                                    attribute.icon!,
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.auto_awesome),
                            onTap: () {
                              _addAttributeField(
                                isExisting: true,
                                group: group,
                                attribute: attribute,
                              );
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}