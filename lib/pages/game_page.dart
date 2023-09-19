import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ikhlassgame/pages/result_page.dart';
import 'package:ionicons/ionicons.dart';
import 'package:just_audio/just_audio.dart';

class GamePage extends StatefulWidget {
  final List<Map<String, dynamic>> globalLevel;
  final int gLevel;
  const GamePage({Key? key, required this.globalLevel, required this.gLevel})
      : super(key: key);

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  late List<Map<String, dynamic>> levelQuestionList = widget.globalLevel;
  int level = 1; //للانتقال للسؤال التالى
  late int levelTime, startTime = levelQuestionList[level - 1]['level_time'];
// late List<Map<String, dynamic>> lvls = levelQuestionList[level - 1]['level'];
//  لستة الايتمات  كل ايتم  مكون من هذه العناصر
// نعتبرها لستة الاسئلة
//صف  الكلمات
  late List<Map<String, dynamic>> qList = levelQuestionList[level - 1]['items'];
//  {
//           "text_ar": "تفاحة",
//           "text_en": "apple",
//           "image": "assets/images/apples.png",
//           "sound_ar": "assets/sounds/apples.mp3",
//           "sound_en": "assets/sounds/apples.mp3",
//         },
// صف تانى
  late List<Map<String, dynamic>> q2List = List.from(qList);
  late List<GlobalKey> objectKey =
      List.generate(qList.length, (index) => GlobalKey());
// قائمة العناصر التى تم افلاتها  قيمتها الافتراضية false
  late List<bool> droppedList = List.generate(qList.length, (index) => false);
  late List answerList = List.generate(qList.length, (index) => "");
  late List answerListItem = List.generate(qList.length, (index) => "");
  List<Offset> offsets = [];
  List<Offset> doffsets = [];

  late Timer _timer;

  final player = AudioPlayer();

  List<bool> globalAnswers = [];
  List globalAnswersTime = [];

  void startTimer() {
    // print(level);// المستوى التالى من كل مستوى

    const oneSec = Duration(milliseconds: 400);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (startTime == 0) {
          setState(() {
            timer.cancel();
          });
          if (level < levelQuestionList.length) {
            setState(() {
              isWaite = true;
              _timer.cancel();
              for (var element in answerList) {
                globalAnswers.add(element);
              }
              globalAnswersTime.add(startTime);
              // منع اختيار اى عنصر الان يعنى بعد انتتهاء الوقت
              currentSelectedItem = 0;
              level++;
              startTime = levelQuestionList[level - 1]['level_time'];
              qList = levelQuestionList[level - 1]['items'];
              q2List = List.from(qList);
              // print(objectKey);
              answerList = List.generate(qList.length, (index) => "");
              droppedList = List.generate(qList.length, (index) => false);
              answerListItem = List.generate(qList.length, (index) => "");
              objectKey = List.generate(qList.length, (index) => GlobalKey());
              offsets = [];
              doffsets = [];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                for (var key in objectKey) {
                  final RenderBox renderBox =
                      key.currentContext?.findRenderObject() as RenderBox;
                  final Offset offset = renderBox.localToGlobal(Offset.zero);
                  offsets.add(offset);
                  doffsets.add(offset);
                }
              });
              // رسم الخط  التابع لكل  عنصر
              cp = CustomPainterLine(
                offsets,
                doffsets,
                objectKey,
                currentSelectedItem,
              );
              isWaite = false;
              startTimer();
            });
          } else {
            setState(() {
              for (var element in answerList) {
                if (element == "") {
                  setState(() {
                    answerList[answerList.indexOf(element)] = false;
                  });
                }
              }
              for (var element in answerList) {
                globalAnswers.add(element);
              }
              globalAnswersTime.add(startTime);
              // print(globalAnswers.length);
            });
            // حفظ  الحالة
            // GetStorage().writeIfNull("level", 1);
            // GetStorage().write("level", widget.gLevel + 1);

            Get.off(
              () => ResultPage(
                level: widget.gLevel,
                answer: globalAnswers,
                answerTime: globalAnswersTime,
              ),
            );
          }
        } else {
          setState(() {
            startTime--;
          });
        }
      },
    );
  }

  bool checkIfFull() {
    return !answerList.contains("");
  }

  resetConfirmation(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) => AlertDialog(
              backgroundColor: Colors.transparent,
            ));
  }

  

  @override
  void initState() {
    // lvls.shuffle();

    levelQuestionList.shuffle(); //  الفرز العشوائى للاسئلة
    qList.shuffle(); //خلط العناصر على الشاشة
    q2List.shuffle();
    startTimer();
    super.initState();
  }

  int currentSelectedItem = 0;

  late CustomPainter cp =
      CustomPainterLine(offsets, doffsets, objectKey, currentSelectedItem);
  bool isWaite = false;

  @override
  void dispose() {
    player.dispose();
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange.shade100,
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(builder: (context, constraints) {
            return isWaite
                ? const CircularProgressIndicator()
                : CustomPaint(
                    size: constraints.biggest,
                    painter: cp,
                    isComplex: true,
                    willChange: false,
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: const [
                                Expanded(child: Icon(Ionicons.checkmark)),
                                Expanded(child: Icon(Ionicons.close)),
                                Expanded(
                                    child: Icon(Ionicons.stopwatch_outline)),
                                Expanded(child: SizedBox()),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  "${globalAnswers.where((element) => element == true).toList().length}",
                                  textAlign: TextAlign.center,
                                )),
                                Expanded(
                                    child: Text(
                                  "${globalAnswers.where((element) => element == false).toList().length}",
                                  textAlign: TextAlign.center,
                                )),
                                Expanded(
                                    child: Text(
                                  "$startTime s",
                                  textAlign: TextAlign.center,
                                )),
                                Expanded(
                                    child: Text(
                                  "$level/${levelQuestionList.length}",
                                  textAlign: TextAlign.center,
                                )),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: qList.length,
                                  crossAxisSpacing: 4),
                          itemCount: qList.length,
                          itemBuilder: (context, index) => dragWidget(
                            key: objectKey[index],
                            // صف الكلمات
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      color: Colors.grey[400]!,
                                      spreadRadius: 1,
                                      offset: const Offset(4, 4)),
                                  const BoxShadow(
                                      color: Colors.white,
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(-4, -4)),
                                ],
                              ),
                              child: Center(
                                // على حسب اختيارك للغة يتم عرض الكلمات  عربية او انجليزية
                                child: Text(
                                  GetStorage().read('lang') == 'ar'
                                      ? "${qList[index]['text_ar']}"
                                      : "${qList[index]['text_en']}",

                                  //    GetStorage().read('lang') == 'en'
                                  // ? "${qList[index]['text_ar']}"
                                  // : "${qList[index]['text_en']}",
                                  style: const TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                              ),
                            ),
                            dataName: qList[index],
                            feedback: Container(
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      color: Colors.grey[400]!,
                                      spreadRadius: 1,
                                      offset: const Offset(4, 4)),
                                  const BoxShadow(
                                      color: Colors.white,
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(-4, -4)),
                                ],
                              ),
                              width: Get.width / qList.length,
                              height: Get.width / qList.length,
                              child: Center(
                                  child: Text(
                                GetStorage().read('lang') == 'en'
                                    ? "${qList[index]['text_en']}"
                                    : "${qList[index]['text_ar']}",
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              )),
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: q2List.length,
                                  crossAxisSpacing: 8),
                          itemCount: q2List.length,
                          itemBuilder: (context, index) => dragTargetWidget(
                              dataName: levelQuestionList[level - 1]['title'],
                              dropIndex: index),
                        ),
                      ],
                    ),
                  );
          }),
        ));
  }

  dragWidget(
      {required Map<String, dynamic> dataName,
      required Widget child,
      required GlobalKey key,
      required Widget feedback}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          key.currentContext?.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      if (level == 1) {
        offsets.add(offset);
        doffsets.add(offset);
      }
    });

    return Draggable<Map<String, dynamic>>(
      data: dataName,
      child: child,
      key: key,
      feedback: Material(
        child: feedback,
      ),
      childWhenDragging: child,
      onDragStarted: () {
        setState(() {
          // print(dataName); //
          currentSelectedItem = qList.indexOf(dataName);
          //print(currentSelectedItem);//
        });
      },
      onDragUpdate: (DragUpdateDetails? details) {
        setState(() {
          try {
            offsets[qList.indexOf(dataName)] = details!.globalPosition;
            // offsets[qList.indexOf(dataName)] = details!.localPosition;
          } catch (e) {
            '';
          }
        });
      },
      onDraggableCanceled: (v, d) {
        setState(() {
          offsets[qList.indexOf(dataName)] = doffsets[qList.indexOf(dataName)];
          // offsets[qList.indexOf(dataName)] = dataName[qList.indexOf(dataName)];
        });
      },
    );
  }

  dragTargetWidget({
    required String dataName,
    required int dropIndex,
  }) {
    return DragTarget<Map<String, dynamic>>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.orange.shade100, width: 4),
              color: Colors.green[500]),
          //  child: Center(child: Text("${q2List[dropIndex]['text_en']}")),
          child: Center(
              child: InkWell(
            onTap: () {
              GetStorage().read('lang') == "ar"
                  ? player.setAsset(q2List[dropIndex]['sound_ar'])
                  : player.setAsset(q2List[dropIndex]['sound_en']);
              // offsets .removeAt(index)
              // print(data);
              player.play();
            },
            child: Image.asset(
              q2List[dropIndex]['image'],
            ),
          )),
        );
      },
      onAccept: (data) async {
        GetStorage().read('lang') == "ar"
            ? await player.setAsset(data['sound_ar'])
            : await player.setAsset(data['sound_en']);
        // print(data);
        player.play();
        setState(() {
          droppedList[qList.indexOf(data)] = true;
          answerList[dropIndex] =
              q2List[dropIndex]['text_ar'] == data['text_ar'];
          answerListItem[dropIndex] = data;
        });

        if (level < levelQuestionList.length) {
          if (checkIfFull()) {
          
            Future.delayed(const Duration(milliseconds: 750)).then((value) {
              
              setState(() {
                isWaite = true;
                player.pause(); //////////////////هام جدا
                _timer.cancel();
                for (var element in answerList) {
                  globalAnswers.add(element);
                }
              });
              globalAnswersTime.add(startTime);
              currentSelectedItem = 0;
              level++;
              startTime = levelQuestionList[level - 1]['level_time'];
              qList = levelQuestionList[level - 1]['items'];
              q2List = List.from(qList);
              q2List.shuffle();
              answerList = List.generate(qList.length, (index) => "");
              droppedList = List.generate(qList.length, (index) => false);
              answerListItem = List.generate(qList.length, (index) => "");
              objectKey = List.generate(qList.length, (index) => GlobalKey());
              offsets = [];
              doffsets = [];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                for (var key in objectKey) {
                  final RenderBox renderBox =
                      key.currentContext?.findRenderObject() as RenderBox;
                  final Offset offset = renderBox.localToGlobal(Offset.zero);

                  offsets.add(offset);
                  doffsets.add(offset);
                }
              });
              cp = CustomPainterLine(
                  offsets, doffsets, objectKey, currentSelectedItem);

              isWaite = false;
              startTimer();
            });
          }
        } else {
          if (checkIfFull()) {
            resetConfirmation(context);
            setState(() {
              _timer.cancel();
              for (var element in answerList) {
                globalAnswers.add(element);
              }
              globalAnswersTime.add(startTime);
            });
            // GetStorage().write("level", widget.globalLevel);
            // GetStorage().writeIfNull("level", widget.gLevel + 1);
            Future.delayed(const Duration(seconds: 2)).then((value) {
              // GetStorage().write("level", widget.globalLevel);
              Get.off(() => ResultPage(
                    level: widget.gLevel,
                    answer: globalAnswers,
                    answerTime: globalAnswersTime,
                  ));
            });
          }
        }
      },
      onWillAccept: (data) {
        // return answerList[dropIndex] == '';
        setState(() {
          answerList[dropIndex] == objectKey ? false : true;
        });
        return true;
      },

      // onWillAccept: (data)  =>true,
    );
  }
}

class CustomPainterLine extends CustomPainter {
  List objectKey;
  List offsets;
  List doffsets;
  int index;
  CustomPainterLine(this.offsets, this.doffsets, this.objectKey, this.index);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 5;
    for (int i = 0; i < offsets.length; i++) {
      final RenderBox renderBox =
          objectKey[index].currentContext?.findRenderObject() as RenderBox;

      final p1 = Offset(
        doffsets[i].dx,
        doffsets[i].dy - renderBox.size.height / 2,
      );
      final p2 = Offset(
        offsets[i].dx,
        offsets[i].dy - renderBox.size.height / 2,
      );

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
