import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tower_of_hanoi/main.dart';

bool _finished = false;

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

String saveString(List<List<int>> save, int time, int move, int error) {
  String result = "";

  for (int i = 0; i < save.length; i++) {
    if (i == 0)
      result = result + "${save[i][0]},${save[i][1]},${save[i][2]}";
    else if (i == save.length - 1)
      result = "${save[i][0]},${save[i][1]},${save[i][2]}," + result;
    else
      result = "${save[i][0]},${save[i][1]},${save[i][2]}," + result;
  }

  result = result + ",,${time},${move},${error}";

  return result;
}

List<List<int>> saveList(String save) {
  List<String> save2 = save.split(',');
  List<int> temp = [];
  List<List<int>> result = [[], [], []];
  for (int i = 0; i < save2.length; i += 3) {
    if (save2[i] == "") {
      result.add([
        int.parse(save2[i + 1]),
        int.parse(save2[i + 2]),
        int.parse(save2[i + 3])
      ]);
      break;
    }
    result[int.parse(save2[i + 1]) - 1].insert(0, int.parse(save2[i]));
  }
  return result;
}

void hanoi_tower(int n) {
  runApp(MyA(n: n, randomn: n, faden: n, type: "d"));
}

bool _visible1 = true;
bool _visible2 = true;
bool _visible3 = true;
bool change3 = true;

class MyA extends StatelessWidget {
  // This widget is the root of your application.
  int n, randomn, faden;
  String type; // "r" : Real Game / "t" : Tutorial / "d" : default

  MyA(
      {required this.n,
      required this.randomn,
      required this.faden,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Disk(n: n, randomn: randomn, faden: faden, type: type));
  }
}

class Disk extends StatefulWidget {
  int n, randomn, faden;
  String type;

  Disk(
      {Key? key,
      required this.n,
      required this.randomn,
      required this.faden,
      required this.type})
      : super(key: key);

  @override
  DiskState createState() => DiskState();

  static DiskState? of(BuildContext context) =>
      context.findAncestorStateOfType<DiskState>();
}

class DiskState extends State<Disk> with TickerProviderStateMixin {
  final List<List<Color>> colorList = [
    [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green,
      Colors.lightBlue,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.deepPurple
    ],
    [
      Colors.pink,
      Colors.red,
      Colors.deepOrange,
      Colors.orange,
      Colors.amber,
      Colors.yellow,
      Colors.lime,
      Colors.lightGreen,
      Colors.green,
      Colors.teal,
      Colors.cyan,
      Colors.lightBlue,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.deepPurple,
      Colors.grey,
      Colors.blueGrey,
      Colors.brown
    ],
    [
      Colors.amber[50]!,
      Colors.amber[100]!,
      Colors.amber[200]!,
      Colors.amber[300]!,
      Colors.amber[400]!,
      Colors.amber,
      Colors.amber[600]!,
      Colors.amber[700]!,
      Colors.amber[800]!,
      Colors.amber[900]!,
      Colors.amber
    ],
    [Colors.deepOrange]
  ];

  final List<List<Image>> imgList = [
    [
      Image.asset('imgs/tower1.png'),
      Image.asset('imgs/tower2.png'),
      Image.asset('imgs/tower3.png'),
      Image.asset('imgs/tower4.png'),
      Image.asset('imgs/tower5.png')
    ],
    [
      Image.asset('imgs/tower1_1.png'),
      Image.asset('imgs/tower2_1.png'),
      Image.asset('imgs/tower3_1.png'),
      Image.asset('imgs/tower4_1.png'),
      Image.asset('imgs/tower5_1.png')
    ]
  ];

  final List<Image> backgroundList = [Image.asset('imgs/background.png')];

  final List<List<Widget>> diskCurrent = [
    [SizedBox(height: 20)],
    [SizedBox(height: 20)],
    [SizedBox(height: 20)]
  ];
  final List<List<int>> diskState = []; //num,pos,index
  int move = 0;
  int error = 0;
  late Timer _timer;
  double _time = 0;

  Widget buildDisk(int num, {int pos: 1}) {
    return Container(
        width: 25 + (num - 1) * 10,
        height: 15,
        color: colorList[1][num.toInt() - 1],
        child: Center(child: Text("$num")));

    /* Draggable(
        data: [num, pos],

        //image
/*
        child: imgList[1][num - 1],
        feedback: imgList[1][num - 1],

 */

        //Color

        child: Container(
            width: 50 + (num - 1) * 20,
            height: 30,
            color: colorList[2][num.toInt() - 1],
            child: Center(child: Text("$num"))),
        feedback: Container(
            width: 50 + (num - 1) * 20,
            height: 30,
            color: colorList[2][num.toInt() - 1],
            child: Center(
              child: Text("$num",
                  style: TextStyle(fontSize: 10, color: Colors.black)),
            )),
        childWhenDragging: Container(child: Text("")),
        onDragEnd: (dragdetail) {
          setState(() {
            pos = diskState[num - 1][1];

            double posCom = MediaQuery.of(context).size.width / 3;

            double x = dragdetail.offset.dx;
            int startPos = 0;
            List<Widget> currentList = [];
            List<int> currentState = [];

            if (pos == 1) {
              currentList = diskCurrent[0];
              startPos = 1;
            } else if (pos == 2) {
              currentList = diskCurrent[1];
              startPos = 2;
            } else if (pos == 3) {
              currentList = diskCurrent[2];
              startPos = 3;
            }

            currentState = diskState[num - 1];
            Widget current = currentList[0];

            if (currentState[2] != 0) {
              error++;
            } else if (x <= posCom) {
              pos = 1;
              currentState[1] = 1;

              if (diskCurrent[0].length == 1) {
                currentState[2] = 0;
                diskCurrent[0].insert(0, current);
                currentList.remove(current);
                move++;
              } else if (startPos != currentState[1]) {
                print(
                    "1 : ${currentState[0]},${currentState[1]},${currentState[2]},");
                int compare = 0;

                for (var i = 0; i < diskState.length; i++) {
                  print(
                      "$i : ${diskState[i][0]},${diskState[i][1]},${diskState[i][2]}");
                  if (diskState[i][1] == currentState[1] &&
                      diskState[i][2] == 0 &&
                      diskState[i][0] != currentState[0]) compare = i + 1;
                }

                if (currentState[0] > compare) {
                  currentState[1] = startPos;
                  pos = startPos;
                  error++;
                } else {
                  diskCurrent[0].insert(0, current);
                  currentList.remove(current);
                  move++;
                  for (var i = 0; i < diskState.length; i++) {
                    if (diskState[i][1] == 1) diskState[i][2]++;
                  }
                  currentState[2] = 0;
                }
              }
            } else if (x <= posCom * 2) {
              pos = 2;
              currentState[1] = 2;

              if (diskCurrent[1].length == 1) {
                currentState[2] = 0;
                diskCurrent[1].insert(0, current);
                currentList.remove(current);
                move++;
              } else if (startPos != currentState[1]) {
                print(
                    "2 : ${currentState[0]}, ${diskState[currentState[1] - 1][0]}");

                int compare = 0;

                for (var i = 0; i < diskState.length; i++) {
                  if (diskState[i][1] == currentState[1] &&
                      diskState[i][2] == 0 &&
                      diskState[i][0] != currentState[0]) compare = i + 1;
                }

                if (currentState[0] > compare) {
                  currentState[1] = startPos;
                  pos = startPos;
                  error++;
                } else {
                  diskCurrent[1].insert(0, current);
                  currentList.remove(current);
                  move++;
                  for (var i = 0; i < diskState.length; i++) {
                    if (diskState[i][1] == 2) diskState[i][2]++;
                  }
                  currentState[2] = 0;
                }
              }
            } else if (x <= posCom * 3) {
              pos = 3;
              currentState[1] = 3;

              if (diskCurrent[2].length == 1) {
                currentState[2] = 0;
                diskCurrent[2].insert(0, current);
                currentList.remove(current);
                move++;
              } else if (startPos != currentState[1]) {
                print(
                    "3 : ${currentState[0]}, ${diskState[currentState[1] - 1][0]}");

                int compare = 0;

                for (var i = 0; i < diskState.length; i++) {
                  if (diskState[i][1] == currentState[1] &&
                      diskState[i][2] == 0 &&
                      diskState[i][0] != currentState[0]) compare = i + 1;
                }

                if (currentState[0] > compare) {
                  currentState[1] = startPos;
                  pos = startPos;
                  error++;
                } else {
                  diskCurrent[2].insert(0, current);
                  currentList.remove(current);
                  move++;
                  for (var i = 0; i < diskState.length; i++) {
                    if (diskState[i][1] == 3) diskState[i][2]++;
                  }
                  currentState[2] = 0;
                }
              }
            }

            if (startPos != currentState[1]) {
              for (var i = 0; i < diskState.length; i++) {
                if (diskState[i][1] == startPos) diskState[i][2]--;
              }
            }

            if (widget.type == 't' && move == 1) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AnimatedOpacity(
                        opacity: change3 ? 1 : 0,
                        duration: Duration(milliseconds: 2000),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Text("잘하셨습니다! 계속 해보세요!",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.amber,
                                        decoration: TextDecoration.none)),
                              )),
                        ),
                      )));
            }

            //APPEND1

            if (widget.type == 'r' && error >= 10) {
              showDialog(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Fail!'),
                    content: Text("you make many errors!"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.pop(context, "OK");
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context, "Cancel");
                        },
                      ),
                    ],
                  );
                },
              );
            }

            if (complete(2)) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AnimatedOpacity(
                        opacity: change3 ? 1 : 0,
                        duration: Duration(milliseconds: 2000),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Text("세번째 칸에 옮기셔야 합니다!",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.amber,
                                        decoration: TextDecoration.none)),
                              )),
                        ),
                      )));
            }

            if (complete(3)) {
              int n = diskState.length;

              _timer.cancel();

              String text =
                  "You solved the problem!!! Will you wanna play this again?";

              if (move == power(2, n) - 1) {
                text =
                    "You solved the problem!!! Greatly!!! You've moved at least the number of moves. Will you wanna play this again?";
              }

              if (widget.type == 't') {
                text = "YOU COMPLEATE";
                firebaseFirestore
                    .collection('checkflag')
                    .doc("flag")
                    .update({"prac": true});
              } else {
                prac_check[Disk.of(context)!.widget.n] = true;

                firebaseFirestore
                    .collection("checkflag")
                    .doc("flag")
                    .update({"practice": prac_check});

                if (prac_check[6] == true) {
                  firebaseFirestore
                      .collection("checkflag")
                      .doc("flag")
                      .update({"real": true});
                }
              }

              showDialog(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Congratulation!!!'),
                    content: Text(text),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.pop(context, "OK");
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context, "Cancel");
                        },
                      ),
                    ],
                  );
                },
              );
            }
          });
        }); */
  }

  void initState() {
    //num pos index

    _finished = false;

    List<List<int>> init = random(widget.n, widget.randomn);

    firebaseFirestore
        .collection("User")
        .doc(id)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.get('realgame') != "" && widget.type == 'r') {
        init = saveList(ds.get("realgame"));
        _time = init[3][0].toDouble();
        move = init[3][1];
        error = init[3][2];
      } else if (ds.get("index${widget.n}") != "" &&
          widget.type != 't' &&
          widget.type != 'r') {
        init = saveList(ds.get("index${widget.n}"));
        _time = init[3][0].toDouble();
        move = init[3][1];
        error = init[3][2];
      }

      for (int i = 0; i < 3; i++) {
        for (int j = init[i].length - 1; j >= 0; j--) {
          diskCurrent[i].insert(0, buildDisk(init[i][j], pos: i + 1));
          diskState[init[i][j] - 1] = [init[i][j], i + 1, j];
          //print(" $i ---- ${init[i][j]-1} : ${init[i][j]} : ${i+1} : $j");
        }

        //print("\n");
      }
    });

    //print(init);
    //print(diskState.length);

/*
    for(var i = widget.n; i >= 1; i--){
      diskCurrent1.insert(0,buildDisk(i));
      diskState.insert(0,[i,1,i-1]);
    }


 */

    if (widget.faden != 0) {
      _timer = Timer.periodic(Duration(seconds: widget.faden), (timer) {
        if (mounted) {
          setState(() {
            _visible1 = false;
            _visible3 = false;
            _visible2 = false;
          });
        }
      });

      _timer = Timer.periodic(Duration(seconds: widget.faden + 8), (timer) {
        if (mounted) {
          setState(() {
            /*
      var n = Random().nextInt(3);
      if(n == 0) _visible1 = !(_visible1);
      else if(n == 1) _visible2 = !(_visible2);
      else if(n == 2) _visible3 = !(_visible3);
       */
            _visible2 = true;
          });
        }
      });
    }

    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      if (mounted) {
        setState(() {
          /*
      var n = Random().nextInt(3);
      if(n == 0) _visible1 = !(_visible1);
      else if(n == 1) _visible2 = !(_visible2);
      else if(n == 2) _visible3 = !(_visible3);
       */
          _time += 1.23;
        });
      }
    });

    super.initState();
  }

  void dispose() {
    _timer.cancel();

    if (!_finished && widget.type != 't') {
      if (widget.type == 'r')
        firebaseFirestore.collection("User").doc(id).update(
            {"realgame": saveString(diskState, _time.toInt(), move, error)});
      else
        firebaseFirestore.collection("User").doc(id).update({
          "index${widget.n}": saveString(diskState, _time.toInt(), move, error)
        });
    }

    _visible1 = true;
    _visible2 = true;
    _visible3 = true;

    _time = 0;

    error = 0;

    super.dispose();

    print("SAVE");
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _time = 0;
        error = 0;
        move = 0;
        diskState.clear();
        for (var i = 0; i < 3; i++) diskCurrent[i].clear();

        for (var i = widget.n; i >= 1; i--) {
          diskCurrent[0].insert(0, buildDisk(i));
          diskState.insert(0, [i, 1, i - 1]);
        }
        for (var i = 0; i < 3; i++) diskCurrent[i].add(SizedBox(height: 20));

        if (widget.faden != 0) {
          _timer = Timer.periodic(Duration(seconds: widget.faden), (timer) {
            if (mounted) {
              setState(() {
                _visible1 = false;
                _visible3 = false;
                _visible2 = false;
              });
            }
          });

          _timer = Timer.periodic(Duration(seconds: widget.faden + 8), (timer) {
            if (mounted) {
              setState(() {
                /*
      var n = Random().nextInt(3);
      if(n == 0) _visible1 = !(_visible1);
      else if(n == 1) _visible2 = !(_visible2);
      else if(n == 2) _visible3 = !(_visible3);
       */
                _visible2 = true;
              });
            }
          });
        }

        if (mounted) {
          setState(() {
            /*
      var n = Random().nextInt(3);
      if(n == 0) _visible1 = !(_visible1);
      else if(n == 1) _visible2 = !(_visible2);
      else if(n == 2) _visible3 = !(_visible3);
       */
            _time += 1.23;
          });
        }
      });
    }
  }

  bool complete(int compare) {
    for (var i = 0; i < diskState.length; i++) {
      if (diskState[i][1] != compare || diskState[i][2] != i) return false;
    }
    return true;
  }

  List<List<int>> random(int n, int randomn) {
    List<List<int>> result = [[], [], []];
    var temp;

    for (int i = 1; i <= n; i++) {
      result[0].add(i);
      diskState.add([]);
    }

    int first, second; // 움직일 기둥 위치, 옮길 기둥 위치

    for (var i = 1; i <= randomn; i++) {
      first = Random().nextInt(3);
      second = Random().nextInt(3);

      if (result[first].length == 0) {
      } else {
        temp = result[first][0];
        result[first].remove(temp);
        result[second].insert(0, temp);
      }
    }
    return result;
  }

  int power(int x, int n) {
    int retval = 1;
    for (int i = 0; i < n; i++) retval *= x;
    return retval;
  }

  @override
  Widget build(BuildContext context) {
    var hour = "${((_time / (100 * 60 * 60)) % 24).toInt()}".padLeft(2, "0");
    var min = "${((_time / (100 * 60)) % 60).toInt()}".padLeft(2, "0");
    var sec = "${((_time / (100)) % 60).toInt()}".padLeft(2, "0");
    var hundredth = "${(_time % 100).toInt()}".padLeft(2, "0");

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          title: Text(
              "Move : $move, Time : $hour : $min : $sec : $hundredth Error : $error"),
          backgroundColor: Colors.amber),
      body: Stack(
        children: <Widget>[
          //Image.asset('imgs/background.png',fit : BoxFit.fill,height: double.infinity,width: double.infinity,alignment: Alignment.center,),
          Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: AnimatedOpacity(
                    opacity: _visible2 ? 1.0 : 0.0,
                    duration: Duration(
                      milliseconds: 1000,
                    ),
                    child: Disk1()),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.amber)),
              )),
              Expanded(
                  child: Container(
                child: AnimatedOpacity(
                    opacity: _visible2 ? 1.0 : 0.0,
                    duration: Duration(
                      milliseconds: 1000,
                    ),
                    child: Disk2()),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.amber)),
              )),
              Expanded(
                  child: Container(
                child: AnimatedOpacity(
                    opacity: _visible2 ? 1.0 : 0.0,
                    duration: Duration(
                      milliseconds: 1000,
                    ),
                    child: Disk3()),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.amber)),
              )),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        child: Icon(Icons.refresh),
        backgroundColor: Colors.amber,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

double dx1 = 0;

class Disk1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: Disk.of(context)!.diskCurrent[0],
              ),
            ),
            onHorizontalDragUpdate: (DragUpdateDetails detail) {
              dx1 = detail.globalPosition.dx;
              print("$dx1");
            },
            onHorizontalDragEnd: (_) {
              print("End : $dx1");
              var startPos, endPos;
              var size = MediaQuery.of(context).size.width / 3;
              startPos = 1;
              if (dx1 < size)
                endPos = 1;
              else if (dx1 < size * 2)
                endPos = 2;
              else if (dx1 >= size * 2) endPos = 3;

              print("$startPos, $endPos");

              //List<Widget> currentList = Disk.of(context)!.diskCurrent[startPos-1];

              //List<int> currentState = Disk.of(context)!.diskState[0];

              //Widget current = currentList[0];

              int num = 0;

              for (int i = 0; i < Disk.of(context)!.diskState.length; i++) {
                if (Disk.of(context)!.diskState[i][1] == startPos &&
                    Disk.of(context)!.diskState[i][2] == 0) num = i;
              }

              if (Disk.of(context)!.diskState[num][2] != 0) {
                Disk.of(context)!.error++;
              } else {
                //pos = 1;
                Disk.of(context)!.diskState[num][1] = endPos;

                //print("${Disk.of(context)!.diskCurrent[endPos-1].length}");
                print(
                    "First : $startPos, ${Disk.of(context)!.diskState[num][1]}");

                if (Disk.of(context)!.diskCurrent[endPos - 1].length == 1) {
                  Disk.of(context)!.diskState[num][2] = 0;
                  Disk.of(context)!.diskCurrent[endPos - 1].insert(
                      0, Disk.of(context)!.diskCurrent[startPos - 1][0]);
                  Disk.of(context)!
                      .diskCurrent[startPos - 1]
                      .remove(Disk.of(context)!.diskCurrent[endPos - 1][0]);
                  Disk.of(context)!.move++;
                } else if (startPos != Disk.of(context)!.diskState[num][1]) {
                  //print("1 : ${currentState[0]},${currentState[1]},${currentState[2]},");
                  int compare = 0;

                  for (var i = 0; i < Disk.of(context)!.diskState.length; i++) {
                    if (Disk.of(context)!.diskState[i][1] ==
                            Disk.of(context)!.diskState[num][1] &&
                        Disk.of(context)!.diskState[i][2] == 0 &&
                        Disk.of(context)!.diskState[i][0] !=
                            Disk.of(context)!.diskState[num][0])
                      compare = i + 1;
                    print(
                        "POS : ${Disk.of(context)!.diskState[i][1]} : ${Disk.of(context)!.diskState[startPos - 1][1]}, INDEX : ${Disk.of(context)!.diskState[i][2]} : 0, NUM : ${Disk.of(context)!.diskState[i][0]} : ${Disk.of(context)!.diskState[startPos - 1][0]}");
                  }

                  if (Disk.of(context)!.diskState[num][0] > compare) {
                    Disk.of(context)!.diskState[num][1] = startPos;
                    Disk.of(context)!.error++;
                  } else {
                    Disk.of(context)!.diskCurrent[endPos - 1].insert(
                        0, Disk.of(context)!.diskCurrent[startPos - 1][0]);
                    Disk.of(context)!
                        .diskCurrent[startPos - 1]
                        .remove(Disk.of(context)!.diskCurrent[endPos - 1][0]);
                    Disk.of(context)!.move++;
                    for (var i = 0;
                        i < Disk.of(context)!.diskState.length;
                        i++) {
                      if (Disk.of(context)!.diskState[i][1] == endPos)
                        Disk.of(context)!.diskState[i][2]++;
                    }
                    Disk.of(context)!.diskState[num][2] = 0;
                  }
                }

                if (startPos != Disk.of(context)!.diskState[num][1]) {
                  for (var i = 0; i < Disk.of(context)!.diskState.length; i++) {
                    if (Disk.of(context)!.diskState[i][1] == startPos)
                      Disk.of(context)!.diskState[i][2]--;
                  }
                }
              }

              print(
                  "GOODdjnjasjdlkk : ${Disk.of(context)!.widget.type}, ${Disk.of(context)!.move},${Disk.of(context)!.error}");

              if (Disk.of(context)!.widget.type == 't' &&
                  Disk.of(context)!.move == 1) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AnimatedOpacity(
                          opacity: change3 ? 1 : 0,
                          duration: Duration(milliseconds: 2000),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text("잘하셨습니다! 계속 해보세요!",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.amber,
                                          decoration: TextDecoration.none)),
                                )),
                          ),
                        )));
              }

              //APPEND2

              if (Disk.of(context)!.widget.type == 'r' &&
                  Disk.of(context)!.error >= 10) {
                showDialog(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Fail!'),
                      content: Text("you make many errors!"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context, "OK");
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                        ),
                      ],
                    );
                  },
                );
              }

              if (Disk.of(context)!.complete(2)) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AnimatedOpacity(
                          opacity: change3 ? 1 : 0,
                          duration: Duration(milliseconds: 2000),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text("세번째 칸에 옮기셔야 합니다!",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.amber,
                                          decoration: TextDecoration.none)),
                                )),
                          ),
                        )));
              }

              if (Disk.of(context)!.complete(3)) {
                int n = Disk.of(context)!.diskState.length;

                Disk.of(context)!._timer.cancel();

                String text =
                    "You solved the problem!!! Will you wanna play this again?";

                if (Disk.of(context)!.move ==
                    Disk.of(context)!.power(2, n) - 1) {
                  text =
                      "You solved the problem!!! Greatly!!! You've moved at least the number of moves. Will you wanna play this again?";
                }

                if (Disk.of(context)!.widget.type == 't') {
                  text = "GOOOOOD";
                  if (currentindex == 0) {
                    firebaseFirestore
                        .collection('User')
                        .doc(id)
                        .update({"prac": true});
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"currentindex": 1});
                    currentindex = 1;
                  }
                } else {
                  prac_check[Disk.of(context)!.widget.n] = true;

                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"practice": prac_check});

                  if (prac_check[6] == true) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"real": true});
                  }

                  if (currentindex < n) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"currentindex": n});
                    currentindex = n;
                  }
                  playcount++;
                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"playcount": playcount});
                  int j = (1 /
                          Disk.of(context)!._time *
                          1 /
                          Disk.of(context)!.move *
                          100000000)
                      .toInt();
                  if (Disk.of(context)!.move ==
                      Disk.of(context)!.power(2, n) - 1) {
                    j = j * 2;
                  }

                  grossscore += j;
                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"grossscore": grossscore});

                  if (score < j) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"score": j});
                    score = j;
                  }

                  grosstime += (Disk.of(context)!._time).toInt();
                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"grosstime": grosstime});

                  if (time < Disk.of(context)!._time) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"time": Disk.of(context)!._time.toInt()});
                    time = Disk.of(context)!._time.toInt();
                  }
                  if (Disk.of(context)!.widget.type == 'r')
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"realgame": ""});
                  else
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"index${Disk.of(context)!.widget.n}": ""});

                  _finished = true;

                  Navigator.of(context).pop();
                }

                showDialog(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Congratulation!!!'),
                      content: Text(text),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context, "OK");
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context, "Cancel");

                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }));
  }
}

double dx2 = 0;

class Disk2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: Disk.of(context)!.diskCurrent[1],
              ),
            ),
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              dx2 = details.globalPosition.dx;
            },
            onHorizontalDragEnd: (_) {
              print("End : $dx2");
              var startPos, endPos;
              var size = MediaQuery.of(context).size.width / 3;

              startPos = 2;

              print("Good2");
              if (dx2 < size)
                endPos = 1;
              else if (dx2 < size * 2)
                endPos = 2;
              else if (dx2 >= size * 2) endPos = 3;

              print("$startPos, $endPos");

              //List<Widget> currentList = Disk.of(context)!.diskCurrent[startPos-1];

              //List<int> currentState = Disk.of(context)!.diskState[0];

              //Widget current = currentList[0];

              int num = 0;
              print(Disk.of(context)!.diskState);
              for (int i = 0; i < Disk.of(context)!.diskState.length; i++) {
                print(
                    "${Disk.of(context)!.diskState[i][1]} : ${Disk.of(context)!.diskState[i][2]}");
                if (Disk.of(context)!.diskState[i][1] == startPos &&
                    Disk.of(context)!.diskState[i][2] == 0) num = i;
              }

              if (Disk.of(context)!.diskState[num][2] != 0) {
                Disk.of(context)!.error++;
              } else {
                //pos = 1;
                Disk.of(context)!.diskState[num][1] = endPos;

                //print("${Disk.of(context)!.diskCurrent[endPos-1].length}");
                print(
                    "First : $startPos, ${Disk.of(context)!.diskState[num][1]}");

                if (Disk.of(context)!.diskCurrent[endPos - 1].length == 1) {
                  Disk.of(context)!.diskState[num][2] = 0;
                  Disk.of(context)!.diskCurrent[endPos - 1].insert(
                      0, Disk.of(context)!.diskCurrent[startPos - 1][0]);
                  Disk.of(context)!
                      .diskCurrent[startPos - 1]
                      .remove(Disk.of(context)!.diskCurrent[endPos - 1][0]);
                  Disk.of(context)!.move++;
                } else if (startPos != Disk.of(context)!.diskState[num][1]) {
                  //print("1 : ${currentState[0]},${currentState[1]},${currentState[2]},");
                  int compare = 0;

                  for (var i = 0; i < Disk.of(context)!.diskState.length; i++) {
                    if (Disk.of(context)!.diskState[i][1] ==
                            Disk.of(context)!.diskState[num][1] &&
                        Disk.of(context)!.diskState[i][2] == 0 &&
                        Disk.of(context)!.diskState[i][0] !=
                            Disk.of(context)!.diskState[num][0])
                      compare = i + 1;
                    print(
                        "POS : ${Disk.of(context)!.diskState[i][1]} : ${Disk.of(context)!.diskState[startPos - 1][1]}, INDEX : ${Disk.of(context)!.diskState[i][2]} : 0, NUM : ${Disk.of(context)!.diskState[i][0]} : ${Disk.of(context)!.diskState[startPos - 1][0]}");
                  }

                  if (Disk.of(context)!.diskState[num][0] > compare) {
                    Disk.of(context)!.diskState[num][1] = startPos;
                    Disk.of(context)!.error++;
                  } else {
                    Disk.of(context)!.diskCurrent[endPos - 1].insert(
                        0, Disk.of(context)!.diskCurrent[startPos - 1][0]);
                    Disk.of(context)!
                        .diskCurrent[startPos - 1]
                        .remove(Disk.of(context)!.diskCurrent[endPos - 1][0]);
                    Disk.of(context)!.move++;
                    for (var i = 0;
                        i < Disk.of(context)!.diskState.length;
                        i++) {
                      if (Disk.of(context)!.diskState[i][1] == endPos)
                        Disk.of(context)!.diskState[i][2]++;
                    }
                    Disk.of(context)!.diskState[num][2] = 0;
                  }
                }

                if (startPos != Disk.of(context)!.diskState[num][1]) {
                  for (var i = 0; i < Disk.of(context)!.diskState.length; i++) {
                    if (Disk.of(context)!.diskState[i][1] == startPos)
                      Disk.of(context)!.diskState[i][2]--;
                  }
                }
              }

              print(
                  "GOODdjnjasjdlkk : ${Disk.of(context)!.widget.type}, ${Disk.of(context)!.move},${Disk.of(context)!.error}");

              if (Disk.of(context)!.widget.type == 't' &&
                  Disk.of(context)!.move == 1) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AnimatedOpacity(
                          opacity: change3 ? 1 : 0,
                          duration: Duration(milliseconds: 2000),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text("잘하셨습니다! 계속 해보세요!",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.amber,
                                          decoration: TextDecoration.none)),
                                )),
                          ),
                        )));
              }

              //APPEND3

              if (Disk.of(context)!.widget.type == 'r' &&
                  Disk.of(context)!.error >= 10) {
                showDialog(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Fail!'),
                      content: Text("you make many errors!"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context, "OK");
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                        ),
                      ],
                    );
                  },
                );
              }

              if (Disk.of(context)!.complete(2)) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AnimatedOpacity(
                          opacity: change3 ? 1 : 0,
                          duration: Duration(milliseconds: 2000),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text("세번째 칸에 옮기셔야 합니다!",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.amber,
                                          decoration: TextDecoration.none)),
                                )),
                          ),
                        )));
              }

              if (Disk.of(context)!.complete(3)) {
                int n = Disk.of(context)!.diskState.length;

                Disk.of(context)!._timer.cancel();

                String text =
                    "You solved the problem!!! Will you wanna play this again?";

                if (Disk.of(context)!.move ==
                    Disk.of(context)!.power(2, n) - 1) {
                  text =
                      "You solved the problem!!! Greatly!!! You've moved at least the number of moves. Will you wanna play this again?";
                }

                if (Disk.of(context)!.widget.type == 't') {
                  text = "GOOOOOD";
                  if (currentindex == 0) {
                    firebaseFirestore
                        .collection('User')
                        .doc(id)
                        .update({"prac": true});
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"currentindex": 1});
                    currentindex = 1;
                  }
                } else {
                  prac_check[Disk.of(context)!.widget.n] = true;

                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"practice": prac_check});

                  if (prac_check[6] == true) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"real": true});
                  }

                  if (currentindex < n) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"currentindex": n});
                    currentindex = n;
                  }
                  playcount++;
                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"playcount": playcount});

                  int j = (1 /
                          Disk.of(context)!._time *
                          1 /
                          Disk.of(context)!.move *
                          100000000)
                      .toInt();
                  if (Disk.of(context)!.move ==
                      Disk.of(context)!.power(2, n) - 1) {
                    j = j * 2;
                  }

                  grossscore += j;
                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"grossscore": grossscore});

                  if (score < j) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"score": j});
                    score = j;
                  }

                  grosstime += (Disk.of(context)!._time).toInt();
                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"grosstime": grosstime});

                  if (time < Disk.of(context)!._time) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"time": Disk.of(context)!._time.toInt()});
                    time = Disk.of(context)!._time.toInt();
                  }

                  if (Disk.of(context)!.widget.type == 'r')
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"realgame": ""});
                  else
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"index${Disk.of(context)!.widget.n}": ""});
                  _finished = true;

                  Navigator.of(context).pop();
                }

                showDialog(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Congratulation!!!'),
                      content: Text(text),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context, "OK");
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }));
  }
}

double dx3 = 0;

class Disk3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: Disk.of(context)!.diskCurrent[2],
              ),
            ),
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              //dx = details.globalPosition.dx.floorToDouble();
              dx3 = details.globalPosition.dx;
            },
            onHorizontalDragEnd: (_) {
              var startPos, endPos;
              double size = MediaQuery.of(context).size.width / 3;
              startPos = 3;
              if (dx3 < size)
                endPos = 1;
              else if (dx3 < size * 2)
                endPos = 2;
              else if (dx3 >= size * 2) endPos = 3;

              print("$startPos, $endPos");

              //List<Widget> currentList = Disk.of(context)!.diskCurrent[startPos-1];

              //List<int> currentState = Disk.of(context)!.diskState[0];

              //Widget current = currentList[0];

              int num = 0;

              for (int i = 0; i < Disk.of(context)!.diskState.length; i++) {
                if (Disk.of(context)!.diskState[i][1] == startPos &&
                    Disk.of(context)!.diskState[i][2] == 0) num = i;
              }

              if (Disk.of(context)!.diskState[num][2] != 0) {
                Disk.of(context)!.error++;
              } else {
                //pos = 1;
                Disk.of(context)!.diskState[num][1] = endPos;

                //print("${Disk.of(context)!.diskCurrent[endPos-1].length}");
                print(
                    "First : $startPos, ${Disk.of(context)!.diskState[num][1]}");

                print(Disk.of(context)!.diskState);
                print(Disk.of(context)!.diskCurrent);

                if (Disk.of(context)!.diskCurrent[endPos - 1].length == 1) {
                  Disk.of(context)!.diskState[num][2] = 0;
                  Disk.of(context)!.diskCurrent[endPos - 1].insert(
                      0, Disk.of(context)!.diskCurrent[startPos - 1][0]);
                  Disk.of(context)!
                      .diskCurrent[startPos - 1]
                      .remove(Disk.of(context)!.diskCurrent[endPos - 1][0]);
                  Disk.of(context)!.move++;
                } else if (startPos != Disk.of(context)!.diskState[num][1]) {
                  //print("1 : ${currentState[0]},${currentState[1]},${currentState[2]},");
                  int compare = 0;

                  for (var i = 0; i < Disk.of(context)!.diskState.length; i++) {
                    if (Disk.of(context)!.diskState[i][1] ==
                            Disk.of(context)!.diskState[num][1] &&
                        Disk.of(context)!.diskState[i][2] == 0 &&
                        Disk.of(context)!.diskState[i][0] !=
                            Disk.of(context)!.diskState[num][0])
                      compare = i + 1;
                    //print(
                    //   "POS : ${Disk.of(context)!.diskState[i][1]} : ${Disk.of(context)!.diskState[startPos - 1][1]}, INDEX : ${Disk.of(context)!.diskState[i][2]} : 0, NUM : ${Disk.of(context)!.diskState[i][0]} : ${Disk.of(context)!.diskState[startPos - 1][0]}");
                  }

                  if (Disk.of(context)!.diskState[num][0] > compare) {
                    Disk.of(context)!.diskState[num][1] = startPos;
                    Disk.of(context)!.error++;
                  } else {
                    Disk.of(context)!.diskCurrent[endPos - 1].insert(
                        0, Disk.of(context)!.diskCurrent[startPos - 1][0]);
                    Disk.of(context)!
                        .diskCurrent[startPos - 1]
                        .remove(Disk.of(context)!.diskCurrent[endPos - 1][0]);
                    Disk.of(context)!.move++;
                    for (var i = 0;
                        i < Disk.of(context)!.diskState.length;
                        i++) {
                      if (Disk.of(context)!.diskState[i][1] == endPos)
                        Disk.of(context)!.diskState[i][2]++;
                    }
                    Disk.of(context)!.diskState[num][2] = 0;
                  }
                }

                if (startPos != Disk.of(context)!.diskState[num][1]) {
                  for (var i = 0; i < Disk.of(context)!.diskState.length; i++) {
                    if (Disk.of(context)!.diskState[i][1] == startPos)
                      Disk.of(context)!.diskState[i][2]--;
                  }
                }
              }

              print(
                  "GOODdjnjasjdlkk : ${Disk.of(context)!.widget.type}, ${Disk.of(context)!.move},${Disk.of(context)!.error}");

              if (Disk.of(context)!.widget.type == 't' &&
                  Disk.of(context)!.move == 1) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AnimatedOpacity(
                          opacity: change3 ? 1 : 0,
                          duration: Duration(milliseconds: 2000),
                          child: GestureDetector(
                            onTap: () {
                              change3 = false;
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text("잘하셨습니다! 계속 해보세요!",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.amber,
                                          decoration: TextDecoration.none)),
                                )),
                          ),
                        )));
              }

              //APPEND4

              if (Disk.of(context)!.widget.type == 'r' &&
                  Disk.of(context)!.error >= 10) {
                showDialog(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Fail!'),
                      content: Text("you make many errors!"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context, "OK");
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                        ),
                      ],
                    );
                  },
                );
              }

              if (Disk.of(context)!.complete(2)) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AnimatedOpacity(
                          opacity: change3 ? 1 : 0,
                          duration: Duration(milliseconds: 2000),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text("세번째 칸에 옮기셔야 합니다!",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.amber,
                                          decoration: TextDecoration.none)),
                                )),
                          ),
                        )));
              }

              if (Disk.of(context)!.complete(3)) {
                int n = Disk.of(context)!.diskState.length;

                Disk.of(context)!._timer.cancel();

                String text =
                    "You solved the problem!!! Will you wanna play this again?";

                if (Disk.of(context)!.move ==
                    Disk.of(context)!.power(2, n) - 1) {
                  text =
                      "You solved the problem!!! Greatly!!! You've moved at least the number of moves. Will you wanna play this again?";
                }

                if (Disk.of(context)!.widget.type == 't') {
                  text = "GOOOOOD";
                  if (currentindex == 0) {
                    firebaseFirestore
                        .collection('User')
                        .doc(id)
                        .update({"prac": true});
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"currentindex": 1});
                    currentindex = 1;
                  }
                } else {
                  prac_check[Disk.of(context)!.widget.n] = true;

                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"practice": prac_check});

                  if (prac_check[6] == true) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"real": true});
                  }

                  if (currentindex < n) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"currentindex": n});
                    currentindex = n;
                  }
                  playcount++;
                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"playcount": playcount});

                  int j = (1 /
                          Disk.of(context)!._time *
                          1 /
                          Disk.of(context)!.move *
                          100000000)
                      .toInt();
                  if (Disk.of(context)!.move ==
                      Disk.of(context)!.power(2, n) - 1) {
                    j = j * 2;
                  }

                  grossscore += j;
                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"grossscore": grossscore});

                  if (score < j) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"score": j});
                    score = j;
                  }

                  grosstime += (Disk.of(context)!._time).toInt();
                  firebaseFirestore
                      .collection("User")
                      .doc(id)
                      .update({"grosstime": grosstime});

                  if (time < Disk.of(context)!._time) {
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"time": Disk.of(context)!._time.toInt()});
                    time = Disk.of(context)!._time.toInt();
                  }

                  _finished = true;

                  if (Disk.of(context)!.widget.type == 'r')
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"realgame": ""});
                  else
                    firebaseFirestore
                        .collection("User")
                        .doc(id)
                        .update({"index${Disk.of(context)!.widget.n}": ""});

                  Navigator.of(context).pop();
                }

                showDialog(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Congratulation!!!'),
                      content: Text(text),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context, "OK");
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }));
  }
}
