import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

var message1 = "output ";
var output;
var cmd;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final databaseReference = FirebaseFirestore.instance;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Firestore App"),
          backgroundColor: Colors.pink[300],
        ),
        body: mybody(),
        
      ),
      debugShowCheckedModeBanner:false,
    );
  }
}

class mybody extends StatefulWidget {
  @override
  _mybodyState createState() => _mybodyState();
}

class _mybodyState extends State<mybody> {
  web(cmd) async {
    print(cmd);
    var url = "http://192.168.43.111/cgi-bin/task2.py?x=${cmd}";
    var r = await http.get(url);
    print(r.body);
    setState(() {
      output = r.body;
    });

    createRecord();

    print('test123');
  }

  void Retrive() {
    setState(() {
      message1 = "Still fetching the output be patience";
    });
    databaseReference.collection("date command").snapshots().listen((result) {
      result.docs.forEach((result) {
        Future.delayed(const Duration(milliseconds: 4000), () {
          setState(() {
            message1 = result.data().toString();
          });
        });
      });
    });
  }

  void createRecord() async {
    await databaseReference.collection("date command").doc("result").set({
      'output': output,
    });
    Retrive();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          onChanged: (b) {
            cmd = b;
          },
          decoration: new InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter any Linux command',
              suffixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.all(20)),
        ),
        RaisedButton(
          color: Colors.pink[300],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(100.0))),
          onPressed: () {
            web(cmd);
          },
          child: Text('Execute'),
          textColor: Colors.white,
        ),
        Container(
          child: Text(message1),
          decoration: BoxDecoration(
            color: Colors.red[50],
          ),
        )
      ],
    );
  }
}