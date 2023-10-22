import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';

class UsersScreen extends StatelessWidget {
  UsersScreen({super.key}) {
    _stream = _reference.snapshots();
  }

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('users');

  TextEditingController phoneController = TextEditingController(text: "+20");

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
                      .map((e) =>
                          {'id': e.id, 'phone': e['phone'], 'type': e['type']})
                      .toList();

                  return Expanded(
                    child: Container(
                      child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            Map thisItem = items[index];

                            return Visibility(
                              visible: thisItem['type'] != 'admin',
                              replacement: Container(),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 12,
                                child: Card(
                                  child: ListTile(
                                    title: Text('${thisItem['phone']}'),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _reference.doc(thisItem['id']).delete();
                                      },
                                    ),
                                    subtitle: Row(children: <Widget>[]),
                                    onTap: () {},
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 9,
              color: Colors.white,
              padding: const EdgeInsets.only(
                  left: 14, right: 14, bottom: 15, top: 16),
              child: Material(
                color: Colors.blueGrey[50],
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    border: InputBorder.none,
                    hintText: 'Phone Number',
                    label: Text('Enter phone number with country code'),
                    suffixIcon: IconButton(
                        onPressed: () async {
                          String phone = phoneController.text;
                          final user = await _reference.doc(phone).get();
                          if (!user.exists) {
                            Map<String, String> dataToSend = {
                              'phone': phone,
                              'type': 'user',
                            };

                            try {
                              _reference.doc(phone).set(dataToSend);
                              phoneController.text = '';
                            } catch (e) {}
                          }
                        },
                        icon: const Icon(Icons.person_add_outlined)),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
