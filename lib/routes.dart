import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/presentation/add_item_screen.dart';
import 'package:inventory_management_app/presentation/home_screen.dart';
import 'package:inventory_management_app/presentation/item_details_screen.dart';
import 'package:inventory_management_app/presentation/login_screen.dart';
import 'package:inventory_management_app/presentation/otp_screen.dart';
import 'package:inventory_management_app/presentation/users_screen.dart';

final GoRouter router = GoRouter(initialLocation: '/', routes: [
  GoRoute(
    name: 'home',
    path: '/',
    builder: (context, state) => HomeScreen(),
  ),
  GoRoute(
    name: 'login',
    path: '/login',
    builder: (context, state) => LoginScreen(),
  ),
  GoRoute(
    name: 'additem',
    path: '/additem',
    builder: (context, state) => AddItemScreen(),
  ),
  GoRoute(
    name: 'otp',
    path: '/otp',
    builder: (context, state) => OtpScreen(phoneNumber: state.extra.toString()),
  ),
  GoRoute(
    name: 'itemdetails',
    path: '/itemdetails',
    builder: (context, state) =>
        ItemDetailsScreen(itemId: state.extra.toString()),
  ),
  GoRoute(
    name: 'users',
    path: '/users',
    builder: (context, state) => UsersScreen(),
  ),
]);
