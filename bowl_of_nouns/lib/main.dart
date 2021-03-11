import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'teams.dart';
part 'game_creation.dart';
part 'auth.dart';
part 'registration.dart';

String _signedIn = "Sign In";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

  void initializeSignedin() async {
    setState(() {
      if (FirebaseAuth.instance.currentUser == null) {
        _signedIn = "Sign In";
      }
      else {
        _signedIn = "Sign Out";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeSignedin();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return TextButton(
              child: Text(_signedIn, style: TextStyle(color: Colors.black)),
              onPressed: () async {
                User user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  Navigator.pushNamed(context, '/Authentication');
                }
                else {
                  await FirebaseAuth.instance.signOut();
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