import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';
import 'package:image_picker/image_picker.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  GlobalKey<FormState> key = GlobalKey();

  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('items');

  String imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        child: Form(
      key: key,
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Item Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              )),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Quantity',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the item quantity';
                }
                return null;
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  hintText: 'Notes',
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                ImagePicker imagePicker = ImagePicker();
                XFile? file =
                    await imagePicker.pickImage(source: ImageSource.gallery);

                if (file == null) return;

                String uniqueFileName =
                    DateTime.now().millisecondsSinceEpoch.toString();

                Reference referenceRoot = FirebaseStorage.instance.ref();
                Reference referenceDirImages = referenceRoot.child('images');
                Reference referenceImageToUpload =
                    referenceDirImages.child(uniqueFileName);

                try {
                  await referenceImageToUpload.putFile(File(file.path));
                  imageUrl = await referenceImageToUpload.getDownloadURL();
                } catch (e) {}
              },
              icon: const Icon(Icons.image),
              label: const Text("Add Image"),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                if (key.currentState!.validate()) {
                  String itemName = nameController.text;
                  String itemQuantity = quantityController.text;
                  String itemNotes = notesController.text;

                  Map<String, String> dataToSend = {
                    'name': itemName,
                    'quantity': itemQuantity,
                    'notes': itemNotes
                  };

                  try {
                    _reference.add(dataToSend);
                    GoRouter.of(context).go('/');
                  } catch (e) {}
                }
              },
              child: const Text('Submit'))
        ],
      ),
    ));
  }
}
