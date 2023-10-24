import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';

import '../data/user_repository.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key}) {
    CollectionReference _reference =
        FirebaseFirestore.instance.collection('items');
    _stream = _reference.snapshots();
  }

  late Stream<QuerySnapshot> _stream;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late dynamic user;

  bool userLoaded = false;

  loadData() async {
    try {
      user = await getUser();
    } catch (e) {
      print(e);
    }

    setState(() {
      if (user != null) {
        userLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Stack(children: [
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

                return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map thisItem = items[index];
                      return Card(
                        child: ListTile(
                          title: Text('${thisItem['name']}'),
                          subtitle: Row(children: <Widget>[
                            Text(
                              'Quantity: ${thisItem['quantity']}',
                            )
                          ]),
                          leading: Container(
                            height: 80,
                            width: 80,
                            child: thisItem.containsKey('image')
                                ? Image.network('${thisItem['image']}')
                                : Container(),
                          ),
                          onTap: () {
                            GoRouter.of(context)
                                .go('/itemdetails', extra: thisItem['id']);
                          },
                        ),
                      );
                    });
              }
              return const Center(child: CircularProgressIndicator());
            }),
        Visibility(
          visible: userLoaded,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  GoRouter.of(context).go('/additem');
                },
              ),
            ),
          ),
        )
      ]),
    );
  }
}
