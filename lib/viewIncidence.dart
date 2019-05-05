import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class ViewIncidence extends StatefulWidget {
  ViewIncidence(
      {Key key, this.title, this.description, this.score, this.reference})
      : super(key: key);

  final String title;
  final String description;
  final double score;
  final String reference;

  @override
  _ViewIncidence createState() => _ViewIncidence();
}

class _ViewIncidence extends State<ViewIncidence> {
  Future<String> _getImage() async {
    print(widget.reference);
    return await FirebaseStorage.instance
        .ref()
        .child(widget.reference.toString())
        .getDownloadURL();
  }

  Widget _buildAll(String uri) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          SizedBox(height: 20.0),
          new Container(

            child: uri != null ? Container(

                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 2,
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: new NetworkImage(
                          "https://firebasestorage.googleapis.com/v0/b/rodera.appspot.com/o/-Le7kMcU5V8KGbQZxBls?alt=media&token=2ba02ba9-a162-43b8-8b13-04b2c13de46f")),
                ),):new Container(),
          ),
          SizedBox(height: 20.0),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(

                  title: Text(widget.title),
                  subtitle: Text(widget.description),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getImage(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return _buildAll("");
          case ConnectionState.done:
            print(snapshot.data);
            print("BADABADUM");
            return _buildAll(snapshot.data);
          //return Text('Press button to start.');
        }
        return null; // unreachable
      },
    );
  }
}
