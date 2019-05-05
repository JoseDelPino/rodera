import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rodera/addIncidence.dart';
import 'package:rodera/feed.dart';
import 'package:rodera/viewMyProfile.dart';
import 'package:rodera/search.dart';

import './map.dart';

class MyHome extends StatefulWidget {
  MyHome({Key key, this.title, this.myFirebaseUser}) : super(key: key);

  final String title;
  final FirebaseUser myFirebaseUser;

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    List<Widget> _widgetOptions = [Feed(user: widget.myFirebaseUser,),Search(myFirebaseUser: widget.myFirebaseUser),MapSample(),viewMyProfile(myFirebaseUser: widget.myFirebaseUser,)];

    return Scaffold(
      appBar: AppBar(
        title: new Image.asset("images/rodera_logo_bw_warm_simple.png"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_currentIndex),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add Incidence"),
        icon: Icon(Icons.add_location),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddIncidence(
                    user: widget.myFirebaseUser,
                    ),
            ),
          );
        },

      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Feed'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search,),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blueAccent,
        onTap: onTabTapped,
      ),
    );
  }
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}

