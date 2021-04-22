part of 'main.dart';

class CreateGamePage extends StatefulWidget {
  @override
  _CreateGamePageState createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  int _numPlayers;
  int _numTeams;
  int _numWords;
  int _numPlayersForm;
  int _numTeamsForm;
  int _numWordsForm;
  String _roomNameForm;
  String _notEnoughPlayers;
  String _notEnoughWords;
  String _enterName = "";
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _numPlayersForm = 4;
    _numTeamsForm = 2;
    _numWordsForm = 4;
    _roomNameForm = "";
    _notEnoughPlayers = "";
    _notEnoughWords = "";
    updateSignedin();
  }

  void updateSignedin() async {
    setState(() {
      if (FirebaseAuth.instance.currentUser == null) {
        _signedIn = "Sign In";
      }
      else {
        _signedIn = "Sign Out";
      }
    });
  }


  void _createGame() {
    var form = formKey.currentState;
    if (form.validate()) {
      if(_numPlayersForm/_numTeamsForm >= 2 && _numPlayersForm * _numWordsForm >= 16) {
        form.save();
        setState(() {
          _enterName = "";
          _notEnoughPlayers = "";
          _notEnoughWords = "";
          _numPlayers = _numPlayersForm;
          _numTeams = _numTeamsForm;
          _numWords = _numWordsForm;
          _roomName = _roomNameForm;
          _numPlayersForm = 4;
          _numTeamsForm = 2;
          _numWordsForm = 4;
          _roomNameForm = "";

          var email = FirebaseAuth.instance.currentUser.email;      //change email to displayName once that's implemented
          if(_roomName != "") {
            dbRef.child(_roomName).set({
              'numTeams': _numTeams,
              'numPlayers': _numPlayers,
              'numWords': _numWords,
              'words': []
            });
            dbRef.child(_roomName).child('players').push().set({
              'email': email,
              'team': 1,
            });
            Navigator.pushNamed(context, '/TeamCreation');
          }
          else{
            _enterName = "Please Enter a Room Name!";
          }
        });
      }
      else {
        setState(() {
          if (_numPlayersForm / _numTeamsForm < 2) {
            _enterName = "";
            _notEnoughPlayers = "You must have at least 2 players per team!";
          }
          else{
            _notEnoughPlayers = "";
          }
          if (_numPlayersForm * _numWordsForm < 16) {
            _notEnoughWords = "You must have at least 16 total words!";
          }
          else{
            _notEnoughWords = "";
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text("Create a New Game"),
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
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text("Room Name:"),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    onSaved: (value) {
                      setState((){
                        _roomNameForm = value;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text("Number of Players:"),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: DropdownButtonFormField(
                    value: _numPlayersForm,
                    onSaved: (value) {
                      setState(() {
                        _numPlayersForm = value;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _numPlayersForm = value;
                      });
                    },
                    items: <int>[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text("Number of Teams:"),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: DropdownButtonFormField(
                    value: _numTeamsForm,
                    onSaved: (value) {
                      setState(() {
                        _numTeamsForm = value;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _numTeamsForm = value;
                      });
                    },
                    items: <int>[2, 3, 4]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text("Number of Words per Player:"),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: DropdownButtonFormField(
                    value: _numWordsForm,
                    onSaved: (value) {
                      setState(() {
                        _numWordsForm = value;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _numWordsForm = value;
                      });
                    },
                    items: <int>[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: Text('Create Game'),
                    onPressed: _createGame,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(_notEnoughPlayers + _enterName, style: TextStyle(color: Colors.red)),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(_notEnoughWords, style: TextStyle(color: Colors.red)),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(_enterName, style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}