import 'package:flutter/material.dart';
import 'package:j_cash/constants/savings_icons.dart';

class IconPickerDialog extends StatelessWidget {
  final String? selectedIconPath;
  final Color selectedColor;

  const IconPickerDialog({
    super.key,
    this.selectedIconPath,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Ikon',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children:
                        SavingsIcons.icons.map((icon) {
                          final isSelected = icon.path == selectedIconPath;
                          return SizedBox(
                            width: 70,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context, icon.path);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? selectedColor.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? selectedColor
                                            : Colors.grey.withOpacity(0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      icon.path,
                                      height: 24,
                                      width: 24,
                                      color:
                                          isSelected
                                              ? selectedColor
                                              : Colors.black54,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            icon.fallbackIcon,
                                            size: 24,
                                            color:
                                                isSelected
                                                    ? selectedColor
                                                    : Colors.black54,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      icon.name,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            isSelected
                                                ? selectedColor
                                                : Colors.black54,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
