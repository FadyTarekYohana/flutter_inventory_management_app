import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/data/item_repository.dart';
import 'package:inventory_management_app/data/user_repository.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';
import 'package:inventory_management_app/util/user_preferences.dart';

// ignore: must_be_immutable
class ItemDetailsScreen extends StatefulWidget {
  ItemDetailsScreen({super.key, required this.itemId}) {
    _reference = FirebaseFirestore.instance.collection('items').doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;
  late DocumentReference _reference;
  late Future<DocumentSnapshot> _futureData;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late dynamic user;
  late dynamic item;
  late Map data;

  bool userLoaded = false;
  bool itemLoaded = false;
  // ignore: prefer_typing_uninitialized_variables
  var quantity;
  // ignore: prefer_typing_uninitialized_variables
  var dropDownValue;

  loadData() async {
    item = await getItem(widget.itemId);

    setState(() {
      if (item != null) {
        itemLoaded = true;
        if (item['quantity'] == '0') {
          quantity = ['0'];
        } else {
          quantity = [
            for (var i = 1; i <= int.parse(item['quantity']); i++) i.toString()
          ];
        }

        dropDownValue = quantity[0];
      }
    });

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
    return AppScaffold(
      child: FutureBuilder<DocumentSnapshot>(
        future: widget._futureData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Some error occurred ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            DocumentSnapshot documentSnapshot = snapshot.data;
            data = documentSnapshot.data() as Map;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width,
                    child: data.containsKey('image')
                        ? Image.network('${data['image']}')
                        : Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${data['name']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'From: ${data['owner']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    'Phone: ${data['owner_phone']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Notes: ${data['notes']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Quantity"),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            value: dropDownValue,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: quantity
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropDownValue = newValue!;
                              });
                            },
                          )),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: quantity[0] == '0'
                              ? null
                              : () {
                                  UserSimplePreferences.addItemToCart(
                                      widget.itemId, dropDownValue);
                                  const snackBar = SnackBar(
                                    content: Text(
                                        'Item added to cart successfully! '),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                          child: const Text(
                            'Add To Cart',
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            GoRouter.of(context).go('/cart');
                          },
                          child: const Text('Go To Cart')),
                    )
                  ]),
                  Visibility(
                    visible: userLoaded ? user['type'] == 'admin' : false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                Reference storage =
                                    FirebaseStorage.instance.ref();
                                await storage
                                    .child('images/${item['image_id']}')
                                    .delete();
                                widget._reference.delete();

                                GoRouter.of(context).go('/');
                              },
                              child: const Text('Delete Item')),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
