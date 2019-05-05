import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rodera/main.dart';

class viewOtherProfile extends StatefulWidget {
  viewOtherProfile({Key key, this.otherUser, this.myUser}) : super(key: key);

  final User otherUser;
  final User myUser;
  @override
  _viewOtherProfileState createState() => new _viewOtherProfileState();
}

class _viewOtherProfileState extends State<viewOtherProfile> {

  Future<String> _getImageURI() async {
    print("******************************************* COMIENZO ERROR"+ widget.otherUser.following.toString());
    String uri;
    try {
      uri = await FirebaseStorage.instance
          .ref()
          .child("profile_images/" + widget.otherUser.uid.toString())
          .getDownloadURL();
    } on Exception catch(e){
      uri = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
    }
    print("******************************************* FINAL ERROR"+ widget.otherUser.followers.toString());
    return uri;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getImageURI(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(child: RefreshProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return _buildProfileView(snapshot.data);
        }
        return null; // unreachable
      },
    );
  }

  Widget _buildProfileView(String uri) {
    return Scaffold(
      appBar: AppBar(
        title: new Image.asset("images/rodera_logo_bw_warm_simple.png"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
              child: new CircleAvatar(
                  backgroundImage: new NetworkImage(uri), radius: 60.0)),
          Container(
            margin: const EdgeInsets.only(right: 50.0, left: 50.0, top: 15.0),
            child: ListTile(
              title: Text("Nombre:"),
              subtitle: Text(widget.otherUser.email == null
                  ? "No se ha elegido un nombre."
                  : widget.otherUser.email.toString()),
            ),
          ),
          Container(
            margin:
            const EdgeInsets.only(right: 50.0, left: 50.0, bottom: 15.0),
            child: ListTile(
              title: Text("Email:"),
              subtitle: Text(widget.otherUser.email == null
                  ? "No se ha elegido un email."
                  : widget.otherUser.email.toString()),
            ),
          ),
          Container(
            child: widget.otherUser.followers.contains(widget.myUser.uid) ? RaisedButton(
              onPressed: () => setState(() {

                Firestore.instance.collection('users').document(widget.otherUser.uid)
                    .updateData({"followers": FieldValue.arrayRemove([widget.myUser.uid])});
                Firestore.instance.collection('users').document(widget.myUser.uid).
                updateData({"following": FieldValue.arrayRemove([widget.otherUser.uid])});

                widget.otherUser.followers.remove(widget.myUser.uid);
                widget.myUser.following.remove(widget.otherUser.uid);
              }),
              child: Text('UNFOLLOW'),
              color: Colors.black,
              textColor: Colors.white,

            ) : RaisedButton(
              onPressed: () => setState(() {
                print("UID: "+widget.otherUser.uid.toString());
                Firestore.instance.collection('users').document(widget.otherUser.uid)
                    .updateData({"followers": FieldValue.arrayUnion([widget.myUser.uid])});
                Firestore.instance.collection('users').document(widget.myUser.uid).
                    updateData({"following": FieldValue.arrayUnion([widget.otherUser.uid])});

                widget.otherUser.followers.add(widget.myUser.uid);
                widget.myUser.following.add(widget.otherUser.uid);
              }),
              child: Text('FOLLOW'),
              color: Colors.white,
              textColor: Colors.black,

            ), //or any other widget but not null
          ),
        ],
      ),
    );
  }

}
