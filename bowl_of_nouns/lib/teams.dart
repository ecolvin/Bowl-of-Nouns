part of 'main.dart';

class CreateTeamPage extends StatefulWidget {
  @override
  _CreateTeamPageState createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  var _numPlayers = -1;
  var _numTeams = -1;
  List _players = [];
  List _teams = [];
  String error = "";

  @override
  void initState() {
    super.initState();
    initVars();
  }

  void initVars() {
    dbRef.child(_roomName).once().then((DataSnapshot snapshot){
      setState(() {
        _numPlayers = snapshot.value["numPlayers"];
        _numTeams = snapshot.value["numTeams"];
        for(int i = 0; i < _numPlayers; i++) {
          _teams.add(1);
        }
      });
    });
  }

  void increment(var player) {
    String email = player['email'];
    dbRef.child(_roomName).child('players').orderByChild('email').equalTo(email).limitToFirst(1).once().then((DataSnapshot snapshot) {
      var key = snapshot.value.keys.first;
      var t = snapshot.value.values.first["team"];
      if (t >= _numTeams - 1){
        t = _numTeams;
      }
      else {
        t++;
      }
      dbRef.child(_roomName).child('players').child(key).update({"team": t});
    });
  }

  void decrement(var player) {
    String email = player['email'];
    dbRef.child(_roomName).child('players').orderByChild('email').equalTo(email).limitToFirst(1).once().then((DataSnapshot snapshot) {
      var key = snapshot.value.keys.first;
      var t = snapshot.value.values.first["team"];
      if (t <= 2){
        t = 1;
      }
      else {
        t--;
      }
      dbRef.child(_roomName).child('players').child(key).update({"team": t});
    });
  }

  void printPlayers ()
  {
    setState(() {
      for(int i = 0; i < _players.length; i++) {
        log(_players[i]);
      }
    });
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

  void startGame() {
    int count = 0;
    var team_counts = [];
    for(int i = 0; i < _numTeams; i++) {
      team_counts.add(0);
    }
    dbRef.child(_roomName).child('players').orderByChild("team").once().then((DataSnapshot snapshot){
      for(var data in snapshot.value.values) {
        count++;
        team_counts[data.values.first - 1]++;
      }
      setState(() {
        bool ready = true;
        for(int i = 0; i < team_counts.length; i++) {
          if(team_counts[i] < 2) {
            ready = false;
          }
        }
        if(count - _numPlayers == 0) {
          if(ready) {
            error = "Game Starting!!!!";
          }
          else {
            error = "All teams must have at least 2 people!";
          }
        } else {
          error = "Not enough players: ${count}/${_numPlayers}";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context){
    if (_numTeams == -1 || _numPlayers == -1) {
      return Center(child: CircularProgressIndicator());
    }
    else {
      return Scaffold(
        appBar: AppBar(
            title: Text(_roomName),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Room Name:",
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _roomName,
                ),
              ),
              StreamBuilder (
                stream: dbRef.child(_roomName).child("players").onValue,
                builder: (BuildContext context, snap) {
                  if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {
                    DataSnapshot snapshot = snap.data.snapshot;
                    _players = [];
                    var data = snapshot.value;
                    data.forEach((k,v) => _players.add(v));
                    return Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _players.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text(_players[index]['email']),
                                ),
                              ),
                              Text("Team:"),
                              IconButton(
                                onPressed: (){
                                  increment(_players[index]);
                                },
                                icon: Icon(Icons.add),
                              ),
                              Text(_players[index]['team'].toString()),
                              IconButton(
                                  onPressed: (){
                                    decrement(_players[index]);
                                  },
                                  icon: Icon(Icons.remove),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }
                  else {
                    return Center(child: CircularProgressIndicator());
                  }
                }
              ),
              ElevatedButton(
                  onPressed: startGame,
                  child: Text("Start Game")
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(error, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      );
    }
  }
}