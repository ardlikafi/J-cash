import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:j_cash/providers/category_provider.dart';

class CategorySelector extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String? selectedCategoryId;
  final bool isExpense;

  const CategorySelector({
    Key? key,
    required this.onCategorySelected,
    this.selectedCategoryId,
    required this.isExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = isExpense
            ? categoryProvider.expenseCategories
            : categoryProvider.incomeCategories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showCategoryPicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    if (selectedCategoryId != null)
                      Container(
                        decoration: BoxDecoration(
                          color: categoryProvider
                              .getCategoryById(selectedCategoryId!)
                              ?.iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          categoryProvider
                                  .getCategoryById(selectedCategoryId!)
                                  ?.iconPath ??
                              '',
                          height: 24,
                          width: 24,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.category_outlined, size: 24),
                        ),
                      )
                    else
                      Icon(
                        Icons.category_outlined,
                        size: 24,
                        color: Colors.grey.shade600,
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedCategoryId != null
                            ? categoryProvider
                                    .getCategoryById(selectedCategoryId!)
                                    ?.name ??
                                'Pilih Kategori'
                            : 'Pilih Kategori',
                        style: TextStyle(
                          fontSize: 15,
                          color: selectedCategoryId == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            final categories = isExpense
                ? categoryProvider.expenseCategories
                : categoryProvider.incomeCategories;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                        const Text(
                          'Pilih Kategori',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40), // Untuk balance
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        bool isSelected = selectedCategoryId == category.id;
                        return InkWell(
                          onTap: () {
                            onCategorySelected(category.id);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade200,
                                width: isSelected ? 1.8 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: category.iconBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Image.asset(
                                    category.iconPath,
                                    height: 22,
                                    width: 22,
                                    errorBuilder: (c, e, s) => const Icon(
                                        Icons.category_outlined,
                                        size: 22),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : 15,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
