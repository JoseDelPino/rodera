import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:rodera/viewIncidenceTabbed.dart';
import 'package:rodera/main.dart';

class Feed extends StatefulWidget {
  Feed({
    Key key,
    this.myFirebaseUser,
  }) : super(key: key);

  final FirebaseUser myFirebaseUser;

  @override
  _FeedState createState() => new _FeedState();
}

Future<List<Map<String, dynamic>>> fetchFeed(String uid) async {
  final response = await http.get(
      'https://us-central1-rodera.cloudfunctions.net/getFeedRodera?uid=' + uid);

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    print("Fetch correcto");
    print(response.body);
    List<Map<String, dynamic>> decodedFeed =
        jsonDecode(response.body).cast<Map<String, dynamic>>();
    return decodedFeed;
  } else {
    print("Error en el fetch");
    // If that response was not OK, throw an error.
    throw new List<Map<String, dynamic>>();
  }
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchFeed(widget.myFirebaseUser.uid.toString()),
      builder: (context, feed) {
        if (!feed.hasData) return CircularProgressIndicator();
        if (feed.data.length == 0)
          return new Image.asset("images/empty_feed.png");
        return ListView(
          padding: const EdgeInsets.only(top: 20.0),
          children: feed.data
              .map((data) => _buildFeedListItem(context, data))
              .toList(),
        );
      },
    );
  }

  /*Widget _buildFeedList(BuildContext context, List<Map<String, dynamic>> feed) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: feed.map((data) => _buildFeedListItem(context, data)).toList(),
    );
  }*/

  Widget _buildFeedListItem(BuildContext context, Map<String, dynamic> post) {
    IconData categoryIcon;
    Color categoryColor;

    switch (post["category"]) {
      case "Acerado y asfaltado":
        categoryIcon = Icons.directions_car;
        categoryColor = Colors.red;
        break;
      case "Alcantarillado":
        categoryIcon = Icons.invert_colors;
        categoryColor = Colors.blue;
        break;
      case "Alumbrado":
        categoryIcon = Icons.lightbulb_outline;
        categoryColor = Colors.amber;
        break;
      case "Limpieza":
        categoryIcon = Icons.delete;
        categoryColor = Colors.purple;
        break;
      case "Mobiliario urbano":
        categoryIcon = Icons.event_seat;
        categoryColor = Colors.deepOrangeAccent;
        break;
      case "Vegetación y sombra":
        categoryIcon = Icons.nature_people;
        categoryColor = Colors.lightGreen;
        break;
      case "Transporte":
        categoryIcon = Icons.directions_bus;
        categoryColor = Colors.pink;
        break;
      case "Otros":
        categoryIcon = Icons.category;
        categoryColor = Colors.black54;
        break;
    }

    bool liked = false;

    void _updateFeelings(bool upvote) async {
      print("Se ha llamado a updateFeeling con upvote: " + upvote.toString());
      if (upvote) {
        Firestore.instance.runTransaction((transaction) async {
          print(widget.myFirebaseUser.uid.toString() +
              ":" +
              post["postID"].toString());
          await transaction.set(
              Firestore.instance.collection('feelings').document(
                  widget.myFirebaseUser.uid.toString() +
                      ":" +
                      post["postID"].toString()),
              {'state': 1});
          setState(() {
            liked = true;
            post["score"] = post["score"]+1;
          });
        });
      } else {
        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
              Firestore.instance.collection('feelings').document(
                  widget.myFirebaseUser.uid.toString() +
                      ":" +
                      post["postID"].toString()),
              {'state': 0});
        });
        setState(() {
          liked = false;
          post["score"] = post["score"]-1;
        });
      }
    }

    IconButton buildLikeIcon() {
      Color color;
      IconData icon;

      if (liked) {
        color = Colors.pink;
        icon = Icons.favorite;
      } else {
        icon = Icons.favorite_border;
      }
      return IconButton(
        icon: Icon(icon),
        color: color,
        splashColor: Colors.pink[100],
        onPressed: () =>
            {liked ? _updateFeelings(false) : _updateFeelings(true)},
      );
    }

    Future getFeeling() async {
      await Firestore.instance
          .collection('feelings')
          .document(
            widget.myFirebaseUser.uid.toString() +
                ":" +
                post["postID"].toString(),
          )
          .get()
          .then((feeling) =>
              {feeling.data["state"] == 1 ? liked = true : liked = false});
    }

    return new FutureBuilder(
        future: getFeeling(),
        builder: (BuildContext context, AsyncSnapshot none) {
          return Card(
            child: new InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewIncidence(
                              documentSnapshot: post,
                              myFirebaseUser: widget.myFirebaseUser,
                            )),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          child: Text(post["title"]),
                          padding: EdgeInsets.all(10.0),
                        ),
                        Padding(
                          child: Text(post["description"]),
                          padding: EdgeInsets.all(10.0),
                        ),
                      ],
                    ),
                    Column(

                      children: <Widget>[
                        buildLikeIcon(),
                        Text(post["score"].toString()),
                      ],
                    )
                  ],
                )
                /*child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Padding(
                      child: Text(post["title"]),
                      padding: EdgeInsets.all(10.0),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          child: Text(post["description"]),
                          padding: EdgeInsets.all(10.0),
                        ),
                        Transform(
                          transform: new Matrix4.identity()..scale(0.9),
                          child: Chip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  categoryIcon,
                                  color: categoryColor,
                                ),
                                Text(
                                  "  " + post["category"],
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(5.0),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(

                      children: <Widget>[
                        buildLikeIcon(),
                        Text(post["score"].toString())
                      ],
                    ),
                  ),
                ],
              ),*/
                ),
          );
        });
  }
}
