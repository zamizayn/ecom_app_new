import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ecom/shared/models/product.dart';
import 'package:ecom/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum SortOption { relevance, priceLowHigh, priceHighLow, ratingHighLow, nameAZ }

extension SortLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.relevance:      return 'Relevance';
      case SortOption.priceLowHigh:   return 'Price: Low → High';
      case SortOption.priceHighLow:   return 'Price: High → Low';
      case SortOption.ratingHighLow:  return 'Top Rated';
      case SortOption.nameAZ:         return 'Name: A → Z';
    }
  }
}

// ── Route payload ──────────────────────────────────────────────────────────────

class ProductsListingArgs {
  final String title;
  final List<Product> products;
  const ProductsListingArgs({required this.title, required this.products});
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class ProductsListingScreen extends StatefulWidget {
  final String title;
  final List<Product> allProducts;

  const ProductsListingScreen({
    super.key,
    required this.title,
    required this.allProducts,
  });

  @override
  State<ProductsListingScreen> createState() => _ProductsListingScreenState();
}

class _ProductsListingScreenState extends State<ProductsListingScreen> {
  // ── filter state ──────────────────────────────────────────────────────────
  SortOption _sort = SortOption.relevance;
  double _minRating = 0;
  RangeValues _priceRange = const RangeValues(0, 2000);
  bool _isGridView = true;

  double get _maxPrice {
    if (widget.allProducts.isEmpty) return 2000;
    return widget.allProducts
        .map((p) => p.price)
        .reduce((a, b) => a > b ? a : b)
        .ceilToDouble();
  }

  List<Product> get _filtered {
    var list = widget.allProducts.where((p) {
      return p.price >= _priceRange.start &&
          p.price <= _priceRange.end &&
          p.rating >= _minRating;
    }).toList();

    switch (_sort) {
      case SortOption.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingHighLow:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.nameAZ:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.relevance:
        break;
    }
    return list;
  }

  // ── Sort bottom sheet ─────────────────────────────────────────────────────
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sort By',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...SortOption.values.map((opt) {
                return RadioListTile<SortOption>(
                  title: Text(opt.label),
                  value: opt,
                  groupValue: _sort,
                  activeColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onChanged: (v) {
                    setState(() => _sort = v!);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ── Filter bottom sheet ───────────────────────────────────────────────────
  void _showFilterSheet() {
    // Local copies so changes only apply on "Apply"
    double localMin = _minRating;
    RangeValues localPrice = _priceRange;
    final maxP = _maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Clear
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filters',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          localMin = 0;
                          localPrice = RangeValues(0, maxP);
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const Divider(),

                // Price Range
                const Text('Price Range',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${localPrice.start.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12)),
                    Text('\$${localPrice.end.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                RangeSlider(
                  values: localPrice,
                  min: 0,
                  max: maxP,
                  divisions: 20,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (v) => setSheetState(() => localPrice = v),
                ),

                const SizedBox(height: 8),
                // Min Rating
                const Text('Minimum Rating',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [1, 2, 3, 4].map((r) {
                    final selected = localMin == r.toDouble();
                    return GestureDetector(
                      onTap: () => setSheetState(
                          () => localMin = selected ? 0 : r.toDouble()),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star,
                                size: 14,
                                color: selected ? Colors.white : Colors.amber),
                            const SizedBox(width: 4),
                            Text('$r+',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: selected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _minRating = localMin;
                        _priceRange = localPrice;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(0, _maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final products = _filtered;
    final hasActiveFilters = _minRating > 0 ||
        _priceRange.start > 0 ||
        _priceRange.end < _maxPrice;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter/Sort bar ────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Sort button
                _BarButton(
                  icon: Icons.sort_rounded,
                  label: _sort == SortOption.relevance
                      ? 'Sort'
                      : _sort.label.split(':').first,
                  isActive: _sort != SortOption.relevance,
                  onTap: _showSortSheet,
                  primary: primary,
                ),
                const SizedBox(width: 10),
                // Filter button
                _BarButton(
                  icon: Icons.tune_rounded,
                  label: hasActiveFilters ? 'Filtered' : 'Filter',
                  isActive: hasActiveFilters,
                  onTap: _showFilterSheet,
                  primary: primary,
                ),
                const Spacer(),
                Text(
                  '${products.length} results',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Product grid / list ────────────────────────────────────────
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No products match your filters',
                            style: TextStyle(color: Colors.grey[500])),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() {
                            _minRating = 0;
                            _priceRange = RangeValues(0, _maxPrice);
                            _sort = SortOption.relevance;
                          }),
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  )
                : _isGridView
                    ? _GridBody(products: products)
                    : _ListBody(products: products),
          ),
        ],
      ),
    );
  }
}

// ── Grid layout ───────────────────────────────────────────────────────────────

class _GridBody extends StatelessWidget {
  final List<Product> products;
  const _GridBody({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          _ProductTile(product: products[index], isGrid: true),
    );
  }
}

// ── List layout ───────────────────────────────────────────────────────────────

class _ListBody extends StatelessWidget {
  final List<Product> products;
  const _ListBody({required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _ProductTile(product: products[index], isGrid: false),
    );
  }
}

// ── Product tile (grid & list mode) ──────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final Product product;
  final bool isGrid;
  const _ProductTile({required this.product, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => context.push('/product', extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: isGrid ? _GridCard(product: product, primary: primary)
                      : _ListCard(product: product, primary: primary),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final Product product;
  final Color primary;
  const _GridCard({required this.product, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              // Wishlist
              Positioned(
                top: 8,
                right: 8,
                child: _WishButton(product: product),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Row(children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text('${product.rating}',
                        style: const TextStyle(fontSize: 11)),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
  final Product product;
  final Color primary;
  const _ListCard({required this.product, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Image
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${product.rating}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    _WishButton(product: product),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

// ── Wishlist toggle button ────────────────────────────────────────────────────

class _WishButton extends StatelessWidget {
  final Product product;
  const _WishButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, state) {
        final isWishlisted = state.items.contains(product);
        return GestureDetector(
          onTap: () =>
              context.read<WishlistBloc>().add(ToggleWishlistItem(product)),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1), blurRadius: 4),
              ],
            ),
            child: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: isWishlisted ? Colors.red : Colors.grey[400],
            ),
          ),
        );
      },
    );
  }
}

// ── Bar chip button ───────────────────────────────────────────────────────────

class _BarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color primary;

  const _BarButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? primary.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? primary : Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16, color: isActive ? primary : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: isActive ? primary : Colors.grey[700],
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
