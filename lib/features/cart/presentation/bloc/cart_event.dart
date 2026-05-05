import 'package:equatable/equatable.dart';
import 'package:ecom/shared/models/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddProductToCart extends CartEvent {
  final Product product;

  const AddProductToCart(this.product);

  @override
  List<Object> get props => [product];
}

class RemoveProductFromCart extends CartEvent {
  final Product product;

  const RemoveProductFromCart(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateCartItemQuantity extends CartEvent {
  final Product product;
  final int quantity;

  const UpdateCartItemQuantity(this.product, this.quantity);

  @override
  List<Object> get props => [product, quantity];
}
