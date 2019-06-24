import 'dart:async';
import 'dart:core';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rodera/main.dart';

class ViewIncidence extends StatefulWidget {
  ViewIncidence({Key key, this.documentSnapshot, this.myFirebaseUser})
      : super(key: key);

  final Map<String, dynamic> documentSnapshot;
  final FirebaseUser myFirebaseUser;

  @override
  _ViewIncidence createState() => _ViewIncidence();
}

class _ViewIncidence extends State<ViewIncidence> {
  Future<String> _getImage() async {
    print(widget.documentSnapshot["postID"]);
    return await FirebaseStorage.instance
        .ref()
        .child(widget.documentSnapshot["postID"].toString())
        .getDownloadURL();
  }

  Widget Info(String uri) {
    IconData categoryIcon;
    Color categoryColor;

    switch (widget.documentSnapshot["category"]) {
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
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 20.0),
            new Container(
              child: uri != null
                  ? Container(
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width / 1.2,
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        image: new DecorationImage(
                            fit: BoxFit.scaleDown,
                            image: new NetworkImage(
                                "https://firebasestorage.googleapis.com/v0/b/rodera.appspot.com/o/"+widget.documentSnapshot["postID"]+"?alt=media&token=2ba02ba9-a162-43b8-8b13-04b2c13de46f")),
                      ),
                    )
                  : new Container(),
            ),
            SizedBox(height: 20.0),
            Transform(
              transform: new Matrix4.identity()..scale(0.9),
              child: Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      categoryIcon,
                      color: Colors.white,
                    ),
                    Text(
                      "  " + widget.documentSnapshot["category"],
                    ),
                  ],
                ),
                labelStyle: TextStyle(color: Colors.white),
                backgroundColor: categoryColor,
                padding: EdgeInsets.all(5.0),
              ),
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(widget.documentSnapshot["description"]),
                    //Comment for git
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget Map() {

    GeoPoint position = new GeoPoint(widget.documentSnapshot["position"]["_latitude"], widget.documentSnapshot["position"]["_longitude"]) ;
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      markers: <Marker>{
        Marker(
          markerId: MarkerId(
              position.latitude.toString() + position.longitude.toString()),
          position: LatLng(position.latitude, position.longitude),
        )
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 13,
      ),
    );
  }

  Widget Comments() {
    final textController = TextEditingController();
    return Column(
      children: <Widget>[
        SizedBox(height: 20.0),
        Container(
          margin: const EdgeInsets.only(
              right: 30.0, left: 30.0, top: 15.0, bottom: 15.0),

        child: TextField(
          controller: textController,
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.add_comment),
            hintText: 'Share your thoughts...',
          ),
        ),),
        RaisedButton(
          onPressed: () {
            var comment = {
              "userName": widget.myFirebaseUser.displayName,
              "userUID": widget.myFirebaseUser.uid,
              "textComment": textController.text,
            };
            Firestore.instance
                .collection('incidences')
                .document(widget.documentSnapshot["postID"].toString())
                .updateData({
              "comments": FieldValue.arrayUnion([comment])
            });
            textController.clear();
            widget.documentSnapshot["comments"].add(comment);
          },
          child: const Icon(Icons.send),
          color: Colors.black,
          textColor: Colors.white,
        ),
        SizedBox(height: 20.0),
        Expanded(
            child: ListView.builder(
          itemCount: widget.documentSnapshot["comments"].length,
          itemBuilder: (BuildContext ctxt, int index) {

            return new ListTile(
              leading: new CircleAvatar(
                child: Text(widget.documentSnapshot["comments"][index]["userName"][0]),

              ),
              title: new Text(widget.documentSnapshot["comments"][index]["textComment"]),
            );
          },
        ))
      ],
    );
  }

  Widget _actionButton() {
    print(widget.documentSnapshot["user"].toString());
    print(widget.myFirebaseUser.uid.toString());
    return widget.documentSnapshot["user"].toString() == widget.myFirebaseUser.uid.toString() ? FloatingActionButton(
        shape: StadiumBorder(),
        onPressed: (){
          Firestore.instance.collection('incidences').document( widget.documentSnapshot["postID"].toString()).delete();
          FirebaseStorage.instance
              .ref()
              .child(widget.documentSnapshot["postID"].toString()).delete();
          Navigator.pop(context);
        },
        backgroundColor: Colors.red,
        child: Icon(
          Icons.clear,
          size: 20.0,
        )) : null;
  }

  Widget _buildAll(String uri) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: _actionButton(),
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info)),
              Tab(icon: Icon(Icons.map)),
              Tab(icon: Icon(Icons.comment)),
            ],
            labelColor: Colors.black,
          ),
          title: Text(widget.documentSnapshot["title"], style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            Info(uri),
            Map(),
            Comments(),
          ],
        ),
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
            return _buildAll(snapshot.data);
        }
        return null; // unreachable
      },
    );
  }
}
