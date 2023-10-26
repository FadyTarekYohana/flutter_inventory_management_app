import 'package:flutter/material.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';
import 'package:inventory_management_app/presentation/otp_screen.dart';
import 'package:inventory_management_app/util/dbTools.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                if (await checkIfDocExists('users', phoneController.text)) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OtpScreen(
                        phoneNumber: phoneController.text,
                      ),
                    ),
                  );
                } else {}
              },
              child: const Text("Login")),
        )
      ],
    ));
  }
}
