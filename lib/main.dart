import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecom/core/router/app_router.dart';
import 'package:ecom/core/theme/app_theme.dart';

import 'package:ecom/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecom/features/products/presentation/bloc/products_bloc.dart';
import 'package:ecom/features/search/presentation/bloc/search_bloc.dart';
import 'package:ecom/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ecom/features/checkout/bloc/address_bloc.dart';

import 'package:ecom/features/products/data/repositories/mock_product_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcomApp());
}

class EcomApp extends StatelessWidget {
  const EcomApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instantiate repository once to share among BLoCs
    final productRepository = MockProductRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => ProductsBloc(productRepository: productRepository),
        ),
        BlocProvider(
          create: (context) => CartBloc(),
        ),
        BlocProvider(
          create: (context) => WishlistBloc(),
        ),
        BlocProvider(
          create: (context) => SearchBloc(repository: productRepository),
        ),
        BlocProvider(
          create: (context) => AddressBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'E-Shop',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
