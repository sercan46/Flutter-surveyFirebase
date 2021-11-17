import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Anket')),
        body: const SurveyList(),
      ),
    );
  }
}

/*class SurveyList extends StatelessWidget {
  const SurveyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('dilanketi').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error:${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text('Loading...');
          default:
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                return ListTile(
                  title: Text(document['isim']),
                  subtitle: Text(document['oy'].toString()),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
*/
class SurveyList extends StatefulWidget {
  const SurveyList({Key? key}) : super(key: key);

  @override
  _SurveyListState createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('dilanketi').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          } else {
            return buildBody(context, snapshot.data!.docs);
          }
        });
    //buildBody(context, sahteSnapshot);
  }

  Widget buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: EdgeInsets.only(top: 20),
      children:
          snapshot.map<Widget>((data) => buildListItem(context, data)).toList(),
    );
  }

  buildListItem(BuildContext context, DocumentSnapshot data) {
    final row = Anket.fromSnapshot(data);
    return Padding(
      key: ValueKey(row.isim),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0)),
        child: ListTile(
          title: Text(row.isim.toString()),
          trailing: Text(row.oy.toString()),
          onTap: () {
            // row.reference!.update({'oy': int.parse(row.oy.toString()) + 1});
            FirebaseFirestore.instance.runTransaction((transaction) async {
              final freshSnapshot = await transaction.get(row.reference!);
              final fresh = Anket.fromSnapshot(freshSnapshot);
              await transaction.update(
                  (row.reference!), {'oy': int.parse(row.oy.toString()) + 1});
            });
          },
        ),
      ),
    );
  }
}

final sahteSnapshot = [
  {"isim": "C#", "oy": 3},
  {"isim": "Java", "oy": 4},
  {"isim": "Dart", "oy": 5},
  {"isim": "C++", "oy": 7},
  {"isim": "Python", "oy": 900},
  {"isim": "Perl", "oy": 2}
];

class Anket {
  String? isim;
  int? oy;
  DocumentReference? reference;

  Anket.fromMap(map, {this.reference})
      : assert(map['isim'] != null),
        assert(map['oy'] != null),
        isim = map['isim'],
        oy = map['oy'];
  Anket.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);
}
