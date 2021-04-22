part of 'main.dart';

class UserAuthentication extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserAuthenticationState();
}

class _UserAuthenticationState extends State<UserAuthentication> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success;
  String _userEmail;

  void _signInUser() async{
    UserCredential user;
    if (_formKey.currentState.validate()) {
      try {
        user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Incorrect Password');
        }
      }

      if(user != null) {
        Navigator.pop(context, 'Success');
      }
      else {
        setState(() {
          _success = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: const Text('Sign in with your email and password'),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Enter your email address...';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Enter your password...';
                  }
                  return null;
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    _signInUser();
                  },
                  child: const Text('Submit'),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _success == null
                      ? ''
                      : (_success
                      ? 'Successfully signed in ' + _userEmail
                      : 'Sign in failed'),
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  child: Text("Create an Account"),
                  onTap: () {
                    Navigator.pushNamed(context, "/Registration");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}