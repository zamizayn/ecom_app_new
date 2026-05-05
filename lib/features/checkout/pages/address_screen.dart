import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecom/shared/models/address.dart';
import '../bloc/address_bloc.dart';
import '../widgets/checkout_widgets.dart';
import 'add_edit_address_screen.dart';
import 'order_summary_screen.dart';
import 'package:ecom/shared/models/cart_item.dart';

class AddressScreen extends StatelessWidget {
  final List<CartItem> cartItems;

  const AddressScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Select Delivery Address',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, state) {
          return Column(
            children: [
              // Progress indicator
              const CheckoutStepper(step: 1),

              Expanded(
                child: state.addresses.isEmpty
                    ? _EmptyAddressState(onAdd: () => _openAdd(context))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.addresses.length + 1, // +1 for add button
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == state.addresses.length) {
                            return _AddAddressButton(
                                onTap: () => _openAdd(context));
                          }
                          final address = state.addresses[index];
                          final isSelected = state.selectedId == address.id;
                          return _AddressTile(
                            address: address,
                            isSelected: isSelected,
                            onSelect: () => context
                                .read<AddressBloc>()
                                .add(SelectAddress(address.id)),
                            onEdit: () => _openEdit(context, address),
                            onDelete: () =>
                                _confirmDelete(context, address.id),
                          );
                        },
                      ),
              ),

              // Continue button
              CheckoutContinueBar(
                enabled: state.selectedId != null,
                onTap: state.selectedId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AddressBloc>(),
                              child: OrderSummaryScreen(cartItems: cartItems),
                            ),
                          ),
                        );
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AddressBloc>(),
          child: const AddEditAddressScreen(),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, Address address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AddressBloc>(),
          child: AddEditAddressScreen(existing: address),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address'),
        content:
            const Text('Are you sure you want to remove this address?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AddressBloc>().add(DeleteAddress(id));
              Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Address tile ──────────────────────────────────────────────────────────────

class _AddressTile extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio-style selector
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? primary : Colors.grey[400]!, width: 2),
                color: isSelected ? primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),

            // Address details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(address.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 8),
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Default',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(address.phone,
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(address.fullAddress,
                      style:
                          TextStyle(color: Colors.grey[700], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ActionChip(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          color: primary,
                          onTap: onEdit),
                      const SizedBox(width: 10),
                      _ActionChip(
                          icon: Icons.delete_outline,
                          label: 'Delete',
                          color: Colors.red,
                          onTap: onDelete),
                    ],
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

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAddressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              width: 1.5,
              style: BorderStyle.none),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text('Add New Address',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyAddressState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No saved addresses',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add an address to continue',
              style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
          ),
        ],
      ),
    );
  }
}


