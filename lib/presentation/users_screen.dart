import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';
import 'package:toggle_switch/toggle_switch.dart';

// ignore: must_be_immutable
class UsersScreen extends StatelessWidget {
  UsersScreen({super.key}) {
    _stream = _reference.snapshots();
  }

  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('users');

  TextEditingController phoneController = TextEditingController(text: "+20");
  TextEditingController nameController = TextEditingController();
  String userType = 'user';

  late Stream<QuerySnapshot> _stream;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
              stream: _stream,
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
                            'phone': e['phone'],
                            'type': e['type']
                          })
                      .toList();

                  return Expanded(
                    child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map thisItem = items[index];

                          return SizedBox(
                            height: MediaQuery.of(context).size.height / 12,
                            child: Card(
                              child: ListTile(
                                title: Text(thisItem['name']),
                                subtitle: Text(thisItem['phone']),
                                trailing: Visibility(
                                  visible: thisItem['type'] != 'admin',
                                  replacement: const Text("Admin"),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _reference.doc(thisItem['id']).delete();
                                    },
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                          );
                        }),
                  );
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
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    border: InputBorder.none,
                    hintText: 'Name',
                    label: Text('Enter Name'),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 11,
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.blueGrey[50],
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    border: InputBorder.none,
                    hintText: 'Phone Number',
                    label: Text('Enter phone number with country code'),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 13,
              color: Colors.white,
              padding:
                  const EdgeInsets.only(left: 8, right: 8, bottom: 15, top: 8),
              child: ToggleSwitch(
                inactiveBgColor: Colors.blueGrey[50],
                initialLabelIndex: 0,
                totalSwitches: 2,
                labels: const ['User', 'Admin'],
                onToggle: (index) {
                  if (index == 0) {
                    userType = 'user';
                  } else {
                    userType = 'admin';
                  }

                  if (kDebugMode) {
                    print('switched to: $index');
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 13,
              color: Colors.white,
              padding:
                  const EdgeInsets.only(left: 8, right: 8, bottom: 15, top: 8),
              child: ElevatedButton.icon(
                style: ButtonStyle(
                    shape:
                        MaterialStateProperty.all(const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ))),
                onPressed: () async {
                  if (phoneController.text.isNotEmpty &&
                      nameController.text.isNotEmpty) {
                    final user = await _reference
                        .doc(phoneController.text.replaceAll(" ", ""))
                        .get();
                    if (!user.exists) {
                      Map<String, String> dataToSend = {
                        'name': nameController.text,
                        'phone': phoneController.text.replaceAll(" ", ""),
                        'type': userType,
                      };

                      try {
                        _reference
                            .doc(phoneController.text.replaceAll(" ", ""))
                            .set(dataToSend);
                        phoneController.text = '';
                        nameController.text = '';
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                      }
                    }
                  }
                },
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Add User'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
