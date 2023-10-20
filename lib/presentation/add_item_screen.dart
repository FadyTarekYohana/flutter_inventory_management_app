import 'package:flutter/material.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        child: Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Item Name',
              ),
            )),
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Quantity',
              ),
            )),
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Notes',
              ),
            )),
        ElevatedButton(onPressed: () {}, child: Text("Add Item"))
      ],
    ));
  }
}
