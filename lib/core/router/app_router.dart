import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ecom/features/auth/presentation/pages/login_screen.dart';
import 'package:ecom/features/products/presentation/pages/home_screen.dart';
import 'package:ecom/features/products/presentation/pages/product_list_screen.dart';
import 'package:ecom/features/products/presentation/pages/product_details_screen.dart';
import 'package:ecom/features/products/presentation/pages/products_listing_screen.dart';
import 'package:ecom/features/cart/presentation/pages/cart_screen.dart';
import 'package:ecom/shared/models/product.dart';

import 'package:ecom/features/auth/presentation/pages/otp_screen.dart';
import 'package:ecom/core/presentation/pages/main_layout_screen.dart';
import 'package:ecom/features/wishlist/presentation/pages/wishlist_screen.dart';
import 'package:ecom/features/profile/presentation/pages/profile_screen.dart';
import 'package:ecom/features/chat/presentation/pages/chat_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phoneNumber: phone);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayoutScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/category/:id',
        builder: (context, state) {
          final categoryId = state.pathParameters['id']!;
          final categoryName = state.uri.queryParameters['name'] ?? 'Products';
          return ProductListScreen(
            categoryId: categoryId,
            categoryName: categoryName,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/products',
        builder: (context, state) {
          final args = state.extra as ProductsListingArgs;
          return ProductsListingScreen(
            title: args.title,
            allProducts: args.products,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/product',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailsScreen(product: product);
        },
      ),
    ],
  );
}
