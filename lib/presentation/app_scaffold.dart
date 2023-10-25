import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/user_repository.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late dynamic user;

  bool userLoaded = false;

  loadData() async {
    try {
      user = await getUser();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    setState(() {
      if (user != null) {
        userLoaded = true;
      }
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: SafeArea(
            top: true,
            child: Visibility(
              replacement: ListTile(
                title: const Text("Login"),
                onTap: () => context.go("/login"),
              ),
              visible: FirebaseAuth.instance.currentUser != null,
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
                  Visibility(
                    visible: userLoaded ? user['type'] == 'admin' : false,
                    child: ListTile(
                      title: const Text("Users"),
                      onTap: () => context.go("/users"),
                    ),
                  ),
                  ListTile(
                    title: const Text("Reservations"),
                    onTap: () => context.go("/reservations"),
                  ),
                  ListTile(
                    title: const Text("Logout"),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      // ignore: use_build_context_synchronously
                      context.go("/login");
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(
          title: Text(userLoaded ? "Hello ${user['name']}" : "Hello Guest"),
        ),
        body: Center(
          child: widget.child,
        ));
  }
}
