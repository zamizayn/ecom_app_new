import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ecom/shared/models/product.dart';
import 'package:ecom/shared/models/cart_item.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecom/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ecom/features/checkout/bloc/address_bloc.dart';
import 'package:ecom/features/checkout/pages/address_screen.dart';
import 'package:ecom/features/products/presentation/bloc/products_bloc.dart';
import 'package:ecom/features/products/presentation/bloc/products_state.dart';
import '../widgets/pdp_widgets.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  int _selectedColorIndex = 0;
  int _selectedStorageIndex = 0;
  bool _cartAdded = false;

  late final AnimationController _cartAnim;
  late final Animation<double> _cartScale;

  final List<String> _colors = [
    'Desert Titanium',
    'Natural Titanium',
    'White Titanium',
    'Black Titanium',
  ];
  final List<String> _storage = ['256 GB', '512 GB', '1 TB'];
  final List<int> _disabledStorage = [2]; // 1 TB unavailable

  @override
  void initState() {
    super.initState();
    _cartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _cartAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _cartAnim.dispose();
    super.dispose();
  }

  void _addToCart() {
    context.read<CartBloc>().add(AddProductToCart(widget.product));
    _cartAnim.forward(from: 0);
    HapticFeedback.lightImpact();
    setState(() => _cartAdded = true);
    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _cartAdded = false) : null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  void _buyNow() {
    final singleItem = CartItem(product: widget.product, quantity: _quantity);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AddressBloc>(),
          child: AddressScreen(cartItems: [singleItem]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final originalPrice = widget.product.price * 1.15;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      body: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, wishState) {
          final isWishlisted = wishState.items.contains(widget.product);
          return CustomScrollView(
            slivers: [
              // ── SliverAppBar with image carousel ─────────────────────────
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4)
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                ),
                actions: [
                  Center(
                    child: ScaleTransition(
                      scale: _cartScale,
                      child: GestureDetector(
                        onTap: () => context.push('/cart'),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4)
                            ],
                          ),
                          child: Icon(
                            _cartAdded
                                ? Icons.shopping_cart
                                : Icons.shopping_cart_outlined,
                            size: 20,
                            color: _cartAdded ? primary : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Colors.white,
                    child: ImageCarouselWidget(
                      imageUrl: widget.product.imageUrl,
                      productId: widget.product.id,
                      isWishlisted: isWishlisted,
                      badge: widget.product.rating >= 4.5
                          ? 'Best Seller'
                          : 'Limited Stock',
                      onWishlistTap: () => context
                          .read<WishlistBloc>()
                          .add(ToggleWishlistItem(widget.product)),
                      onShareTap: () {},
                    ),
                  ),
                ),
              ),

              // ── Content ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Product info card ─────────────────────────────────
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            widget.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          // Brand + Rating row
                          Row(
                            children: [
                              Text('By Brand',
                                  style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13)),
                              const SizedBox(width: 12),
                              const Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 3),
                              Text('${widget.product.rating}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              Text(' (2.2k reviews)',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Price
                          PriceSection(
                              price: widget.product.price,
                              originalPrice: originalPrice),
                          const SizedBox(height: 14),

                          // USP chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '✨ ${widget.product.description.split('.').first}.',
                              style: TextStyle(
                                  color: primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Trust signals ─────────────────────────────────────
                    SectionCard(child: const TrustSignals()),

                    // ── Delivery checker ──────────────────────────────────
                    const SectionCard(child: DeliveryChecker()),

                    // ── Variants ──────────────────────────────────────────
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VariantSelector(
                            title: 'Color',
                            options: _colors,
                            selectedIndex: _selectedColorIndex,
                            onSelect: (i) =>
                                setState(() => _selectedColorIndex = i),
                          ),
                          const SizedBox(height: 20),
                          VariantSelector(
                            title: 'Storage',
                            options: _storage,
                            selectedIndex: _selectedStorageIndex,
                            disabledIndices: _disabledStorage,
                            onSelect: (i) =>
                                setState(() => _selectedStorageIndex = i),
                          ),
                          const SizedBox(height: 16),

                          // Qty selector
                          Row(
                            children: [
                              const Text('Quantity',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[200]!),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        if (_quantity > 1)
                                          setState(() => _quantity--);
                                      },
                                    ),
                                    Text('$_quantity',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    IconButton(
                                      icon: Icon(Icons.add,
                                          size: 16, color: primary),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      constraints: const BoxConstraints(),
                                      onPressed: () =>
                                          setState(() => _quantity++),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Offers ────────────────────────────────────────────
                    SectionCard(child: const OffersSection()),

                    // ── Description ───────────────────────────────────────
                    SectionCard(
                      child: DescriptionSection(
                          description: widget.product.description),
                    ),

                    // ── Reviews ───────────────────────────────────────────
                    SectionCard(
                      child: ReviewsSection(rating: widget.product.rating),
                    ),

                    // ── Recommended ───────────────────────────────────────
                    BlocBuilder<ProductsBloc, ProductsState>(
                      builder: (context, state) {
                        if (state is HomeDataLoaded &&
                            state.recommendedProducts.isNotEmpty) {
                          return SectionCard(
                            child: RecommendedProducts(
                              title: 'You May Also Like',
                              products: state.recommendedProducts
                                  .where((p) => p.id != widget.product.id)
                                  .take(6)
                                  .toList(),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // ── Sticky bottom bar ─────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            24, 14, 24, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          children: [
            // Add to Cart
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: const Text('Add to Cart',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Buy Now
            Expanded(
              flex: 2,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [primary, primary.withBlue(220)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _buyNow,
                    borderRadius: BorderRadius.circular(28),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('Buy Now',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
