import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/presentation/reservation_details_screen.dart';
import 'package:inventory_management_app/presentation/reservations_screen.dart';
import 'package:inventory_management_app/presentation/add_item_screen.dart';
import 'package:inventory_management_app/presentation/cart_screen.dart';
import 'package:inventory_management_app/presentation/home_screen.dart';
import 'package:inventory_management_app/presentation/item_details_screen.dart';
import 'package:inventory_management_app/presentation/login_screen.dart';
import 'package:inventory_management_app/presentation/otp_screen.dart';
import 'package:inventory_management_app/presentation/users_screen.dart';

final GoRouter router = GoRouter(
    initialLocation: FirebaseAuth.instance.currentUser != null ? '/' : '/login',
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'additem',
        path: '/additem',
        builder: (context, state) => const AddItemScreen(),
      ),
      GoRoute(
        name: 'otp',
        path: '/otp',
        builder: (context, state) =>
            OtpScreen(phoneNumber: state.extra.toString()),
      ),
      GoRoute(
        name: 'itemdetails',
        path: '/itemdetails',
        builder: (context, state) =>
            ItemDetailsScreen(itemId: state.extra.toString()),
      ),
      GoRoute(
        name: 'reservationdetails',
        path: '/reservationdetails',
        builder: (context, state) =>
            ReservationDetailsScreen(itemId: state.extra.toString()),
      ),
      GoRoute(
        name: 'users',
        path: '/users',
        builder: (context, state) => UsersScreen(),
      ),
      GoRoute(
        name: 'cart',
        path: '/cart',
        builder: (context, state) => CartScreen(),
      ),
      GoRoute(
        name: 'reservations',
        path: '/reservations',
        builder: (context, state) => ReservationsScreen(),
      ),
    ]);
