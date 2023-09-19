import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ikhlassgame/lists/app_list.dart';
import 'package:ikhlassgame/pages/game_page.dart';
import 'package:ionicons/ionicons.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({Key? key}) : super(key: key);

  @override
  _LevelPageState createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  late int _lv;
  final data = GetStorage();
  @override
  void initState() {
    GetStorage.init();
    _lv = 0;
    // GetStorage().writeIfNull("level", 1);
    data.writeIfNull("lang", "ar");
    // GetStorage().write("lang", "ar");
    super.initState();
    if (data.read("level") == null) {
      _lv != data.read("level") ? GetStorage().writeIfNull("level", 1) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faisal Matching Game'),
        actions: [
          IconButton(
              onPressed: () {
                GetStorage().erase();
                GetStorage().writeIfNull("level", 1);
                GetStorage().writeIfNull("lang", "ar");
                setState(() {});
              },
              icon: const Icon(Ionicons.refresh)),
          IconButton(
              onPressed: () {
                GetStorage().read('lang') == 'ar'
                    ? setState(() {
                        GetStorage().write('lang', 'en');
                      })
                    : setState(() {
                        GetStorage().write('lang', 'ar');
                      });
                // ? GetStorage().write("lang", "en")
                // : GetStorage().write("lang", "ar");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("${GetStorage().read('lang')}"),
                  duration: const Duration(milliseconds: 400),
                ));
              },
              icon: const Icon(Ionicons.globe_outline)),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: AppList().levelList.length,
        itemBuilder: (
          context,
          index,
        ) {
          // ignore: avoid_print

          return GestureDetector(
            onTap: GetStorage().read("level") < index + 1
                ? null
                : () => Get.to(
                      () => GamePage(
                        //الوصول لاسئلة المستوى
                        globalLevel: AppList().levelList[index],
                        gLevel: index + 1,
                      ),
                    ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: GetStorage().read("level") < index + 1
                  ? Colors.blueGrey.shade200 //مغلق
                  : GetStorage().read("level") == index + 1 // مفتوح
                      ? Colors.orange
                      : Colors.green.shade900, // تمت
              child: Center(
                child: GetStorage().read("level") < index + 1
                    ? Icon(
                        Ionicons.lock_closed,
                        size: Get.size.width / 6,
                        color: Colors.red.shade900,
                      )
                    : Text(
                        "${index + 1}",
                        style: Get.textTheme.headline2!
                            .copyWith(color: Colors.white),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
