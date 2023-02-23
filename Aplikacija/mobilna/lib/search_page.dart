import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mobilna/main.dart';
import 'package:mobilna/pregled_usluge.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final User user = FirebaseAuth.instance.currentUser!;

  bool filtrirano = false;

  List<Map<String, dynamic>> Kategorije = [];
  Map<String, dynamic> kategorija = {};

  List<String> Nivoi = [];
  String Nivo = "";

  List<String> Gradovi = [];
  String grad = "";

  @override
  void initState() {
    FirebaseFirestore.instance.collection('kategorije').get().then((value) {
      List<Map<String, dynamic>> data = [];
      value.docs.forEach((e) {
        final el = e.data();
        data.add(el);
      });
      setState(() {
        Kategorije = data;
        kategorija = data.first;
      });
    });

    FirebaseFirestore.instance.collection('lokacija').get().then((value) {
      List<String> data = [];
      value.docs.forEach((e) {
        final el = e.data();
        data.add(el['grad']);
      });
      setState(() {
        Gradovi = data;
        grad = data.first;
      });
    });
    super.initState();
  }

  void setKategoriju(value) {
    List<String> temp = [];
    value['stepen'].forEach((val) {
      temp.add(val);
    });
    debugPrint(temp.first);
    setState(() {
      Nivoi = temp;
      Nivo = temp.first;
      kategorija = value;
    });
    navigatorKey.currentState!.pop();
    filtriraj();
  }

  void filtriraj() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Primenite filter'),
        content: Column(children: [
          Text(
            "Kategorija",
            style: TextStyle(fontSize: 20),
          ),
          DropdownButton<Map<String, dynamic>>(
            value: kategorija,
            onChanged: (value) => setKategoriju(value),
            items: Kategorije.map<DropdownMenuItem<Map<String, dynamic>>>(
                (Map<String, dynamic> value) {
              return DropdownMenuItem(
                  value: value, child: Text(value['nazivKategorije']));
            }).toList(),
          ),
          Container(
            height: 20,
          ),
          Text(
            "Nivo stručne spreme",
            style: TextStyle(fontSize: 20),
          ),
          DropdownButton<String>(
            value: Nivo,
            onChanged: (value) {
              setState(() {
                Nivo = value!;
              });
            },
            items: Nivoi.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
          ),
          Container(
            height: 20,
          ),
          Text(
            "Lokacija",
            style: TextStyle(fontSize: 20),
          ),
          DropdownButton<String>(
            value: grad,
            onChanged: (value) {
              setState(() {
                grad = value!;
              });
            },
            items: Gradovi.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
          ),
        ]),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                filtrirano = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Resetuj'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                filtrirano = true;
              });
              Navigator.pop(context);
            },
            child: const Text('Primeni'),
          ),
        ],
      ),
    );
  }

  void pogledajUslugu(String uslugaID) {
    navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => UslugaPage(
              uslugaID: uslugaID,
              tutor: false,
            )));
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> uslugeStream;
    if (!filtrirano) {
      uslugeStream =
          FirebaseFirestore.instance.collection('usluge').limit(15).snapshots();
    } else {
      uslugeStream = FirebaseFirestore.instance
          .collection("usluge")
          .where("kategorija", isEqualTo: kategorija['nazivKategorije'])
          .where("stepen", isEqualTo: Nivo)
          .where("lokacija", isEqualTo: grad)
          .snapshots();
    }
    ;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Pretraga",
          style: TextStyle(color: Color.fromRGBO(31, 93, 120, 1)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt_outlined,
              color: Color.fromRGBO(31, 93, 120, 1),
            ),
            onPressed: filtriraj,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: uslugeStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData == false) {
            return Center(child: Text("No data !"));
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> podatak =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                leading: podatak['fotografija'] != null &&
                        podatak['fotografija'] != ""
                    ? SizedBox(
                        width: 100,
                        height: 50,
                        child: Image.network(
                          podatak['fotografija'],
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    : Icon(Icons.no_photography_outlined),
                title: Text(podatak['nazivUsluge']),
                subtitle: Row(
                  children: [
                    RatingBarIndicator(
                      rating: podatak['srednjaOcena'] != null
                          ? podatak['srednjaOcena'].toDouble()
                          : 0,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemSize: 15,
                      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    podatak['brojOcena'] != null
                        ? Text(
                            "od " + podatak['brojOcena'].toString() + " ocena")
                        : Text("od 0 ocena")
                  ],
                ),
                onTap: () => pogledajUslugu(document.id),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
