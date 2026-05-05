import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ecom/shared/models/product.dart';

// Events
abstract class WishlistEvent extends Equatable {
  const WishlistEvent();
  @override
  List<Object> get props => [];
}
class ToggleWishlistItem extends WishlistEvent {
  final Product product;
  const ToggleWishlistItem(this.product);
  @override
  List<Object> get props => [product];
}

// States
class WishlistState extends Equatable {
  final List<Product> items;
  const WishlistState({this.items = const []});
  @override
  List<Object> get props => [items];
}

// BLoC
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc() : super(const WishlistState()) {
    on<ToggleWishlistItem>((event, emit) {
      final currentItems = List<Product>.from(state.items);
      if (currentItems.contains(event.product)) {
        currentItems.remove(event.product);
      } else {
        currentItems.add(event.product);
      }
      emit(WishlistState(items: currentItems));
    });
  }
}
