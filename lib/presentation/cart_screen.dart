import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_app/data/item_repository.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';
import 'package:inventory_management_app/util/user_preferences.dart';

// ignore: must_be_immutable
class CartScreen extends StatefulWidget {
  CartScreen({super.key}) {
    _reference = FirebaseFirestore.instance.collection('items');
    _stream = _reference.snapshots();
  }

  late CollectionReference _reference;
  late Stream<QuerySnapshot> _stream;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  GlobalKey<FormState> key = GlobalKey();

  final CollectionReference _reservations =
      FirebaseFirestore.instance.collection('reservations');
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  TextEditingController nameController = TextEditingController();

  Future<void> _selectStartDate(
      BuildContext context, DateTime selectedDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(9999));
    if (picked != null && picked != selectedDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(
      BuildContext context, DateTime selectedDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(9999));
    if (picked != null && picked != selectedDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        child: Form(
      key: key,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
              stream: widget._stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Some error occurred ${snapshot.error}"));
                }
                if (snapshot.hasData) {
                  QuerySnapshot querySnapshot = snapshot.data;
                  List<QueryDocumentSnapshot> documents = querySnapshot.docs;

                  List<Map> items = documents
                      .map((e) => {
                            'id': e.id,
                            'name': e['name'],
                            'quantity': e['quantity'],
                            'notes': e['notes'],
                            'owner': e['owner'],
                            'image': e['image']
                          })
                      .toList();

                  return Expanded(
                      child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            Map thisItem = items[index];
                            return Visibility(
                              visible: UserSimplePreferences.cart
                                  .containsKey(thisItem['id']),
                              child: Card(
                                child: ListTile(
                                  trailing: ElevatedButton(
                                    child: const Text("Remove"),
                                    onPressed: () {
                                      setState(() {
                                        UserSimplePreferences
                                            .removeItemFromCard(thisItem['id']);
                                      });
                                    },
                                  ),
                                  title: Text('${thisItem['name']}'),
                                  subtitle: Row(children: <Widget>[
                                    Text(
                                      'Quantity: ${UserSimplePreferences.cart[thisItem['id']]}',
                                    )
                                  ]),
                                  leading: SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: thisItem.containsKey('image')
                                        ? Image.network('${thisItem['image']}')
                                        : Container(),
                                  ),
                                ),
                              ),
                            );
                          }));
                }
                return const Center(child: CircularProgressIndicator());
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 11,
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.blueGrey[50],
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Your Name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    border: InputBorder.none,
                    hintText: 'Name',
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("${startDate.toLocal()}".split(' ')[0]),
                      const SizedBox(
                        height: 5.0,
                      ),
                      ElevatedButton(
                        onPressed: () => _selectStartDate(context, startDate),
                        child: const Text('Start Date'),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("${endDate.toLocal()}".split(' ')[0]),
                      const SizedBox(
                        height: 5.0,
                      ),
                      ElevatedButton(
                        onPressed: () => _selectEndDate(context, endDate),
                        child: const Text('End Date'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
                onPressed: () async {
                  if (key.currentState!.validate() &&
                      UserSimplePreferences.cart.isNotEmpty) {
                    final DateFormat formatter = DateFormat('dd-MM-yyyy');
                    Map<String, String> dataToSend = {
                      'name': nameController.text,
                      'start_date': formatter.format(startDate).toString(),
                      'end_date': formatter.format(endDate).toString(),
                      'items': json.encode(UserSimplePreferences.cart)
                    };

                    try {
                      UserSimplePreferences.cart.forEach((key, value) async {
                        var item = await getItem(key);
                        if (int.parse(item['quantity']) >= int.parse(value)) {
                          setState(() {
                            UserSimplePreferences.setInStock(true);
                          });
                        } else {
                          setState(() {
                            UserSimplePreferences.setInStock(false);
                          });
                        }
                      });

                      if (UserSimplePreferences.getInStock()) {
                        UserSimplePreferences.cart.forEach((key, value) async {
                          var item = await getItem(key);
                          var newQuantity =
                              int.parse(item['quantity']) - int.parse(value);

                          widget._reference
                              .doc(key)
                              .update({'quantity': newQuantity.toString()});
                        });
                        _reservations.add(dataToSend);
                        if (kDebugMode) {
                          print('boom');
                        }
                        UserSimplePreferences.cart = {};
                        nameController.text = '';
                        UserSimplePreferences.setInStock(false);
                        const snackBar = SnackBar(
                          content: Text('Reservation made successfully! '),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        GoRouter.of(context).go('/');
                      } else {
                        if (kDebugMode) {
                          print('oo oh');
                        }
                        UserSimplePreferences.cart = {};
                        nameController.text = '';
                        GoRouter.of(context).go('/');
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print(e);
                      }
                      GoRouter.of(context).go('/');
                    }
                  }
                },
                child: const Text("Reserve")),
          )
        ],
      ),
    ));
  }
}
