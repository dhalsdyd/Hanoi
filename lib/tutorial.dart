import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'tower_hanoi.dart';

bool change3 = true;
bool change2 = true;
bool change1 = true;
bool change = true;
bool once = true;
bool once2 = true;

bool movecheck = true;
int _widgetindex = 2;

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
            Hero(
              tag : "one",
              child: MyA(
                n: 3,
                randomn: 0,
                faden: 0,
                type: 't',
              ),
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
                    Hero(tag: "two",child: MyA(n: 3, randomn: 0, faden: 0,type : "t")),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Text(
                              "디스크를 잡고 옮기거나 칸을 선택해서 옮길 수 있습니다\n한번은 디스크, 한번은 칸으로 움직여 보세요\n세번째 칸으로 다 옮기면 됩니다",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber,
                                  decoration: TextDecoration.none),
                          textAlign: TextAlign.center,),

                        )),
                    PositionedTransition(
                      rect: RelativeRectTween(
                        begin: RelativeRect.fromSize(
                            Rect.fromLTWH(
                                MediaQuery.of(context).size.width / 4,
                                MediaQuery.of(context).size.height / 8 * 7,
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
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                    decoration: TextDecoration.none)),
                            Text(
                                "1. 한번에 하나만 이동 가능합니다\n2. 작은 원반 위로 큰 원반을 이동할 수 없습니다\n3. 가장 위의 원판만 이동 가능합니다",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber,
                                    decoration: TextDecoration.none),
                                textAlign: TextAlign.center),
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
/*
Widget build(BuildContext context) {
    return AnimatedBuilder(
      child : Stack(children: [
        MyA(n: 3, randomn: 0, faden: 0),
        Positioned(
          bottom: 50,
          left: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              AnimatedContainer(
                  duration: Duration(seconds: 1),
                  height: height,
                  width: width,
                  child: Image.asset("../imgs/arrow.png",
                      height: height, width: width, fit: BoxFit.fill)),
              FlatButton(
                color : Colors.white.withOpacity(0.0),
                child:
                Image.asset("../imgs/hand.png", height: height, width: 200),
                onPressed: () =>
                    setState(() =>
                    width =
                    width == 0 ? MediaQuery
                        .of(context)
                        .size
                        .width - 200 : 0),
              ),
            ],
          ),
        ),
      ]),
      animation: aniController,
      builder: (context,child){
        return Trans
    };
  }
 */
