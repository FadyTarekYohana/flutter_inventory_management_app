import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController phoneController = TextEditingController(text: "+20");

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Icon(
            Icons.manage_accounts,
            size: 100,
            color: Colors.blue,
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                icon: Icon(Icons.phone),
                hintText: 'Phone Number With Country Code',
              ),
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () async {
                await auth.verifyPhoneNumber(
                  phoneNumber: phoneController.text,
                  verificationCompleted:
                      (PhoneAuthCredential credential) async {},
                  verificationFailed: (FirebaseAuthException e) async {},
                  codeSent: (String verificationId, int? resendToken) async {},
                  codeAutoRetrievalTimeout: (String verificationId) async {},
                );
                GoRouter.of(context).go('/otp');
              },
              child: const Text("Login")),
        )
      ],
    ));
  }
}
