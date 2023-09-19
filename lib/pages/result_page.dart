import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ikhlassgame/lists/app_list.dart';
import 'package:ikhlassgame/pages/level_page.dart';
import 'package:ionicons/ionicons.dart';

class ResultPage extends StatefulWidget {
  final int level;
  final List answer;
  final List answerTime;

  const ResultPage(
      {Key? key,
      required this.answer,
      required this.answerTime,
      required this.level})
      : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late int totalWord = widget.answer.length;
  late int totalCorrectWord =
      widget.answer.where((element) => element == true).toList().length;
  double percentOfPoint = 0;

  calcFinalResult() async {
    setState(() {
      percentOfPoint = (((widget.answer
                  .where((element) => element == true)
                  .toList()
                  .length) *
              100) /
          widget.answer.length);
    });
    if (percentOfPoint >= 50) {
      GetStorage().read("level") == 3
          ? GetStorage().erase()
          : GetStorage().write("level", widget.level + 1);
    } else {
      GetStorage().write("level", widget.level);
    }
  }

  // imageToTextList[level - 1]['level_time']
  int totalTime() {
    int tt = 0;
    for (var element in AppList().levelList[widget.level - 1]) {
      tt = (tt + element['level_time']).toInt();
    }
    return tt;
  }

  int totalSpendTime() {
    int tst = 0;
    for (var element in widget.answerTime) {
      tst = (tst + element).toInt();
    }
    return (totalTime() - tst).toInt();
  }

  @override
  void initState() {
    calcFinalResult();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const LevelPage());
        // Get.back(result: true);
        // Get.back(result: true);
        calcFinalResult();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.offAll(() => const LevelPage());
              // Get.back(result: true);
              calcFinalResult();
              // Get.back(result: true);
            },
            icon: const Icon(Ionicons.arrow_forward),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: Text("عدد الكلمات"
                  "\n"
                  "$totalWord "
                  "(100 %)"),
              trailing: Text("الكلمات الصحيحة"
                  "\n"
                  "$totalCorrectWord "
                  "(${(totalCorrectWord * 100 / totalWord).toStringAsFixed(2)} %)"),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: LinearProgressIndicator(
                value: totalCorrectWord / totalWord,
                minHeight: 20,
                backgroundColor: Colors.grey,
                color: totalCorrectWord / totalWord < .33
                    ? Colors.red
                    : totalCorrectWord / totalWord > .33 &&
                            totalCorrectWord / totalWord < .66
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const Divider(),
            ListTile(
              leading: Text("مجموع الوقت"
                  "\n"
                  "${totalTime()} ثانية "
                  "(100 %)"),
              trailing: Text("الوقت المستغرق"
                  "\n"
                  "${totalSpendTime()} ثانية "
                  "(${(totalSpendTime() * 100 / totalTime()).toStringAsFixed(2)} %)"),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: LinearProgressIndicator(
                value: totalSpendTime() / totalTime(),
                minHeight: 20,
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text("مجموع النقاط الكلي"),
              trailing: Text("${totalWord * 5}"),
            ),
            ListTile(
              title: const Text("مجموع النقاط المتحصل عليها"),
              trailing: Text("${totalCorrectWord * 5}"),
            )
          ],
        ),
      ),
    );
  }
}






















 // GetStorage().read("level") == 3
    //     ? GetStorage().erase()
    //     : GetStorage().write("level", widget.level + 1);
    // Future<void> b = GetStorage().write("level", widget.level);
    // if (percentOfPoint >= 50) {
    //   // GetStorage().read("level") == 3
    //   //     ? GetStorage().erase()
    //   // GetStorage().write("level", widget.level);
    //   // Future<void> b = GetStorage().write("level", widget.level);

    //   // // ignore: unrelated_type_equality_checks
    //   // if (b == true) {
    //   //   GetStorage().erase();
    //   //   GetStorage().write("level", 1);
    //   //   GetStorage().write("lang", "ar");
    //   // }

    //   // else {
    //   //   GetStorage().write("level", widget.level + 1);
    //   // }
    //   setState(() {});
    // }