import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'tower_hanoi.dart';
import 'loading_page.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;

/*
Main, TUTORIAL REAL GAME(50%)
PROFILE, SHOP, SERVER CONNECT
 */

int _index = 1;

bool change3 = true;
bool change2 = true;
bool change1 = true;
bool change = true;
bool once = true;
bool once2 = true;

bool prac = true, tuto = true, real = true, rank = false, login = false;
List<bool> prac_check = [
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
  true,
];
int currentindex = 0;
int grossscore = 0;
int score = 0;
int time = 0;
int grosstime = 0;
int playcount = 0;

//bool musicflag = true;

bool movecheck = true;
int _widgetindex = 2;

String id = "TEST";
String display = "";
String photourl = "";
FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<String> _signIn(BuildContext context) async {
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

  id = await googleUser.id;
  print("id : $id");

  firebaseFirestore.collection("User").doc("${id}").get().then((ds) {
    print("GOOD");
    if (!ds.exists) {
      firebaseFirestore.collection("User").doc("$id").set({
        "id": id,
        "display": googleUser.displayName,
        "photo": googleUser.photoUrl,
        "prac": false,
        "tuto": true,
        "real": false,
        "rank": false,
        "practice": [
          true,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false
        ],
        "currentindex": 0,
        "grossscore": 0,
        "grosstime": 0,
        "playcount": 0,
        "score": 0,
        "time": 0,
        "index1": "",
        "index2": "",
        "index3": "",
        "index4": "",
        "index5": "",
        "index6": "",
        "index7": "",
        "index8": "",
        "index9": "",
        "index10": "",
        "index11": "",
        "index12": "",
        "index13": "",
        "index14": "",
        "index15": "",
        "index16": "",
        "realgame": "",
      });
    }
    print("WHYYYY!");
    display = ds.get("display");
    photourl = ds.get("photo");
    print("WHAT HAPPENING!!!");
    print(display);
    print(photourl);
    prac = ds.get("prac");
    tuto = ds.get("tuto");
    real = ds.get("real");
    rank = ds.get("rank");
    currentindex = ds.get("currentindex");
    time = ds.get("time");
    grosstime = ds.get("grosstime");
    score = ds.get("score");
    grossscore = ds.get("grossscore");
    playcount = ds.get("playcount");
    print(ds.get("practice"));
    prac_check = List.from(ds.get("practice"));

    Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => Scaffold(
            body: Container(
                color: Colors.amber,
                child: Center(
                  child: FlatButton(
                    child: Container(
                        color: Colors.orangeAccent,
                        child: Text(
                          "로그인 완료하셨습니다!",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        )),
                    onPressed: () {
                      _index = (_index == 1) ? 2 : 1;
                      Navigator.of(context).pop();
                    },
                  ),
                )))));
  });

  return 'success';
}

_signOut() async {
  await _googleSignIn.signOut();
}

class DecoratedTabBar extends StatelessWidget implements PreferredSizeWidget {
  DecoratedTabBar({required this.tabBar, required this.decoration});

  final TabBar tabBar;
  final BoxDecoration decoration;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: decoration)),
        tabBar,
      ],
    );
  }
}

final dummyItems = ["Tutorial", "Practice", "Real Game", "Rank"];
final RankItems = ["count", "fade", "random", "timeattack"];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Flutter Demo",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var _pages = [Page1(), Page2(), Page3()];

  AudioCache player = AudioCache(prefix: "audio/");

  @override
  void initState() {
    _signIn(context);

    super.initState();
    player.loop("hanoi_bgm.wav");
  }

  @override
  void dispose() {
    super.dispose();

    //player.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _index = index;
            });
          },
          currentIndex: _index,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                title: Text(
                  "상점",
                  style: TextStyle(color: _index == 0 ? Colors.amber : null),
                ),
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.amber,
                )),
            BottomNavigationBarItem(
                title: Text("홈",
                    style: TextStyle(color: _index == 1 ? Colors.amber : null)),
                icon: Icon(Icons.home, color: Colors.amber)),
            BottomNavigationBarItem(
                title: Text("내 정보",
                    style: TextStyle(color: _index == 2 ? Colors.amber : null)),
                icon: Icon(Icons.account_circle, color: Colors.amber))
          ]),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildTop(),
        //_buildMiddle(),
        //SizedBox(height : 50),
        _buildBottom(),
      ],
    );
  }

  Widget _buildTop() {
    return Builder(builder: (BuildContext context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 275,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.amber, Colors.orangeAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 50.0,
                        color: Colors.yellow,
                      ),
                      child: Center(
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('Hanoi of Tower'),
                            WavyAnimatedText('Welcome'),
                          ],
                          isRepeatingAnimation: true,
                          repeatForever: true,
                        ),
                      ),
                    )),
                Container(
                  //#FIX
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  height: 50.0,
                  margin: EdgeInsets.all(10),
                  child: RaisedButton(
                    onPressed: () {
                      if (currentindex == 0) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (builder) => G()));
                      } else if (currentindex < 6) {
                        firebaseFirestore
                            .collection("User")
                            .doc(id)
                            .get()
                            .then((DocumentSnapshot ds) {
                          if (ds.get("index${currentindex + 1}") != "") {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ForthRoute(currentindex + 1, 0, 0, 'd')));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (builder) => MyA(
                                    n: currentindex + 1,
                                    faden: 0,
                                    randomn: 0,
                                    type: 'd')));
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => My()));
                          }
                        });
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) =>
                                ThirdRoute(currentindex + 1)));
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(
                          "빠른 시작",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(photourl),
                    radius: 25,
                  ),
                  Text("$display님"),
                ],
              ),
            ]),
          ],
        ),
      );
    });
  }

  Widget _buildBottom() {
    return CarouselSlider(
      options: CarouselOptions(height: 155, autoPlay: true),
      items: dummyItems.map((text) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orangeAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                ),
                child: ClipRRect(
                  //borderRadius: BorderRadius.circular(8.0),
                  child: InkWell(
                    onTap: () {
                      firebaseFirestore
                          .collection("User")
                          .doc(id)
                          .get()
                          .then((DocumentSnapshot ds) {
                        prac = ds.get("prac");
                        tuto = ds.get("tuto");
                        real = ds.get("real");
                        rank = ds.get("rank");
                      });

                      if (text == "Practice" && prac) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SecondRoute()));
                      } else if (text == "Tutorial") {
                        if (!tuto) {
                        } else {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => (G())))
                              .then((_) => {
                                    firebaseFirestore
                                        .collection("User")
                                        .doc(id)
                                        .get()
                                        .then((DocumentSnapshot ds) {
                                      prac = ds.get("prac");
                                      tuto = ds.get("tuto");
                                      real = ds.get("real");
                                      rank = ds.get("rank");
                                    })
                                  });
                        }
                      } else if (text == "Real Game") {
                        print("WHY SO SERIOUS?");
                        if (!real) {
                        } else {
                          //#FIX2
                          firebaseFirestore
                              .collection("User")
                              .doc(id)
                              .get()
                              .then((DocumentSnapshot ds) {
                            if (ds.get("realgame") != "") {
                              List<List<int>> temp =
                                  saveList(ds.get("realgame"));
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ForthRoute(
                                      temp[0].length +
                                          temp[1].length +
                                          temp[2].length,
                                      Random().nextInt(5) + 15,
                                      0,
                                      'r')));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MyA(
                                      n: Random().nextInt(5) + 6,
                                      randomn: Random().nextInt(500) + 500,
                                      faden: Random().nextInt(5) + 15,
                                      type: 'r')));
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => My()));
                            }
                          });
                        }
                      } else if (rank) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RankRoute()));
                      }
                    },
                    child: Stack(children: [
                      Center(
                        child: AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(seconds: 1),
                          child: Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    (text == "Real Game"
                                        ? "하노이 탑의 신이 되어보세요!"
                                        : text == "Tutorial"
                                            ? "하노이 탑에 대해서 배웁니다"
                                            : text == "Practice"
                                                ? "연습할 수 있습니다"
                                                : "당신의 실력을 증명해보세요!"),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w100))
                              ])),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black
                              .withOpacity((text == "Tutorial" && tuto)
                                  ? 0.0
                                  : (text == "Practice" && prac)
                                      ? 0.0
                                      : (text == "Real Game" && real)
                                          ? 0.0
                                          : (text == "Rank" && rank)
                                              ? 0.0
                                              : (text == "Rank" && rank)
                                                  ? 0.0
                                                  : 0.8),
                          child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: (text == "Tutorial" && tuto)
                                        ? 0.0
                                        : (text == "Practice" && prac)
                                            ? 0.0
                                            : (text == "Real Game" && real)
                                                ? 0.0
                                                : (text == "Rank" && rank)
                                                    ? 0.0
                                                    : 50,
                                    color: Colors.amber,
                                  ),
                                  Text(
                                    text == "Practice"
                                        ? "Tutorial을 먼저 해주세요"
                                        : text == "Real Game"
                                            ? "6단계부터 깨주세요"
                                            : text == "Rank"
                                                ? "기대해주세요!"
                                                : " ",
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: (text == "Tutorial" && tuto)
                                            ? 0.0
                                            : (text == "Practice" && prac)
                                                ? 0.0
                                                : (text == "Real Game" && real)
                                                    ? 0.0
                                                    : (text == "Rank" && rank)
                                                        ? 0.0
                                                        : 20),
                                  )
                                ]),
                          )),
                    ]),
                  ),
                ));
          },
        );
      }).toList(),
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Text("추후에 오픈 예정입니다",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.amber,
                  decoration: TextDecoration.none)),
        ));
    /*
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: AppBar(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.amber,
              bottom: DecoratedTabBar(
                tabBar: TabBar(indicatorColor: Colors.pink, tabs: <Widget>[
                  Tab(text: '번들'),
                  Tab(text: '티켓'),
                  Tab(text: '시즌'),
                ]),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white, width: 2.0))),
              ),
            ),
          ),
          body:
            TabBarView(children: <Widget>[
              Container(color: Colors.amber),
              Container(color: Colors.amber),
              Container(color: Colors.amber),
            ]),

          bottomNavigationBar: build_top(),
        ));
  }

  Widget build_top() {
    return Row(
      children: [
        Container(
            child: Row(
          children: [
            Icon(
              Icons.brightness_1,
              color: Colors.yellow[500]!,
              size: 20,
            ),
            Text(
              "150",
              style: TextStyle(fontSize: 20),
            )
          ],
        )),
        SizedBox(width: 20),

        Container(
            child: Row(
          children: [
            Icon(
              Icons.airplane_ticket,
              color: Colors.yellow[500]!,
              size: 20,
            ),
            Text(
              "4/10",
              style: TextStyle(fontSize: 20),
            )
          ],
        ))
      ],
    );

     */
  }

  Widget build_middle() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: AppBar(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.amber,
              bottom: DecoratedTabBar(
                tabBar: TabBar(indicatorColor: Colors.pink, tabs: <Widget>[
                  Tab(text: '번들'),
                  Tab(text: '티켓'),
                  Tab(text: '시즌'),
                ]),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white, width: 2.0))),
              ),
            ),
          ),
          body: Stack(
            children: [
              TabBarView(children: <Widget>[
                Container(color: Colors.amber),
                Container(color: Colors.amber),
                Container(color: Colors.amber),
              ]),
            ],
          )),
    );
  }
}

class Page3 extends StatefulWidget {
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: AppBar(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.amber,
              title: Center(
                child: Text("플레이어 정보"),
              )
              /*
              DecoratedTabBar(
                tabBar: TabBar(indicatorColor: Colors.pink, tabs: <Widget>[
                  Tab(text: '플레이어 정보'),
                  Tab(text: '테마'),
                ]),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white, width: 2.0))),
              ),
              */
              ),
        ),
        body: SingleChildScrollView(
          child: DefaultTabController(
            length: 1,
            initialIndex: 0,
            child: Container(
              color: Colors.amber,
              child: Container(
                color: Colors.amberAccent,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              _signOut();
                              setState(() {
                                _signIn(context);
                              });
                            },
                            icon: Icon(Icons.account_circle)),
                        Text("계정 교체"),
                      ],
                    ),
                    Center(
                        child: Text("Practice 진행률",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold))),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      width: MediaQuery.of(context).size.width - 50,
                      height: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          value: (currentindex * 0.066),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.amber),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    Row(children: [
                      Expanded(
                          child: Container(
                        child: Center(child: Text("플레이 한 횟수\n$playcount")),
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12)),
                      )),
                      SizedBox(width: 5),
                      Expanded(
                          child: Container(
                        child: Center(child: Text("최고 점수\n$score")),
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12)),
                      )),
                      SizedBox(width: 5),
                      Expanded(
                          child: Container(
                        child: Center(
                          child: Text(
                              "최고 시간\n${(time ~/ (100 * 60 * 60) == 0) ? ("${((time / (100 * 60)) % 60).toInt()}분 : ${((time / (100)) % 60).toInt()}초") : ("${time ~/ (100 * 60 * 60)}시 : ${((time / (100 * 60)) % 60).toInt()}분")}"),
                        ),
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12)),
                      )),
                    ]),
                    SizedBox(height: 5),
                    Row(children: [
                      Expanded(
                          child: Container(
                        child: Center(
                          child: Text(
                              "총 시간\n${(grosstime ~/ (100 * 60 * 60) == 0) ? ("${((grosstime / (100 * 60)) % 60).toInt()}분 : ${((grosstime / (100)) % 60).toInt()}초") : ("${grosstime ~/ (100 * 60 * 60)}시 : ${((grosstime / (100 * 60)) % 60).toInt()}분")}"),
                        ),
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12)),
                      )),
                      SizedBox(width: 5),
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(child: Text("총 점수\n$grossscore")),
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12)),
                      )),
                    ]),
                    SizedBox(height: 5),
                    Container(
                      child: TabBar(
                        indicatorColor: Colors.pink,
                        isScrollable: true,
                        labelColor: Colors.orange,
                        unselectedLabelColor: Colors.black,
                        tabs: [
                          Tab(text: "Play")
                          // Tab(text: 'Count'),
                          // Tab(text: 'Fade'),
                          // Tab(text: 'Random'),
                          // Tab(text: 'TimeAttack'),
                        ],
                      ),
                    ),
                    Container(
                        width: 240,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1.0, color: Colors.pink))),
                        child: Center(
                          child: Text("내 랭킹",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("아직 정보가 없습니다"),
                    ),
                    Container(
                        width: 300,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1.0, color: Colors.pink))),
                        child: Center(
                          child: Text("TOP 10",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        )),
                    Container(
                        height: 250,
                        //height of TabBarView
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey, width: 0.5))),
                        child: TabBarView(children: <Widget>[
                          ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: 11,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    height: 50,
                                    child: Text((index == 10)
                                        ? "더보기"
                                        : "${1 + index}"));
                              }),
                          // Container(
                          //   child: Center(
                          //     child: Text('Display Tab 2',
                          //         style: TextStyle(
                          //             fontSize: 22,
                          //             fontWeight: FontWeight.bold)),
                          //   ),
                          // ),
                          // Container(
                          //   child: Center(
                          //     child: Text('Display Tab 3',
                          //         style: TextStyle(
                          //             fontSize: 22,
                          //             fontWeight: FontWeight.bold)),
                          //   ),
                          // ),
                          // Container(
                          //   child: Center(
                          //     child: Text('Display Tab 4',
                          //         style: TextStyle(
                          //             fontSize: 22,
                          //             fontWeight: FontWeight.bold)),
                          //   ),
                          // ),
                        ]))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent.withOpacity(0.5),
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Center(child: Text("Menu")),
          backgroundColor: Colors.amber),
      body: GridView.extent(
        padding: EdgeInsets.all(10),
        maxCrossAxisExtent: 300.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: List.generate(15, (index) {
          return Center(
            child: InkWell(
              onTap: () {
                firebaseFirestore
                    .collection("User")
                    .doc(id)
                    .get()
                    .then((DocumentSnapshot ds) {
                  if (ds.get("index${index + 1}") != "" && prac_check[index]) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) =>
                            ForthRoute(index + 1, 0, 0, 'd')));
                  } else if (prac_check[index]) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext build) => MyA(
                              n: index + 1,
                              randomn: 0,
                              faden: 0,
                              type: "d",
                            )));

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext build) => My()));
                  }
                });
              },
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3.0, color: Colors.amberAccent),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      color: Colors.amber),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                    ),
                  ),
                  //color: Colors.amber,
                ),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      color: Colors.black
                          .withOpacity(prac_check[index] ? 0.0 : 0.8),
                    ),
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: prac_check[index] ? 0.0 : 50,
                              color: Colors.amber,
                            ),
                            Text("$index 부터 깨주세요",
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: prac_check[index] ? 0.0 : 20))
                          ]),
                    )),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

class G extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      home: Tuto(),
    );
  }
}

class Tuto extends StatefulWidget {
  @override
  _TutoState createState() => _TutoState();
}

class _TutoState extends State<Tuto> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  void initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    animation = new CurvedAnimation(parent: _controller, curve: Curves.ease);
    animation.addListener(() {
      this.setState(() {});
    });
    animation.addStatusListener((status) {});
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
    change = true;
    change1 = true;
    change2 = true;
    change3 = true;
    once = true;
    once2 = true;
    movecheck = true;
    _widgetindex = 2;
  }

  @override
  Widget build(BuildContext context) {
    const double smallLogo = 100;
    const double bigLogo = 200;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size biggest = constraints.biggest;
        return IndexedStack(
          index: _widgetindex,
          children: <Widget>[
            MyA(
              n: 3,
              randomn: 0,
              faden: 0,
              type: 't',
            ),
            AnimatedOpacity(
              opacity: change ? 1 : 0,
              duration: Duration(milliseconds: 2000),
              child: GestureDetector(
                onTap: () {
                  change = !change;
                  _widgetindex--;
                },
                child: Stack(
                  children: <Widget>[
                    MyA(n: 3, randomn: 0, faden: 0, type: "d"),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Text(
                              "디스크를 잡고 옮기거나 칸을 선택해서 옮길 수 있습니다\n한번은 디스크, 한번은 칸으로 움직여 보세요\n세번째 칸으로 다 옮기면 됩니다",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.amber,
                                  decoration: TextDecoration.none)),
                        )),
                    PositionedTransition(
                      rect: RelativeRectTween(
                        begin: RelativeRect.fromSize(
                            Rect.fromLTWH(
                                MediaQuery.of(context).size.width / 4,
                                MediaQuery.of(context).size.height / 2,
                                smallLogo,
                                smallLogo),
                            biggest),
                        end: RelativeRect.fromSize(
                            Rect.fromLTWH(biggest.width - bigLogo,
                                biggest.height - bigLogo, bigLogo, bigLogo),
                            biggest),
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Curves.ease,
                      )),
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Image.asset("imgs/hand.png")),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: change1 ? 1 : 0,
              duration: Duration(milliseconds: 2000),
              child: GestureDetector(
                onTap: () {
                  change1 = !change1;
                  _widgetindex--;
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("게임 규칙",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.amber,
                                    decoration: TextDecoration.none)),
                            Text(
                                "1. 한번에 하나만 이동 가능합니다\n2. 작은 원반 위로 큰 원반을 이동할 수 없습니다\n3. 가장위의 원판만 이동 가능합니다",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.amber,
                                    decoration: TextDecoration.none)),
                          ]),
                    )),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ThirdRoute extends StatelessWidget {
  int n = 0;
  ThirdRoute(int n) {
    this.n = n;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amberAccent.withOpacity(0.5),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
          backgroundColor: Colors.amber,
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
        body: Row(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    //Navigator.of(context).pop();

                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .get()
                        .then((DocumentSnapshot ds) {
                      if (ds.get("realgame") != "") {
                        List<List<int>> temp = saveList(ds.get("realgame"));

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => ForthRoute(
                                temp[0].length +
                                    temp[1].length +
                                    temp[2].length,
                                Random().nextInt(5) + 15,
                                0,
                                'r')));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyA(
                                n: Random().nextInt(5) + 6,
                                randomn: Random().nextInt(500) + 500,
                                faden: Random().nextInt(5) + 15,
                                type: 'r')));
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => My()));
                      }
                    });
                  },
                  child: Text(
                    "Real Game",
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
            SizedBox(width: 10),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .get()
                        .then((DocumentSnapshot ds) {
                      Navigator.of(context).pop();
                      if (ds.get("index$n") != "") {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => ForthRoute(n, 0, 0, 'd')));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                MyA(n: n, randomn: 0, faden: 0, type: 'd')));
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => My()));
                      }
                    });
                  },
                  child: Text(
                    "Practice",
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
          ],
        ));
  }
}

class ForthRoute extends StatelessWidget {
  int n = 0, faden = 0, randomn = 0;
  String type = "";

  ForthRoute(int n, int faden, int randomn, String type) {
    this.n = n;
    this.faden = faden;
    this.randomn = randomn;
    this.type = type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amberAccent.withOpacity(0.5),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
          backgroundColor: Colors.amber,
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
        body: Row(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    if (type == 'r') {
                      firebaseFirestore
                          .collection("User")
                          .doc(id)
                          .update({"realgame": ""});

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) => MyA(
                              n: Random().nextInt(5) + 6,
                              randomn: Random().nextInt(500) + 500,
                              faden: Random().nextInt(5) + 15,
                              type: 'r')));
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => My()));
                    } else {
                      print("GJOSDIAS135456");

                      firebaseFirestore
                          .collection("User")
                          .doc(id)
                          .update({"index${n}": ""});

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) =>
                              MyA(n: n, faden: 0, randomn: 0, type: type)));
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => My()));
                    }
                  },
                  child: Text(
                    "새로하기",
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
            SizedBox(width: 10),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => MyA(
                            n: n, faden: faden, randomn: randomn, type: type)));
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => My()));
                  },
                  child: Text(
                    "이어하기",
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
          ],
        ));
  }
}

class RankRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent.withOpacity(0.5),
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Center(child: Text("Rank")),
          backgroundColor: Colors.amber),
      body: GridView.extent(
        padding: EdgeInsets.all(10),
        maxCrossAxisExtent: 900,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: List.generate(4, (index) {
          return Center(
            child: InkWell(
              onTap: () {},
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3.0, color: Colors.amberAccent),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      color: Colors.amber),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          '${RankItems[index]}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 40),
                        ),
                      ),
                      Center(
                        child: Text(
                          RankItems[index] == "count"
                              ? "제일 적은 횟수로 움직이세요!"
                              : RankItems[index] == "fade"
                                  ? "디스크 판이 사라집니다! 빠르게 해보세요!"
                                  : RankItems[index] == "random"
                                      ? "디스크가 랜덤으로 섞입니다!"
                                      : "제한 시간안에 최대한으로 정렬을 해보세요!",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Image.asset("imgs/season.png"),
                    ],
                  ),
                  //color: Colors.amber,
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }
}
