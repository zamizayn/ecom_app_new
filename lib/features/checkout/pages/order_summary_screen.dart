import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:ecom/shared/models/cart_item.dart';
import '../bloc/address_bloc.dart';
import '../widgets/checkout_widgets.dart';
import 'order_success_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const OrderSummaryScreen({super.key, required this.cartItems});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final _couponController = TextEditingController();
  String? _appliedCoupon;
  double _discount = 0;
  bool _isPlacing = false;

  static const double _deliveryCharge = 15.0;

  double get _subtotal => widget.cartItems.fold(0, (t, i) => t + i.totalPrice);

  double get _total => _subtotal + _deliveryCharge - _discount;

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code == 'SAVE10') {
      setState(() {
        _appliedCoupon = code;
        _discount = _subtotal * 0.10;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('🎉 Coupon applied! 10% off'),
            behavior: SnackBarBehavior.floating),
      );
    } else if (code == 'FLAT50') {
      setState(() {
        _appliedCoupon = code;
        _discount = 50;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('🎉 Coupon applied! \$50 off'),
            behavior: SnackBarBehavior.floating),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid coupon code'),
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacing = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isPlacing = false);

    final orderId =
        'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final address = context.read<AddressBloc>().state.selectedAddress!;

    if (!mounted) return;
    context.go(
      '/order-success',
      extra: OrderSuccessArgs(
        orderId: orderId,
        address: address,
        cartItems: widget.cartItems,
        total: _total,
      ),
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order Summary',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          const CheckoutStepper(step: 2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Delivery address ─────────────────────────────────────
                BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, state) {
                    final addr = state.selectedAddress;
                    if (addr == null) return const SizedBox();
                    return _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivering To',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primary)),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Change',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(addr.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(addr.phone,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(addr.fullAddress,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 13)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Order items ──────────────────────────────────────────
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Items (${widget.cartItems.length})',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: primary)),
                      const Divider(height: 20),
                      ...widget.cartItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: item.product.imageUrl,
                                    width: 56,
                                    height: 56,
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
                                      const SizedBox(height: 4),
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
                                      color: primary),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Coupon ───────────────────────────────────────────────
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Promo Code',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: primary)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              enabled: _appliedCoupon == null,
                              decoration: InputDecoration(
                                hintText: 'Try SAVE10 or FLAT50',
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey[200]!)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey[200]!)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_appliedCoupon == null)
                            ElevatedButton(
                              onPressed: _applyCoupon,
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text('Apply'),
                            )
                          else
                            TextButton(
                              onPressed: () => setState(() {
                                _appliedCoupon = null;
                                _discount = 0;
                                _couponController.clear();
                              }),
                              child: const Text('Remove',
                                  style: TextStyle(color: Colors.red)),
                            ),
                        ],
                      ),
                      if (_appliedCoupon != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 6),
                              Text('"$_appliedCoupon" applied',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Payment method (static) ──────────────────────────────
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Method',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: primary)),
                      const SizedBox(height: 10),
                      _PaymentOption(
                          icon: Icons.credit_card,
                          label: 'Credit / Debit Card',
                          selected: true),
                      const SizedBox(height: 8),
                      _PaymentOption(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'UPI / Wallet',
                          selected: false),
                      const SizedBox(height: 8),
                      _PaymentOption(
                          icon: Icons.money,
                          label: 'Cash on Delivery',
                          selected: false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Price breakdown ──────────────────────────────────────
                _Card(
                  child: Column(
                    children: [
                      _PriceRow(
                          'Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _PriceRow('Delivery', '\$$_deliveryCharge'),
                      if (_discount > 0) ...[
                        const SizedBox(height: 8),
                        _PriceRow(
                            'Discount', '-\$${_discount.toStringAsFixed(2)}',
                            color: Colors.green),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('\$${_total.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── Place Order button ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isPlacing ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: _isPlacing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Place Order · \$${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _PriceRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: color ?? Colors.black87)),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _PaymentOption(
      {required this.icon, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? primary.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: selected ? primary.withOpacity(0.4) : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: selected ? primary : Colors.grey[500]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13)),
          ),
          if (selected)
            Icon(Icons.radio_button_checked, size: 18, color: primary)
          else
            Icon(Icons.radio_button_unchecked,
                size: 18, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
