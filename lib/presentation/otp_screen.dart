import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Icon(
            Icons.password_outlined,
            size: 100,
            color: Colors.blue,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 48,
                width: 44,
                child: TextFormField(
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                  onSaved: (newValue) {},
                  style: Theme.of(context).textTheme.titleLarge,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                width: 44,
                child: TextFormField(
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).nextFocus();
                    }
                    if (value.isEmpty) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  onSaved: (newValue) {},
                  style: Theme.of(context).textTheme.titleLarge,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                width: 44,
                child: TextFormField(
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).nextFocus();
                    }
                    if (value.isEmpty) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  onSaved: (newValue) {},
                  style: Theme.of(context).textTheme.titleLarge,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                width: 44,
                child: TextFormField(
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).nextFocus();
                    }
                    if (value.isEmpty) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  onSaved: (newValue) {},
                  style: Theme.of(context).textTheme.titleLarge,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                width: 44,
                child: TextFormField(
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).nextFocus();
                    }
                    if (value.isEmpty) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  onSaved: (newValue) {},
                  style: Theme.of(context).textTheme.titleLarge,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                width: 44,
                child: TextFormField(
                  onChanged: (value) {
                    if (value.isEmpty) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  onSaved: (newValue) {},
                  style: Theme.of(context).textTheme.titleLarge,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: ElevatedButton(
              onPressed: () => {GoRouter.of(context).go('/')},
              child: const Text("Verify")),
        )
      ],
    ));
  }
}
