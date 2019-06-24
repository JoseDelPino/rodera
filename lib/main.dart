import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import './home.dart';
import './addIncidence.dart';
import './signIn.dart';
import './signUp.dart';
import './splash_page.dart';

void main() => runApp(Padding(
      padding: const EdgeInsets.all(8.0),
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rodera',
      //home: SignIn(),
      home: MySplashScreen(),
    );
  }
}

class Record {
  final String title;
  final String description;
  final int score;
  final GeoPoint position;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['title'] != null),
        assert(map['description'] != null),
        assert(map['score'] != null),
        assert(map['position'] != null),
        title = map['title'],
        description = map['description'],
        score = map['score'],
        position = map['position'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$title:$score>";
}

class Profile {
  String name;
  String email;
  Image image;
  Profile(this.name, this.email, this.image);
}

class User {
  String name;
  String email;
  String uid;
  List<dynamic> followers;
  List<dynamic> following;

  User(this.name, this.email, this.uid, this.followers, this.following);

  User.fromFirebaseUser(FirebaseUser firebaseUser)
      :
        name = firebaseUser.displayName,
        email = firebaseUser.email,
        uid = firebaseUser.uid,
        followers = new List(),
        following = new List();
}

class Comment {
  String user;
  String comment;


  Comment(this.user, this.comment, );
}
