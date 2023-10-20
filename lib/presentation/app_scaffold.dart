import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: SafeArea(
            top: true,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: const Text("Home"),
                  onTap: () => context.go("/"),
                ),
                ListTile(
                  title: const Text("Cart"),
                  onTap: () => context.go("/cart"),
                ),
                ListTile(
                  title: const Text("My Items"),
                  onTap: () => context.go("/myitems"),
                ),
                ListTile(
                  title: const Text("Users"),
                  onTap: () => context.go("/users"),
                ),
                ListTile(
                  title: const Text("Login"),
                  onTap: () => context.go("/Login"),
                ),
                ListTile(
                  title: const Text("Logout"),
                  onTap: () => context.go("/Logout"),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: const Text("Inventory Manager"),
        ),
        body: Center(
          child: child,
        ));
  }
}
