import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rodera/viewMyProfile.dart';
import 'package:rodera/viewOtherProfile.dart';
import 'package:rodera/main.dart';

class Search extends StatefulWidget {
  Search({Key key, this.myFirebaseUser}) : super(key: key);

  final FirebaseUser myFirebaseUser;

  @override
  _SearchState createState() => new _SearchState();
}

class _SearchState extends State<Search> {
  var searchResults = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        searchResults = [];
      });
    } else {
      setState(() {
        searchResults = [];
      });
      Firestore.instance
          .collection('users')
          .where('name', isEqualTo: value)
          .getDocuments()
          .then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          if (docs.documents[i].documentID != widget.myFirebaseUser.uid)
            searchResults.add(docs.documents[i]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: ListView(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          onChanged: (val) {
            initiateSearch(val);
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search for a user or post',
          ),
        ),
      ),
      SizedBox(height: 20.0),
      GridView.count(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          crossAxisCount: 2,
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 6.0,
          primary: false,
          shrinkWrap: true,
          children: searchResults.map((documentSnapshot) {
            return buildResultCard(
                context, documentSnapshot, widget.myFirebaseUser);
          }).toList())
    ]));
  }
}

Widget buildResultCard(BuildContext context, DocumentSnapshot documentSnapshot,
    FirebaseUser myFirebaseUser) {
  return FlatButton(
      onPressed: () {
        print(documentSnapshot.data['followers']);
        User otherUser = User(
            documentSnapshot.data['name'],
            documentSnapshot.data['email'],
            documentSnapshot.documentID,
            new List<dynamic>.from(documentSnapshot.data['followers']),
            new List<dynamic>.from(documentSnapshot.data['following']));
        User myUser = User.fromFirebaseUser(myFirebaseUser);
        print("myUser: " + myUser.uid + " otherUser: " + otherUser.uid);
        if (myUser.uid != otherUser.uid) {
          print("No son iguales");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => viewOtherProfile(
                      otherUser: otherUser,
                      myUser: myUser,
                    )),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    viewMyProfile(myFirebaseUser: myFirebaseUser)),
          );
        }
      },
      child: Text(
        documentSnapshot.data['name'],
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
        ),
      ));
}
