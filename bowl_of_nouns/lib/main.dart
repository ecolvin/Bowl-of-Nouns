import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bowl of Nouns',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CreateGamePage(title: 'Create Game'),
    );
  }
}

class CreateGamePage extends StatefulWidget {
  CreateGamePage({Key key, this.title}) : super(key: key);

  final String title;

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
  String _notEnoughPlayers;
  String _notEnoughWords;
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _numPlayersForm = 4;
    _numTeamsForm = 2;
    _numWordsForm = 4;
    _notEnoughPlayers = "";
    _notEnoughWords = "";
  }

  _createGame() {
    var form = formKey.currentState;
    if (form.validate()) {
      if(_numPlayersForm/_numTeamsForm >= 2 && _numPlayersForm * _numWordsForm >= 16) {
        form.save();
        setState(() {
          _notEnoughPlayers = "";
          _notEnoughWords = "";
          _numPlayers = _numPlayersForm;
          _numTeams = _numTeamsForm;
          _numWords = _numWordsForm;
          //Go to the next page with _numPlayers, _numTeams, and _numWords
        });
      }
      else {
        setState(() {
          if (_numPlayersForm / _numTeamsForm < 2) {
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                child: RaisedButton(
                  child: Text('Create Game'),
                  onPressed: _createGame,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(_notEnoughPlayers, style: TextStyle(color: Colors.red)),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(_notEnoughWords, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
