import 'package:flutter/material.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _currentRangeValues = const RangeValues(100, 1000);
  String _selectedCategory = 'All';
  String _sortBy = 'Popular';
  String _selectedRating = 'All';

  final List<String> _categories = ['All', 'Rings', 'Bangles', 'Earrings', 'Necklace'];
  final List<String> _sortOptions = ['Popular', 'Newest', 'Price: Low to High', 'Price: High to Low'];
  final List<String> _ratings = ['All', '5★', '4★ & up', '3★ & up'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: Text(
          'Filter',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentRangeValues = const RangeValues(100, 1000);
                _selectedCategory = 'All';
                _sortBy = 'Popular';
                _selectedRating = 'All';
              });
            },
            child: const Text('Reset', style: TextStyle(color: AppTheme.primaryRose)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Category'),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: AppTheme.surfaceWhite,
                  selectedColor: AppTheme.primaryRose,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryRose : Colors.transparent,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Price Range'),
            const SizedBox(height: 15),
            Column(
              children: [
                RangeSlider(
                  values: _currentRangeValues,
                  min: 0,
                  max: 2000,
                  divisions: 20,
                  activeColor: AppTheme.primaryRose,
                  inactiveColor: AppTheme.primaryRose.withValues(alpha: 0.2),
                  labels: RangeLabels(
                    '\$${_currentRangeValues.start.round()}',
                    '\$${_currentRangeValues.end.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRangeValues = values;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${_currentRangeValues.start.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${_currentRangeValues.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Sort By'),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                underline: const SizedBox(),
                items: _sortOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _sortBy = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Customer Rating'),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _ratings.map((rating) {
                final isSelected = _selectedRating == rating;
                return ChoiceChip(
                  label: Text(rating),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRating = rating;
                    });
                  },
                  backgroundColor: AppTheme.surfaceWhite,
                  selectedColor: AppTheme.primaryRose,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryRose : Colors.transparent,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 15,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Apply filter logic
            Navigator.pop(context);
          },
          child: const Text('Apply Filter'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textDark,
      ),
    );
  }
}

