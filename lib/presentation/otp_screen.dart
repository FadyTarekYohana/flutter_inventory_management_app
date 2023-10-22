import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';

import '../widgets/text_otp.dart';
import '../widgets/textfield_otp.dart';

class OtpScreen extends StatefulWidget {
  OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);
  String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  void initState() {
    // ignore: avoid_print
    print("initState");
    phoneAuth();
    // serviceAuth.phoneAuth(widget.phoneNumber, verifId!);
    startTimer();

    super.initState();
  }

  int counter = 60;
  late Timer _timer;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? verifId;
  // ServiceAuth serviceAuth = ServiceAuth();

  void startTimer() {
    setState(() {
      counter = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // ignore: avoid_print
      print(timer.tick);

      if (!mounted || counter == 0) {
        timer.cancel();
      } else {
        setState(() {
          if (counter > 0) {
            counter--;
          }
        });
      }
    });
  }

  bool correct = true;

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print

    return AppScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width / 8,
          ),
          const TextOTP(),
          Text(
            widget.phoneNumber,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 60,
          ),
          TextFieldOTPWidget(correct: correct),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              children: [
                const Text("Don't Recive any code ?"),
                TextButton(
                    onPressed: () {
                      if (counter == 0) {
                        startTimer();
                        phoneAuth();
                        //   serviceAuth.phoneAuth(widget.phoneNumber, verifId!);
                      }
                    },
                    child: const Text("send again")),
                const Spacer(),
                Text(
                  "$counter",
                  style: const TextStyle(fontSize: 25),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width / 8,
          ),
          ElevatedButton(
              onPressed: () {
                sentCode();
                // serviceAuth.sentCode(verifId, correct);
              },
              child: const Text("confirm", style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ignore: avoid_print
    print("dispose");
    c1.dispose();
    c2.dispose();
    c3.dispose();
    c4.dispose();
    c5.dispose();
    c6.dispose();
    _timer.cancel();
    super.dispose();
  }

  // phoneAuth();

  void phoneAuth() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 30),
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        // ignore: avoid_print
        print("ex");
      },
      codeSent: (String verificationId, int? resendToken) async {
        verifId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verifId = verificationId;
      },
    );
  }

  sentCode() async {
    try {
      String smsCode =
          c1.text + c2.text + c3.text + c4.text + c5.text + c6.text;

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verifId!, smsCode: smsCode);

      await auth.signInWithCredential(credential).then((value) {
        if (value.user != null && correct) {
          GoRouter.of(context).go('/');
        }
      });
    } catch (ex) {
      setState(() {
        correct = false;
      });
    }
  }
}

class TextFieldOTPWidget extends StatelessWidget {
  const TextFieldOTPWidget({
    super.key,
    required this.correct,
  });

  final bool correct;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextFieldOTP(
            correct: correct, first: true, last: false, controller: c1),
        TextFieldOTP(
            correct: correct, controller: c2, first: false, last: false),
        TextFieldOTP(
            correct: correct, controller: c3, first: false, last: false),
        TextFieldOTP(
            correct: correct, controller: c4, first: false, last: false),
        TextFieldOTP(
            correct: correct, controller: c5, first: false, last: false),
        TextFieldOTP(
            correct: correct, controller: c6, first: false, last: true),
      ],
    );
  }
}

TextEditingController c1 = TextEditingController();
TextEditingController c2 = TextEditingController();
TextEditingController c3 = TextEditingController();
TextEditingController c4 = TextEditingController();
TextEditingController c5 = TextEditingController();
TextEditingController c6 = TextEditingController();
