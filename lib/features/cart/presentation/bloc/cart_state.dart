import 'package:equatable/equatable.dart';
import 'package:ecom/shared/models/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get totalAmount =>
      items.fold(0, (total, item) => total + item.totalPrice);

  CartState copyWith({
    List<CartItem>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }

  @override
  List<Object> get props => [items];
}
