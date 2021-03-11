import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'teams.dart';
part 'game_creation.dart';
part 'auth.dart';
part 'registration.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

String _signedIn = "Sign In";

void main() {
  runApp(MaterialApp(
    title: 'Bowl of Nouns',
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(title: 'Bowl of Nouns'),
      '/Authentication': (context) => UserAuthentication(),
      '/Registration': (context) => UserRegistration(),
      '/GameCreation': (context) => CreateGamePage(),
      '/TeamCreation': (context) => TeamCreation(),
    },
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  ));
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _CreateHomePageState createState() => _CreateHomePageState();
}

class _CreateHomePageState extends State<HomePage> {
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try{
      await Firebase.initializeApp();
      setState((){
        _initialized = true;
      });
    } catch(e) {
      setState((){
        _error = true;
      });
    }
  }

  void initializeSignedin() async {
    setState(() {
      if (auth.currentUser == null) {
        _signedIn = "Sign In";
      }
      else {
        _signedIn = "Sign Out";
      }
    });
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
    initializeSignedin();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return SomethingWentWrong();
    }

    if (!_initialized) {
      return Loading();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return TextButton(
              child: Text(_signedIn),
              onPressed: () async {
                User user = auth.currentUser;
                if (user == null) {
                  Navigator.pushNamed(context, '/Authentication');
                }
                else {
                  await auth.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('You were successfully signed out.'),
                  ));
                }
              },
            );
          })
        ]
      )
    );
  }
}

class SomethingWentWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Something Went Wrong!!!"),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Loading..."),
      ),
    );
  }
}