import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeWidget());
  }
}

class AppState {
  bool loading;
  User? user;
  AppState(this.loading, this.user);
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final app = AppState(false, null);
  @override
  Widget build(BuildContext context) {
    if (app.loading) return _loading();
    if (app.user == null) return _loginPage();
    return _main();
  }

  Widget _loading() {
    return Scaffold(
        appBar: AppBar(title: Text('loading...')),
        body: Center(child: CircularProgressIndicator()));
  }

  Widget _loginPage() {
    return Scaffold(
        appBar: AppBar(title: Text('login page')),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('id'),
            Text('pass'),
            RaisedButton(
                child: Text('login'),
                onPressed: () {
                  _signIn();
                })
          ],
        )));
  }

  Widget _main() {
    return Scaffold(
        appBar: AppBar(
          title: Text('app.user'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WriteDoc()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () async {
                FirebaseAuth auth = FirebaseAuth.instance;
                GoogleSignIn googleSignIn = GoogleSignIn();
                GoogleSignInAccount? account = await googleSignIn.signIn();
                GoogleSignInAuthentication authentication =
                    await account!.authentication;

                print(account);
              },
            )
          ],
        ),
        body: _list());
  }

  Widget _list() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('test').snapshots(),
        builder: (context, snapshot) {
          final items = snapshot.data!.docs;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                  title: Text(item['title']), subtitle: Text(item['subtitle']));
            },
          );
        });
  }

  Future<String> _signIn() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    return 'success';
  }

  _signOut() async {
    await _googleSignIn.signOut();
  }
}

class WriteDoc extends StatelessWidget {
  var title, subtitle;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('test')
                  .add({'title': title, 'subtitle': subtitle});
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (text) => title = text,
              ),
              TextField(
                onChanged: (text) => subtitle = text,
              )
            ],
          )),
    );
  }
}
