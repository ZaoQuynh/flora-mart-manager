import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int filteredOrdersCount;
  final int displayedOrdersCount;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.filteredOrdersCount,
    required this.displayedOrdersCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredOrdersCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hiển thị $displayedOrdersCount / $filteredOrdersCount đơn hàng',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_left),
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                tooltip: 'Trang trước',
              ),
              Text(
                '${currentPage + 1}/$totalPages',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_right),
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: 'Trang sau',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PageNumberControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int maxVisiblePages;

  const PageNumberControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxVisiblePages = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    // Calculate visible page range
    final int halfVisible = (maxVisiblePages ~/ 2);
    int startPage = currentPage - halfVisible;
    int endPage = currentPage + halfVisible;

    // Adjust if out of bounds
    if (startPage < 0) {
      endPage += (0 - startPage);
      startPage = 0;
    }
    if (endPage >= totalPages) {
      startPage -= (endPage - totalPages + 1);
      endPage = totalPages - 1;
    }
    
    // Ensure startPage is never negative
    startPage = startPage < 0 ? 0 : startPage;

    // Build page number widgets
    List<Widget> pageNumberWidgets = [];

    // First page and ellipsis if necessary
    if (startPage > 0) {
      pageNumberWidgets.add(_buildPageNumberButton(0));
      if (startPage > 1) {
        pageNumberWidgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }
    }

    // Visible page numbers
    for (int i = startPage; i <= endPage && i < totalPages; i++) {
      pageNumberWidgets.add(_buildPageNumberButton(i));
    }

    // Last page and ellipsis if necessary
    if (endPage < totalPages - 1) {
      if (endPage < totalPages - 2) {
        pageNumberWidgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }
      pageNumberWidgets.add(_buildPageNumberButton(totalPages - 1));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pageNumberWidgets,
    );
  }

  Widget _buildPageNumberButton(int pageNumber) {
    final bool isCurrentPage = pageNumber == currentPage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: isCurrentPage ? null : () => onPageChanged(pageNumber),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCurrentPage ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${pageNumber + 1}',
            style: TextStyle(
              color: isCurrentPage ? Colors.white : Colors.black87,
              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// Alternative pagination style with page numbers
class AdvancedPaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int filteredOrdersCount;
  final int displayedOrdersCount;
  final Function(int) onPageChanged;

  const AdvancedPaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.filteredOrdersCount,
    required this.displayedOrdersCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredOrdersCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hiển thị $displayedOrdersCount / $filteredOrdersCount đơn hàng',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_double_arrow_left),
                    onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                    tooltip: 'Trang đầu',
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_left),
                    onPressed: currentPage > 0
                        ? () => onPageChanged(currentPage - 1)
                        : null,
                    tooltip: 'Trang trước',
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${currentPage + 1}/$totalPages',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_right),
                    onPressed: currentPage < totalPages - 1
                        ? () => onPageChanged(currentPage + 1)
                        : null,
                    tooltip: 'Trang sau',
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_double_arrow_right),
                    onPressed: currentPage < totalPages - 1
                        ? () => onPageChanged(totalPages - 1)
                        : null,
                    tooltip: 'Trang cuối',
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          if (totalPages > 2)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: PageNumberControls(
                currentPage: currentPage,
                totalPages: totalPages,
                onPageChanged: onPageChanged,
              ),
            ),
        ],
      ),
    );
  }
}