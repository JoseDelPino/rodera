/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:rodera/viewIncidenceTabbed.dart';
import 'package:rodera/main.dart';

class Feed extends StatefulWidget {
  Feed({
    Key key,
    this.user,
  }) : super(key: key);

  final FirebaseUser user;

  @override
  _FeedState createState() => new _FeedState();
}

class _FeedState extends State<Feed> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('incidences').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return _buildFeedList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildFeedList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children:
          snapshot.map((data) => _buildFeedListItem(context, data)).toList(),
    );
  }

  Widget _buildFeedListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    StreamController<List<Color>> colorsStream =
        new StreamController<List<Color>>();

    void _updateFeelings(bool upvote, Color color) async {
      if (upvote) {
        if (color == Colors.black) {
          Firestore.instance.runTransaction((transaction) async {
            await transaction.set(
                Firestore.instance.collection('feelings').document(
                    widget.user.uid.toString() +
                        ":" +
                        record.reference.documentID.toString()),
                {'state': 1});
          });
          colorsStream.sink.add([Colors.green, Colors.black]);
        } else {
          Firestore.instance.runTransaction((transaction) async {
            await transaction.set(
                Firestore.instance.collection('feelings').document(
                    widget.user.uid.toString() +
                        ":" +
                        record.reference.documentID.toString()),
                {'state': 0});
          });
          colorsStream.sink.add([Colors.black, Colors.black]);
        }
      } else {
        if (color == Colors.black) {
          Firestore.instance.runTransaction((transaction) async {
            await transaction.set(
                Firestore.instance.collection('feelings').document(
                    widget.user.uid.toString() +
                        ":" +
                        record.reference.documentID.toString()),
                {'state': -1});
          });
          colorsStream.sink.add([Colors.black, Colors.red]);
        } else {
          Firestore.instance.runTransaction((transaction) async {
            await transaction.set(
                Firestore.instance.collection('feelings').document(
                    widget.user.uid.toString() +
                        ":" +
                        record.reference.documentID.toString()),
                {'state': 0});
            print(widget.user.uid);
          });
          colorsStream.sink.add([Colors.black, Colors.black]);
        }
      }
    }

    return new StreamBuilder(
        stream: colorsStream.stream,
        initialData: [Colors.black, Colors.black],
        builder: (BuildContext context, AsyncSnapshot<List> colors) {
          return Center(
            child: Card(
              child: new InkWell(
                onTap: () {
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewIncidence(
                              documentSnapshot: ,
                              myFirebaseUser: widget.user,
                            )),
                  );*/
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.place),
                      title: Text(record.title),
                      subtitle: Text(record.description),
                    ),
                    ButtonTheme.bar(
                      child: ButtonBar(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.thumb_up),
                            color: colors.data[0],
                            splashColor: Colors.green[50],
                            onPressed: () =>
                                _updateFeelings(true, colors.data[0]),
                          ),
                          IconButton(
                            icon: Icon(Icons.thumb_down),
                            color: colors.data[1],
                            splashColor: Colors.red[50],
                            onPressed: () =>
                                _updateFeelings(false, colors.data[1]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
*/