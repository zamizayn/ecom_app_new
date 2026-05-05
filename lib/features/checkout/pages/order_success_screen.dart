import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom/shared/models/address.dart';
import 'package:ecom/shared/models/cart_item.dart';

/// Payload passed via GoRouter extra to the /order-success route.
class OrderSuccessArgs {
  final String orderId;
  final Address address;
  final List<CartItem> cartItems;
  final double total;

  const OrderSuccessArgs({
    required this.orderId,
    required this.address,
    required this.cartItems,
    required this.total,
  });
}

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final Address address;
  final List<CartItem> cartItems;
  final double total;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.address,
    required this.cartItems,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ── Success animation ─────────────────────────────────
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 64),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Order Placed!',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Your order has been confirmed',
                        style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 4),

                    // Order ID
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_outlined, size: 16, color: primary),
                          const SizedBox(width: 6),
                          Text('Order ID: $orderId',
                              style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Delivery address ──────────────────────────────────
                    _Section(
                      title: 'Delivering To',
                      icon: Icons.location_on_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(address.phone,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(address.fullAddress,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.local_shipping_outlined,
                                  size: 14, color: Colors.green),
                              const SizedBox(width: 6),
                              Text('Expected delivery: 3-5 business days',
                                  style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Order items ───────────────────────────────────────
                    _Section(
                      title: 'Items Ordered',
                      icon: Icons.shopping_bag_outlined,
                      child: Column(
                        children: cartItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: item.product.imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                      Text('Qty: ${item.quantity}',
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                        fontSize: 13)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Total ─────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primary.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Paid',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('\$${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── CTAs ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Continue Shopping',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('View My Orders',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primary),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primary)),
            ],
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}
