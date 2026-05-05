import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:ecom/shared/models/product.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecom/features/wishlist/presentation/bloc/wishlist_bloc.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  int _selectedColorIndex = 0;
  int _selectedStorageIndex = 0;

  final List<String> _colors = ['Desert Titanium', 'Natural Titanium', 'White Titanium', 'Black Titanium'];
  final List<String> _storage = ['256 GB', '512 GB', '1 TB'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, wishState) {
              final isWishlisted = wishState.items.contains(widget.product);
              return IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_outline,
                  color: isWishlisted ? Colors.red : null,
                ),
                onPressed: () {
                  context.read<WishlistBloc>().add(ToggleWishlistItem(widget.product));
                },
              );
            },
          ),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () => context.push('/cart')),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Center(
                child: Hero(
                  tag: 'product_${widget.product.id}',
                  child: SizedBox(
                    height: 250,
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Title & Rating
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('By Apple', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.product.rating}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(' (2.2k) >', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 16),

              // Price & Quantity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${widget.product.price}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${(widget.product.price * 1.1).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                        ),
                        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.add, size: 16, color: Theme.of(context).colorScheme.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() => _quantity++);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Color Options
              const Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_colors.length, (index) {
                  final isSelected = _selectedColorIndex == index;
                  return ChoiceChip(
                    label: Text(_colors[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedColorIndex = index);
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: Colors.blue[50],
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[800],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Storage Options
              const Text('Storage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: List.generate(_storage.length, (index) {
                  final isSelected = _selectedStorageIndex == index;
                  return ChoiceChip(
                    label: Text(_storage[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedStorageIndex = index);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Colors.blue[50],
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[800],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Description / Specs (A Snapshot View)
              const Text('A Snapshot View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildSpecRow(Icons.display_settings, '4K Ultra HD XDR Display'),
              const SizedBox(height: 12),
              _buildSpecRow(Icons.battery_charging_full, 'Wireless Charging System'),
              const SizedBox(height: 12),
              Text(widget.product.description, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 100), // spacing for bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartBloc>().add(AddProductToCart(widget.product));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.product.name} added to cart')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}
