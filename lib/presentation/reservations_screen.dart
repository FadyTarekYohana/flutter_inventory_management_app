import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_app/presentation/app_scaffold.dart';
import 'package:inventory_management_app/presentation/reservation_details_screen.dart';

// ignore: must_be_immutable
class ReservationsScreen extends StatefulWidget {
  ReservationsScreen({super.key}) {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('reservations');
    _stream = reference.snapshots();
  }
  late Stream<QuerySnapshot> _stream;
  @override
  State<ReservationsScreen> createState() => ReservationsScreenState();
}

class ReservationsScreenState extends State<ReservationsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: StreamBuilder<QuerySnapshot>(
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
                        'items': e['items'],
                        'name': e['name'],
                        'start_date': e['start_date'],
                        'end_date': e['end_date']
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
                            'From ${thisItem['start_date']} to ${thisItem['end_date']}',
                          )
                        ]),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReservationDetailsScreen(
                                itemId: thisItem['id'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  });
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
