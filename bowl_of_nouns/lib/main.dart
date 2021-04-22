import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:developer';

part 'teams.dart';
part 'game_creation.dart';
part 'auth.dart';
part 'registration.dart';

String _signedIn = "Sign In";
String _roomName = "";

final dbRef = FirebaseDatabase.instance.reference();

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
      '/TeamCreation': (context) => CreateTeamPage(),
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

  String _pleaseSignIn = "";
  final formKey = new GlobalKey<FormState>();
  String _roomNameForm = "Enter Room Name...";
  String validRoom = "";

  void updateSignedin() async {
    setState(() {
      _pleaseSignIn = "";
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
    updateSignedin();
  }

  void _joinGame() {
    validRoom = "";
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _roomName = _roomNameForm;
        String email = FirebaseAuth.instance.currentUser.email;
        int numPlayers = 0;
        dbRef.child(_roomName).once().then((DataSnapshot ss) {
          numPlayers = ss.value["numPlayers"];
          dbRef.child(_roomName).child("players").once().then((DataSnapshot snapshot) {
            if(snapshot.value != null){
              int count = 0;
              for(var data in snapshot.value.values) {
                count++;
              }
              bool full = false;
              dbRef.child(_roomName).child("players").orderByChild("email").equalTo(email).limitToFirst(1).once().then((DataSnapshot snap) {
                if(snap.value == null) {
                  if(count < numPlayers) {
                    dbRef.child(_roomName).child('players').push().set({
                      'email': email,
                      'team': 1,
                    });
                  } else {
                    full = true;
                    setState(() {
                      validRoom = "The room you are trying to join is full.";
                    });
                  }
                }
                if(full == false) {
                  Navigator.pushNamed(context, '/TeamCreation');
                }
              });
            }
            else{
              setState(() {
                validRoom = "Could not find room \'" + _roomName + "\'";
              });
            }
          });
        });
      });
    }
    else {

    }
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
                  final result = await Navigator.pushNamed(context, '/Authentication');
                  if(result == 'Success'){
                    updateSignedin();
                  }
                }
                else {
                  await FirebaseAuth.instance.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('You were successfully signed out.'),
                  ));
                  updateSignedin();
                }
              },
            );
          })
        ]
      ),
      body: Center(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                child: Text('Create New Game'),
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    setState(() {
                      _pleaseSignIn = "Please Sign In First!";
                    });
                  }
                  else {
                    Navigator.pushNamed(context, '/GameCreation');
                  }
                },
            ),
            Form(
              key: formKey,
              child: Container(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  onSaved: (value) {
                    setState((){
                      _roomNameForm = value;
                    });
                  },
                  /*validator: (value) {
                    return value;// ? '' : null;
                  },*/
                ),
              ),
            ),
            ElevatedButton(
                child: Text('Join Game'),
                onPressed: _joinGame,
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _pleaseSignIn,
                style: TextStyle(color: Colors.red),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                validRoom,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SomethingWentWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Something Went Wrong!!!",
          style: TextStyle(color: Colors.red),
        ),
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