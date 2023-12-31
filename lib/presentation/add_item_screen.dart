import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management_app/presentation/home_screen.dart';

import '../data/user_repository.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
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

  GlobalKey<FormState> key = GlobalKey();

  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('items');

  List<File> selectedImages = [];
  final picker = ImagePicker();

  String imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        child: Form(
      key: key,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width / 4,
            child: selectedImages.isEmpty
                ? Image.asset('assets/images/placeholder.jpg')
                : Image.file(File(selectedImages[0].path)),
          ),
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
                getImages();
              },
              icon: const Icon(Icons.image),
              label: const Text("Add Image"),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                if (key.currentState!.validate()) {
                  if (selectedImages.isNotEmpty) {
                    const snackBar = SnackBar(
                      content: Text('Adding the item...'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    String uniqueFileName =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    Reference referenceRoot = FirebaseStorage.instance.ref();
                    Reference referenceDirImages =
                        referenceRoot.child('images');
                    Reference referenceImageToUpload =
                        referenceDirImages.child(uniqueFileName);

                    String itemName = nameController.text;
                    String itemQuantity = quantityController.text;
                    String itemNotes = notesController.text;

                    try {
                      await referenceImageToUpload
                          .putFile(File(selectedImages[0].path));
                      imageUrl = await referenceImageToUpload.getDownloadURL();
                      Map<String, String> dataToSend = {
                        'name': itemName,
                        'quantity': itemQuantity,
                        'notes': itemNotes,
                        'image': imageUrl,
                        'image_id': uniqueFileName,
                        'owner': userLoaded ? user['name'] : '',
                        'owner_phone':
                            FirebaseAuth.instance.currentUser?.phoneNumber ?? ''
                      };

                      _reference.add(dataToSend);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    } catch (e) {
                      const snackBar = SnackBar(
                        content: Text('Some problem occurred!'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      if (kDebugMode) {
                        print(e);
                      }
                    }
                  } else {
                    const snackBar = SnackBar(
                      content: Text('Please add an image!'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              },
              child: const Text('Submit'))
        ],
      ),
    ));
  }

  Future getImages() async {
    final pickedFile = await picker.pickImage(
        requestFullMetadata: true,
        imageQuality: 100,
        maxHeight: 1000,
        maxWidth: 1000,
        source: ImageSource.gallery);
    XFile? xfilePick = pickedFile;

    var pickedFiles = [xfilePick];

    setState(
      () {
        selectedImages.insert(0, File(pickedFiles[0]!.path));
      },
    );
  }
}
