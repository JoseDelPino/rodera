import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:rodera/signIn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySplashScreen extends StatefulWidget {
  MySplashScreen({Key key}) : super(key: key);

  @override
  MySplashScreenState createState() => new MySplashScreenState();
}

// Custom config
class MySplashScreenState extends State<MySplashScreen> {
  List<Slide> slides = new List();

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {

      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new SignIn()));

    } else {
      prefs.setBool('seen', true);
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirstSeen();

    slides.add(
      new Slide(
        title: "REPORT",
        description: "Report any incidence you encounter in your daily life from the palm of your hands",
        pathImage: "images/holding-phone-colour-1200px.png",
        backgroundColor: Colors.amber,
      ),
    );
    slides.add(
      new Slide(
        title: "CONNECT",
        description: "Connect with your neighbours and share your thoughts with them.",
        pathImage: "images/handshake-colour-1200px.png",
        backgroundColor: Colors.indigo,
      ),
    );
    slides.add(
      new Slide(
        title: "DISCOVER",
        description:
        "Discover new incidences in your area.",
        pathImage: "images/app-user-colour-1200px.png",
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void onDonePress() {
    // TODO: go to next screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));
  }

  void onSkipPress() {
    // TODO: go to next screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));

  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Color(0xffD02090),
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Color(0xffD02090),
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Color(0xffD02090),
    );
  }


  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onSkipPress,
    );
  }
}