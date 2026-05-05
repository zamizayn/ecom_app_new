import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecom/shared/models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddProductToCart>(_onAddProduct);
    on<RemoveProductFromCart>(_onRemoveProduct);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
  }

  void _onAddProduct(AddProductToCart event, Emitter<CartState> emit) {
    final List<CartItem> currentItems = List.from(state.items);
    final int index =
        currentItems.indexWhere((item) => item.product.id == event.product.id);

    if (index >= 0) {
      final item = currentItems[index];
      currentItems[index] = item.copyWith(quantity: item.quantity + 1);
    } else {
      currentItems.add(CartItem(product: event.product));
    }

    emit(state.copyWith(items: currentItems));
  }

  void _onRemoveProduct(RemoveProductFromCart event, Emitter<CartState> emit) {
    final List<CartItem> currentItems = List.from(state.items);
    currentItems.removeWhere((item) => item.product.id == event.product.id);
    emit(state.copyWith(items: currentItems));
  }

  void _onUpdateQuantity(
      UpdateCartItemQuantity event, Emitter<CartState> emit) {
    final List<CartItem> currentItems = List.from(state.items);
    final int index =
        currentItems.indexWhere((item) => item.product.id == event.product.id);

    if (index >= 0) {
      if (event.quantity <= 0) {
        currentItems.removeAt(index);
      } else {
        currentItems[index] = currentItems[index].copyWith(quantity: event.quantity);
      }
      emit(state.copyWith(items: currentItems));
    }
  }
}
