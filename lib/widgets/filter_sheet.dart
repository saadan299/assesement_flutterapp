import 'package:flutter/material.dart';
import '../blocs/product_list/product_list_event.dart';
import '../blocs/product_list/product_list_state.dart';
import '../theme/app_theme.dart';

enum FilterSheetSection { sort, category }

class FilterSheet extends StatefulWidget {
  final ProductSortOption initialSort;
  final String? initialCategory;
  final List<String> availableCategories;
  final FilterSheetSection initialSection;
  final Future<int> Function(String? category) countResults;

  const FilterSheet({
    super.key,
    required this.initialSort,
    required this.initialCategory,
    required this.availableCategories,
    required this.countResults,
    this.initialSection = FilterSheetSection.sort,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterSheetSection _section = widget.initialSection;
  late ProductSortOption _sortBy = widget.initialSort;
  late String? _category = widget.initialCategory;
  late Future<int> _resultCount;
  final _counts = <String?, int>{};

  @override
  void initState() {
    super.initState();
    _resultCount = _loadCount(_category);
  }

  Future<int> _loadCount(String? category) async {
    if (_counts.containsKey(category)) return _counts[category]!;
    final count = await widget
        .countResults(category)
        .timeout(const Duration(seconds: 15));
    _counts[category] = count;
    return count;
  }

  void _selectCategory(String? category) {
    setState(() {
      _category = category;
      _resultCount = _loadCount(category);
    });
  }

  void _clearAll() {
    setState(() {
      _sortBy = ProductSortOption.relevance;
      _category = null;
      _resultCount = _loadCount(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        height: mediaHeight * 0.82,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.cardBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort & Filter',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.cardBorder),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 128,
                    child: Container(
                      color: theme.scaffoldBackgroundColor,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          _SectionTab(
                            label: 'Sort By',
                            active: _section == FilterSheetSection.sort,
                            hasDot: _sortBy != ProductSortOption.relevance,
                            onTap: () => setState(
                              () => _section = FilterSheetSection.sort,
                            ),
                          ),
                          _SectionTab(
                            label: 'Category',
                            active: _section == FilterSheetSection.category,
                            hasDot: _category != null,
                            onTap: () => setState(
                              () => _section = FilterSheetSection.category,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildSectionContent(theme, scheme),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.cardBorder),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: scheme.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(
                        ProductListFiltersApplied(
                          sortBy: _sortBy,
                          category: _category,
                        ),
                      ),
                      child: FutureBuilder<int>(
                        future: _resultCount,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Text('Show results (…)');
                          }
                          if (snapshot.hasError) {
                            return const Tooltip(
                              message:
                                  'Count unavailable. You can still show results.',
                              child: Text('Show results'),
                            );
                          }
                          return Text('Show results (${snapshot.data})');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(ThemeData theme, ColorScheme scheme) {
    switch (_section) {
      case FilterSheetSection.sort:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ProductSortOption.values
              .map(
                (option) => _RadioRow(
                  label: option.label,
                  selected: _sortBy == option,
                  onTap: () => setState(() => _sortBy = option),
                ),
              )
              .toList(),
        );

      case FilterSheetSection.category:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RadioRow(
              label: 'All Categories',
              selected: _category == null,
              onTap: () => _selectCategory(null),
            ),
            if (widget.availableCategories.isEmpty)
              Text(
                'No categories loaded yet.',
                style: theme.textTheme.bodyMedium,
              ),
            ...widget.availableCategories.map(
              (category) => _RadioRow(
                label: category
                    .split('-')
                    .map(
                      (word) => word.isEmpty
                          ? word
                          : '${word[0].toUpperCase()}${word.substring(1)}',
                    )
                    .join(' '),
                selected: _category == category,
                onTap: () => _selectCategory(category),
              ),
            ),
          ],
        );
    }
  }
}

class _SectionTab extends StatelessWidget {
  final String label;
  final bool active;
  final bool hasDot;
  final VoidCallback onTap;

  const _SectionTab({
    required this.label,
    required this.active,
    required this.hasDot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: active ? scheme.surface : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: active ? scheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: active ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (hasDot)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
