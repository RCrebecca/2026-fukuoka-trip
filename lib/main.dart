import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const String apiKey = "AIzaSyAsvVaZyk-MwAfmGhtnQbTnKfLNLad5myY";

  if (apiKey != "YOUR_API_KEY" && apiKey.isNotEmpty) {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: apiKey,
          authDomain: "y-fukuoka-trip.firebaseapp.com",
          projectId: "y-fukuoka-trip",
          storageBucket: "y-fukuoka-trip.firebasestorage.app",
          messagingSenderId: "1097824951606",
          appId: "1:1097824951606:web:6260f1b06f92b95c706797",
        ),
      );
      Db.isFirebase = true;
      await _initializeFirebaseDataIfNeeded();
    } catch (e) {
      Db.isFirebase = false;
      Db.initLocal();
    }
  } else {
    Db.isFirebase = false;
    Db.initLocal();
  }

  runApp(const BlackOrangeTravelApp());
}

class IndustrialStyle {
  static const Color bgMarble = Color(0xFFEFEFEF);
  static const Color strokeBlack = Color(0xFF000000);
  static const Color accentOrange = Color(0xFFFF5500);

  static BoxDecoration neoBox({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: strokeBlack, width: 3.5),
      boxShadow: const [BoxShadow(color: strokeBlack, offset: Offset(5, 5), blurRadius: 0)],
    );
  }
}

class Db {
  static bool isFirebase = false;
  static List<Map<String, dynamic>> travelPlan = [];
  static List<Map<String, dynamic>> pocketList = [
    {"name": "MaxValu 博多祇園店", "category": "購物"}, {"name": "いくら博多店 はんばーぐと", "category": "正餐"},
    {"name": "博多水炊 濱田屋 本店", "category": "正餐"}, {"name": "串燒 八兵衛", "category": "正餐"},
    {"name": "燒肉 大東園 本店", "category": "正餐"}, {"name": "かわ屋 祇園店", "category": "正餐"},
    {"name": "水炊名店 鳥田 博多本店", "category": "正餐"}, {"name": "24小時 築地壽司鮮", "category": "正餐"},
    {"name": "食堂 おわん", "category": "早餐"}, {"name": "小料理屋 そのへん", "category": "正餐"},
    {"name": "だしいなり 海木", "category": "點心"}, {"name": "柳橋食堂", "category": "正餐"},
    {"name": "°F/concept", "category": "正餐"}, {"name": "Musashiza", "category": "正餐"},
    {"name": "Hakata阿菜-Asa-", "category": "早餐"}, {"name": "Hakata seafood Uoden", "category": "正餐"},
    {"name": "おいしいパスタ", "category": "正餐"}, {"name": "博多拉麵 ShinShin 博多DEITOS店", "category": "正餐"},
    {"name": "Ganso Hakata Mentaiju", "category": "外帶"}, {"name": "博多一幸舍 博多本店", "category": "正餐"},
    {"name": "本格燒鳥 大名へて 貳號店", "category": "正餐"}, {"name": "しちみ", "category": "正餐"},
    {"name": "博多拉麵 ShinShin 天神本店", "category": "正餐"}, {"name": "Gohanya Hansuke", "category": "正餐"},
    {"name": "博多水炊鍋專門 橙", "category": "正餐"}, {"name": "Robata no Ito Okashi", "category": "正餐"},
    {"name": "福太郎 博多DEITOS店", "category": "伴手禮"}, {"name": "Torifumi Akasaka", "category": "正餐"},
    {"name": "Sabataro", "category": "早餐"}, {"name": "Robata Hyakushiki", "category": "正餐"},
    {"name": "Pain Stock Tenjin", "category": "早餐"}, {"name": "The Full Full Hakata", "category": "伴手禮"},
    {"name": "博多駅の辛子明太子専門店", "category": "伴手禮"}, {"name": "SABOE HAKATA", "category": "購物"},
    {"name": "小倉山莊 博多大丸店", "category": "伴手禮"}, {"name": "小倉山莊 阪急博多店", "category": "伴手禮"},
    {"name": "明太子煎餅 博多風美庵", "category": "伴手禮"}, {"name": "鈴懸 博多DEITOS店", "category": "伴手禮"},
    {"name": "如水庵 博多站DEITOS 1號店", "category": "伴手禮"}, {"name": "伊都King 博多MING店", "category": "伴手禮"},
    {"name": "Dacomecca", "category": "早餐"}, {"name": "鈴懸 天神岩田屋店", "category": "伴手禮"},
    {"name": "Full full", "category": "伴手禮"}, {"name": "AMAM DACOTAN Ropponmatsu", "category": "早餐"},
    {"name": "Bread, Espresso & Hakata", "category": "咖啡/午茶"}, {"name": "NOOICE Tenjin", "category": "咖啡/午茶"},
    {"name": "Imonne Hakata", "category": "點心"}, {"name": "白金茶房", "category": "咖啡/午茶"},
    {"name": "Abeki", "category": "咖啡/午茶"}, {"name": "&LOCALS 大濠公園", "category": "咖啡/午茶"},
    {"name": "百藥", "category": "Bar"}, {"name": "Oscar", "category": "Bar"}
  ];

  static final _travelPlanController = StreamController<List<Map<String, dynamic>>>.broadcast();
  static final _pocketListController = StreamController<List<Map<String, dynamic>>>.broadcast();

  static Stream<List<Map<String, dynamic>>> get travelPlanStream => _travelPlanController.stream;
  static Stream<List<Map<String, dynamic>>> get pocketListStream => _pocketListController.stream;

  static void initLocal() {
    travelPlan = [
      {"day_index": 0, "date": "9/25 (五)", "title": "Day 1 · 出發與糸島", "hotel_name": "糸島 Seven*Seven", "items": []},
      {"day_index": 1, "date": "9/26 (六)", "title": "Day 2 · 博多市區", "hotel_name": "西鐵克魯姆酒店", "items": []},
      {"day_index": 2, "date": "9/27 (日)", "title": "Day 3 · 博多市區", "hotel_name": "西鐵克魯姆酒店", "items": []},
      {"day_index": 3, "date": "9/28 (一)", "title": "Day 4 · 返航", "hotel_name": "退房", "items": []}
    ];
    refreshAllStreams();
  }

  static void refreshAllStreams() {
    _travelPlanController.add(List.from(travelPlan));
    _pocketListController.add(List.from(pocketList));
  }
}

class BlackOrangeTravelApp extends StatelessWidget {
  const BlackOrangeTravelApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const MainNavigatorScreen());
  }
}

class MainNavigatorScreen extends StatefulWidget {
  const MainNavigatorScreen({Key? key}) : super(key: key);
  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const TimelinePage(), const PocketListPage(), const TranslationToolsPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_view_day), label: '行程'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '口袋名單'),
          BottomNavigationBarItem(icon: Icon(Icons.g_translate), label: '翻譯'),
        ],
      ),
    );
  }
}

class TimelinePage extends StatelessWidget { const TimelinePage({Key? key}) : super(key: key); @override Widget build(BuildContext context) => const Center(child: Text("行程頁面")); }
class PocketListPage extends StatelessWidget { const PocketListPage({Key? key}) : super(key: key); @override Widget build(BuildContext context) => const Center(child: Text("口袋名單頁面")); }
class TranslationToolsPage extends StatelessWidget { const TranslationToolsPage({Key? key}) : super(key: key); @override Widget build(BuildContext context) => const Center(child: Text("翻譯頁面")); }

Future<void> _initializeFirebaseDataIfNeeded() async {
  final pocketSnap = await FirebaseFirestore.instance.collection('pocket_list').limit(1).get();
  if (pocketSnap.docs.isEmpty) {
    for (var pocket in Db.pocketList) { await FirebaseFirestore.instance.collection('pocket_list').add(pocket); }
  }
}
