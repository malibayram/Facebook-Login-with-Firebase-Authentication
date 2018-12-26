import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

void main() {
  runApp(MaterialApp(
    home: MyMainPage(),
  ));
}

class MyMainPage extends StatefulWidget {
  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLogged = false;

  FirebaseUser myUser;

  Future<FirebaseUser> _loginWithFacebook() async {
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin.logInWithReadPermissions(['email']);

    debugPrint(result.status.toString());

    if (result.status == FacebookLoginStatus.loggedIn) {
      FirebaseUser user =
          await _auth.signInWithFacebook(accessToken: result.accessToken.token);
      return user;
    }
    return null;
  }

  Future<FirebaseUser> _loginWithTwitter() async {
    var twitterLogin = new TwitterLogin(
      consumerKey: 'Y2My4EBwXnRLrlqATYeo9fYKX',
      consumerSecret: 'xYXUhQ1KoHEIUMI1ZjH5RnnvPjFAJZLmQc7ZXecPiXoFQDvS3i',
    );

    final TwitterLoginResult result = await twitterLogin.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        var session = result.session;
        FirebaseUser user = await _auth.signInWithTwitter(
            authToken: session.token, authTokenSecret: session.secret);
        return user;
        break;
      case TwitterLoginStatus.cancelledByUser:
        debugPrint(result.status.toString());
        return null;
        break;
      case TwitterLoginStatus.error:
        debugPrint(result.errorMessage.toString());
        return null;
        break;
    }
    return null;
  }

  void _logOut() async {
    await _auth.signOut().then((response) {
      isLogged = false;
      setState(() {});
    });
  }

  void _logIn() {
    _loginWithFacebook().then((response) {
      if (response != null) {
        myUser = response;
        isLogged = true;
        setState(() {});
      }
    });
  }

  void _logInTwitter() {
    _loginWithTwitter().then((response) {
      if (response != null) {
        myUser = response;
        isLogged = true;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogged ? "Profile Page" : "Facebook Loing Example"),
        actions: <Widget>[
          isLogged
              ? IconButton(
                  icon: Icon(Icons.power_settings_new),
                  onPressed: _logOut,
                )
              : IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: () {},
                ),
        ],
      ),
      body: Center(
        child: isLogged
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Name: ' + myUser.displayName),
                  Image.network(myUser.photoUrl),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FacebookSignInButton(
                    onPressed: _logIn,
                  ),
                  SizedBox(height: 30.0),
                  TwitterSignInButton(
                    onPressed: _logInTwitter,
                  ),
                ],
              ),
      ),
    );
  }
}
