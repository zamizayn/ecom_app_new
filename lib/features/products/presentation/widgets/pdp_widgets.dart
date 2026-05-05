import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom/shared/models/product.dart';

// ── Image Carousel ─────────────────────────────────────────────────────────────

class ImageCarouselWidget extends StatefulWidget {
  final String imageUrl;
  final String productId;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;
  final VoidCallback onShareTap;
  final String? badge; // "Best Seller" / "Limited Stock"

  const ImageCarouselWidget({
    super.key,
    required this.imageUrl,
    required this.productId,
    required this.isWishlisted,
    required this.onWishlistTap,
    required this.onShareTap,
    this.badge,
  });

  @override
  State<ImageCarouselWidget> createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget> {
  int _currentPage = 0;
  late final PageController _pc;
  // Simulate multiple images by repeating the same URL
  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
    _images = [widget.imageUrl, widget.imageUrl, widget.imageUrl];
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pc,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => GestureDetector(
              onDoubleTap: () {},
              child: Hero(
                tag: 'product_${widget.productId}',
                child: CachedNetworkImage(
                  imageUrl: _images[i],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // Badge — offset below status bar
          if (widget.badge != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 16,
              child: _Badge(label: widget.badge!),
            ),

          // Wishlist + Share — below the pinned app bar
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            right: 12,
            child: Column(
              children: [
                _CircleAction(
                  icon: widget.isWishlisted
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.isWishlisted ? Colors.red : Colors.grey[700]!,
                  onTap: widget.onWishlistTap,
                ),
                const SizedBox(height: 8),
                _CircleAction(
                  icon: Icons.share_outlined,
                  color: Colors.grey[700]!,
                  onTap: widget.onShareTap,
                ),
              ],
            ),
          ),

          // Dots indicator
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? primary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final isBestSeller = label.contains('Best');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isBestSeller ? Colors.orange : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isBestSeller ? '🔥' : '⚡', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// ── Price Section ─────────────────────────────────────────────────────────────

class PriceSection extends StatelessWidget {
  final double price;
  final double originalPrice;

  const PriceSection(
      {super.key, required this.price, required this.originalPrice});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final discount =
        (((originalPrice - price) / originalPrice) * 100).round();

    return Row(
      children: [
        Text('\$${price.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: primary)),
        const SizedBox(width: 10),
        Text('\$${originalPrice.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 15,
                color: Colors.grey[400],
                decoration: TextDecoration.lineThrough)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
          child: Text('$discount% off',
              style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      ],
    );
  }
}

// ── Variant Selector ──────────────────────────────────────────────────────────

class VariantSelector extends StatelessWidget {
  final String title;
  final List<String> options;
  final int selectedIndex;
  final List<int> disabledIndices;
  final ValueChanged<int> onSelect;

  const VariantSelector({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    this.disabledIndices = const [],
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 8),
            Text(': ${options[selectedIndex]}',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(options.length, (i) {
            final isSelected = i == selectedIndex;
            final isDisabled = disabledIndices.contains(i);
            return GestureDetector(
              onTap: isDisabled ? null : () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withOpacity(0.08)
                      : isDisabled
                          ? Colors.grey[100]
                          : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : isDisabled
                            ? Colors.grey[200]!
                            : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? primary
                        : isDisabled
                            ? Colors.grey[400]
                            : Colors.grey[800],
                    decoration: isDisabled
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Delivery Checker ──────────────────────────────────────────────────────────

class DeliveryChecker extends StatefulWidget {
  const DeliveryChecker({super.key});

  @override
  State<DeliveryChecker> createState() => _DeliveryCheckerState();
}

class _DeliveryCheckerState extends State<DeliveryChecker> {
  final _ctrl = TextEditingController();
  String? _result;
  bool _checking = false;

  void _check() async {
    if (_ctrl.text.length < 5) return;
    setState(() => _checking = true);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _checking = false;
      _result = 'Delivery by ${_nextDeliveryDate()} · Free Shipping';
    });
  }

  String _nextDeliveryDate() {
    final d = DateTime.now().add(const Duration(days: 3));
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.day}';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_shipping_outlined, size: 18),
            const SizedBox(width: 6),
            const Text('Delivery',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'Enter pincode',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _checking ? null : _check,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: _checking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Check'),
            ),
          ],
        ),
        if (_result != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(_result!,
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Stock warning
        Row(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 14, color: Colors.orange[700]),
            const SizedBox(width: 6),
            Text('Only 5 left in stock – order soon!',
                style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

// ── Offers Section ────────────────────────────────────────────────────────────

class OffersSection extends StatelessWidget {
  const OffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final offers = [
      ('Bank Offer', '10% off on HDFC Bank Cards. T&C apply'),
      ('Coupon', 'Use SAVE10 for 10% off on first order'),
      ('No-cost EMI', 'Starting \$25/month'),
    ];

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      leading: Icon(Icons.local_offer_outlined, color: primary, size: 20),
      title: const Text('Offers & Coupons',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      children: offers
          .map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.$1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(o.$2,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ── Description Section ───────────────────────────────────────────────────────

class DescriptionSection extends StatefulWidget {
  final String description;
  const DescriptionSection({super.key, required this.description});

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final specs = [
      (Icons.display_settings_outlined, '4K Ultra HD XDR Display'),
      (Icons.battery_charging_full_outlined, 'Wireless Charging System'),
      (Icons.camera_alt_outlined, '50 MP Pro Camera System'),
      (Icons.speed_outlined, 'A17 Pro Chip'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.description_outlined, size: 18, color: primary),
          const SizedBox(width: 6),
          const Text('Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
        const SizedBox(height: 12),
        // Bullet highlights
        ...specs.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(s.$1, size: 18, color: Colors.grey[500]),
                const SizedBox(width: 10),
                Text(s.$2,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ]),
            )),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Text(widget.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.6)),
          secondChild: Text(
            widget.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.6),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less ↑' : 'Read more ↓',
            style:
                TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ── Reviews Section ───────────────────────────────────────────────────────────

class ReviewsSection extends StatelessWidget {
  final double rating;
  const ReviewsSection({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final reviews = [
      ('Alex M.', 5.0, 'Absolutely love this product! Worth every penny.'),
      ('Sara K.', 4.0, 'Great quality, fast delivery. Highly recommend!'),
      ('John D.', 4.5, 'Premium feel and excellent performance overall.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.star_rounded, size: 18, color: primary),
              const SizedBox(width: 6),
              const Text('Ratings & Reviews',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
            TextButton(
              onPressed: () {},
              child: const Text('See all',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Rating overview
        Row(
          children: [
            Column(
              children: [
                Text(rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(
                      5,
                      (i) => Icon(
                            i < rating.floor()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: Colors.amber,
                          )),
                ),
                Text('2.2k reviews',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  final pct = star == 5
                      ? 0.6
                      : star == 4
                          ? 0.25
                          : star == 3
                              ? 0.1
                              : 0.05;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('$star', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        const Icon(Icons.star_rounded,
                            size: 12, color: Colors.amber),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...reviews.map((r) => _ReviewCard(
            name: r.$1, rating: r.$2, comment: r.$3)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Write a Review',
              style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final double rating;
  final String comment;
  const _ReviewCard(
      {required this.name, required this.rating, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          i < rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: Colors.amber,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment,
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Trust Signals ─────────────────────────────────────────────────────────────

class TrustSignals extends StatelessWidget {
  const TrustSignals({super.key});

  @override
  Widget build(BuildContext context) {
    final signals = [
      (Icons.replay_outlined, '7-Day Returns'),
      (Icons.verified_user_outlined, '1 Year Warranty'),
      (Icons.lock_outlined, 'Secure Payment'),
      (Icons.local_shipping_outlined, 'Free Shipping'),
    ];
    return Row(
      children: signals
          .map((s) => Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(s.$1,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 5),
                    Text(s.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ── Recommended Products ──────────────────────────────────────────────────────

class RecommendedProducts extends StatelessWidget {
  final List<Product> products;
  final String title;

  const RecommendedProducts(
      {super.key, required this.products, required this.title});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox();
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = products[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Placeholder(), // replaced by real nav
                  ),
                ),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[100]!),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: CachedNetworkImage(
                          imageUrl: p.imageUrl,
                          height: 90,
                          width: 120,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.image)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('\$${p.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: primary,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Section Card wrapper ──────────────────────────────────────────────────────

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const SectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}
