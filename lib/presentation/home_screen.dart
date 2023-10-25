import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';

import '../data/user_repository.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key}) {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('items');
    _stream = reference.snapshots();
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
                          leading: SizedBox(
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
          visible: FirebaseAuth.instance.currentUser != null,
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
