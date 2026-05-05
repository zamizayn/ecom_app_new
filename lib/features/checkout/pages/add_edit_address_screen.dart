import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:ecom/shared/models/address.dart';
import '../bloc/address_bloc.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? existing; // null = add mode

  const AddEditAddressScreen({super.key, this.existing});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;
  bool _isDefault = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _name    = TextEditingController(text: a?.name ?? '');
    _phone   = TextEditingController(text: a?.phone ?? '');
    _line1   = TextEditingController(text: a?.line1 ?? '');
    _line2   = TextEditingController(text: a?.line2 ?? '');
    _city    = TextEditingController(text: a?.city ?? '');
    _state   = TextEditingController(text: a?.state ?? '');
    _pincode = TextEditingController(text: a?.pincode ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _line1, _line2, _city, _state, _pincode]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final address = Address(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      line1: _line1.text.trim(),
      line2: _line2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      pincode: _pincode.text.trim(),
      isDefault: _isDefault,
    );

    if (_isEdit) {
      context.read<AddressBloc>().add(UpdateAddress(address));
    } else {
      context.read<AddressBloc>().add(AddAddress(address));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Address' : 'Add New Address',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Contact Details'),
            const SizedBox(height: 12),
            _Field(controller: _name, label: 'Full Name', icon: Icons.person_outline, validator: _required),
            const SizedBox(height: 14),
            _Field(
              controller: _phone,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Delivery Address'),
            const SizedBox(height: 12),
            _Field(controller: _line1, label: 'Address Line 1', icon: Icons.home_outlined, validator: _required),
            const SizedBox(height: 14),
            _Field(controller: _line2, label: 'Address Line 2 (optional)', icon: Icons.apartment_outlined),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _Field(controller: _city, label: 'City', icon: Icons.location_city_outlined, validator: _required)),
                const SizedBox(width: 12),
                Expanded(child: _Field(controller: _state, label: 'State', icon: Icons.map_outlined, validator: _required)),
              ],
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _pincode,
              label: 'PIN Code',
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 5) return 'Enter valid PIN';
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Set as default toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SwitchListTile(
                value: _isDefault,
                activeColor: primary,
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as default address',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('Use this address by default for all orders',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                onChanged: (v) => setState(() => _isDefault = v),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(_isEdit ? 'Save Changes' : 'Save Address',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
