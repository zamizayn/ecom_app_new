import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ecom/shared/models/address.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object?> get props => [];
}

class AddAddress extends AddressEvent {
  final Address address;
  const AddAddress(this.address);
  @override
  List<Object?> get props => [address];
}

class UpdateAddress extends AddressEvent {
  final Address address;
  const UpdateAddress(this.address);
  @override
  List<Object?> get props => [address];
}

class DeleteAddress extends AddressEvent {
  final String id;
  const DeleteAddress(this.id);
  @override
  List<Object?> get props => [id];
}

class SetDefaultAddress extends AddressEvent {
  final String id;
  const SetDefaultAddress(this.id);
  @override
  List<Object?> get props => [id];
}

class SelectAddress extends AddressEvent {
  final String id;
  const SelectAddress(this.id);
  @override
  List<Object?> get props => [id];
}

// ── State ─────────────────────────────────────────────────────────────────────

class AddressState extends Equatable {
  final List<Address> addresses;
  final String? selectedId;

  const AddressState({this.addresses = const [], this.selectedId});

  Address? get selectedAddress =>
      selectedId == null ? null : addresses.where((a) => a.id == selectedId).firstOrNull;

  AddressState copyWith({List<Address>? addresses, String? selectedId}) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedId: selectedId ?? this.selectedId,
    );
  }

  @override
  List<Object?> get props => [addresses, selectedId];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc()
      : super(const AddressState(
          // Pre-load a sample address so the screen is non-empty
          addresses: [
            Address(
              id: 'addr_1',
              name: 'John Doe',
              phone: '+1 234 567 8901',
              line1: '123 Elm Street, Apt 4B',
              city: 'New York',
              state: 'NY',
              pincode: '10001',
              isDefault: true,
            ),
          ],
          selectedId: 'addr_1',
        )) {
    on<AddAddress>(_onAdd);
    on<UpdateAddress>(_onUpdate);
    on<DeleteAddress>(_onDelete);
    on<SetDefaultAddress>(_onSetDefault);
    on<SelectAddress>(_onSelect);
  }

  void _onAdd(AddAddress event, Emitter<AddressState> emit) {
    final updated = List<Address>.from(state.addresses);
    // If this is first or marked default, clear others
    if (event.address.isDefault || updated.isEmpty) {
      final cleared = updated.map((a) => a.copyWith(isDefault: false)).toList();
      cleared.add(event.address);
      emit(state.copyWith(addresses: cleared, selectedId: event.address.id));
    } else {
      updated.add(event.address);
      emit(state.copyWith(addresses: updated));
    }
  }

  void _onUpdate(UpdateAddress event, Emitter<AddressState> emit) {
    final updated = state.addresses.map((a) {
      if (a.id == event.address.id) return event.address;
      if (event.address.isDefault) return a.copyWith(isDefault: false);
      return a;
    }).toList();
    emit(state.copyWith(addresses: updated));
  }

  void _onDelete(DeleteAddress event, Emitter<AddressState> emit) {
    final updated = state.addresses.where((a) => a.id != event.id).toList();
    final newSelected =
        state.selectedId == event.id ? null : state.selectedId;
    emit(AddressState(addresses: updated, selectedId: newSelected));
  }

  void _onSetDefault(SetDefaultAddress event, Emitter<AddressState> emit) {
    final updated = state.addresses
        .map((a) => a.copyWith(isDefault: a.id == event.id))
        .toList();
    emit(state.copyWith(addresses: updated));
  }

  void _onSelect(SelectAddress event, Emitter<AddressState> emit) {
    emit(state.copyWith(selectedId: event.id));
  }
}
