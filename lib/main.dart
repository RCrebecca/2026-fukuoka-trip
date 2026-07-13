import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const String apiKey = "YOUR_API_KEY";

  if (apiKey != "YOUR_API_KEY" && apiKey.isNotEmpty) {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: apiKey,
          authDomain: "YOUR_AUTH_DOMAIN",
          projectId: "YOUR_PROJECT_ID",
          storageBucket: "YOUR_STORAGE_BUCKET",
          messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
          appId: "YOUR_APP_ID",
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
      boxShadow: const [
        BoxShadow(
          color: strokeBlack,
          offset: Offset(5, 5),
          blurRadius: 0,
        )
      ],
    );
  }
}

class Db {
  static bool isFirebase = false;
  static List<Map<String, dynamic>> travelPlan = [];
  static List<Map<String, dynamic>> pocketList = [];

  static final _travelPlanController = StreamController<List<Map<String, dynamic>>>.broadcast();
  static final _pocketListController = StreamController<List<Map<String, dynamic>>>.broadcast();

  static Stream<List<Map<String, dynamic>>> get travelPlanStream {
    Timer.run(() => _travelPlanController.add(List.from(travelPlan)));
    return _travelPlanController.stream;
  }
  static Stream<List<Map<String, dynamic>>> get pocketListStream {
    Timer.run(() => _pocketListController.add(List.from(pocketList)));
    return _pocketListController.stream;
  }

  static void initLocal() {
    travelPlan = [
      {
        "day_index": 0, "date": "9/25 (五)", "title": "Day 1 · 出發與糸島",
        "hotel_name": "糸島 Seven*Seven (住宿房價 NT\$16,640)",
        "items": [
          {"time": "07:00", "event": "星宇航空 JX840", "sub": "09:35桃園機場 - 13:05福岡機場"},
          {"time": "14:00", "event": "飯店辦理 Check In", "sub": "seven x seven 糸島"},
          {"time": "16:00", "event": "糸島海鮮堂 二見ヶ浦本店", "sub": "享用超豐富海鮮"},
          {"time": "17:00", "event": "二見ヶ浦海岸夫婦岩", "sub": "絕美夕陽地標"}
        ]
      },
      {
        "day_index": 1, "date": "9/26 (六)", "title": "Day 2 · 未排定行程",
        "hotel_name": "博多祇園櫛田神社前西鐵克魯姆酒店 (3間房共 NT\$24,483)", "items": []
      },
      {
        "day_index": 2, "date": "9/27 (日)", "title": "Day 3 · 未排定行程",
        "hotel_name": "博多祇園櫛田神社前西鐵克魯姆酒店 (連續入住第2晚)", "items": []
      },
      {
        "day_index": 3, "date": "9/28 (一)", "title": "Day 4 · 返航回家",
        "hotel_name": "今日退房 (西鐵克魯姆酒店 11:00前)",
        "items": [
          {"time": "14:15", "event": "星宇航空 JX841", "sub": "14:15福岡機場 - 15:45桃園機場"}
        ]
      }
    ];

    pocketList = [
      {"name": "MaxValu 博多祇園店", "category": "購物"},
      {"name": "いくら博多店 はんばーぐと", "category": "正餐"},
      {"name": "博多水炊 濱田屋 本店", "category": "正餐"},
      {"name": "串燒 八兵衛", "category": "正餐"},
      {"name": "燒肉 大東園 本店", "category": "正餐"},
      {"name": "かわ屋 祇園店", "category": "正餐"},
      {"name": "水炊名店 鳥田 博多本店", "category": "正餐"},
      {"name": "24小時 築地壽司鮮", "category": "正餐"},
      {"name": "食堂 おわん", "category": "早餐"},
      {"name": "小料理屋 そのへん", "category": "正餐"},
      {"name": "だしいなり 海木", "category": "點心"},
      {"name": "柳橋食堂", "category": "正餐"},
      {"name": "°F/concept", "category": "正餐"},
      {"name": "Musashiza", "category": "正餐"},
      {"name": "Hakata阿菜-Asa-", "category": "早餐"},
      {"name": "Hakata seafood Uoden", "category": "正餐"},
      {"name": "おいしいパスタ", "category": "正餐"},
      {"name": "博多拉麵 ShinShin 博多DEITOS店", "category": "正餐"},
      {"name": "Ganso Hakata Mentaiju", "category": "外帶"},
      {"name": "博多一幸舍 博多本店", "category": "正餐"},
      {"name": "本格燒鳥 大名へて 貳號店", "category": "正餐"},
      {"name": "しちみ", "category": "正餐"},
      {"name": "博多拉麵 ShinShin 天神本店", "category": "正餐"},
      {"name": "Gohanya Hansuke", "category": "正餐"},
      {"name": "博多水炊鍋專門 橙", "category": "正餐"},
      {"name": "Robata no Ito Okashi", "category": "正餐"},
      {"name": "福太郎 博多DEITOS店", "category": "伴手禮"},
      {"name": "Torifumi Akasaka", "category": "正餐"},
      {"name": "Sabataro", "category": "早餐"},
      {"name": "Robata Hyakushiki", "category": "正餐"},
      {"name": "Pain Stock Tenjin", "category": "早餐"},
      {"name": "The Full Full Hakata", "category": "伴手禮"},
      {"name": "博多駅の辛子明太子専門店", "category": "伴手禮"},
      {"name": "SABOE HAKATA", "category": "購物"},
      {"name": "小倉山莊 博多大丸店", "category": "伴手禮"},
      {"name": "小倉山莊 阪急博多店", "category": "伴手禮"},
      {"name": "明太子煎餅 博多風美庵", "category": "伴手禮"},
      {"name": "鈴懸 博多DEITOS店", "category": "伴手禮"},
      {"name": "如水庵 博多站DEITOS 1號店", "category": "伴手禮"},
      {"name": "伊都King 博多MING店", "category": "伴手禮"},
      {"name": "Dacomecca", "category": "早餐"},
      {"name": "鈴懸 天神岩田屋店", "category": "伴手禮"},
      {"name": "Full full", "category": "伴手禮"},
      {"name": "AMAM DACOTAN Ropponmatsu", "category": "早餐"},
      {"name": "Bread, Espresso & Hakata", "category": "咖啡/午茶"},
      {"name": "NOOICE Tenjin", "category": "咖啡/午茶"},
      {"name": "Imonne Hakata", "category": "點心"},
      {"name": "白金茶房", "category": "咖啡/午茶"},
      {"name": "Abeki", "category": "咖啡/午茶"},
      {"name": "&LOCALS 大濠公園", "category": "咖啡/午茶"},
      {"name": "百藥", "category": "Bar"},
      {"name": "Oscar", "category": "Bar"}
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
    return MaterialApp(
      title: '福岡黑橘工業風 App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: IndustrialStyle.bgMarble,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Arial Black', fontWeight: FontWeight.w900, color: Colors.black),
        ),
      ),
      home: const MainNavigatorScreen(),
    );
  }
}

class MainNavigatorScreen extends StatefulWidget {
  const MainNavigatorScreen({Key? key}) : super(key: key);
  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  int _currentIndex = 0;
  bool _showFloatingCalc = false;
  double _calcJpy = 0;
  final double _rate = 0.21;

  final List<Widget> _pages = [
    const TimelinePage(),
    const PocketListPage(),
    const TranslationToolsPage(),
  ];

  void _onItemTapped(int index) async {
    if (index == 3) {
      await launchUrl(Uri.parse("https://alinchuang.my.canva.site/"), mode: LaunchMode.platformDefault);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('FUKUOKA INDUSTRIAL TRIP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        backgroundColor: IndustrialStyle.accentOrange,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 4)),
      ),
      body: Stack(
        children: [
          _pages[_currentIndex],
          
          if (_showFloatingCalc)
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                width: 210,
                padding: const EdgeInsets.all(12),
                decoration: IndustrialStyle.neoBox(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('全域快速換算 (0.21)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                    const Divider(color: Colors.black, thickness: 2),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '輸入日幣 JPY', border: OutlineInputBorder()),
                      onChanged: (val) { setState(() { _calcJpy = double.tryParse(val) ?? 0; }); },
                    ),
                    const SizedBox(height: 8),
                    Text('台幣：\$${(_calcJpy * _rate).toStringAsFixed(1)} TWD', style: const TextStyle(color: IndustrialStyle.accentOrange, fontWeight: FontWeight.w900, fontSize: 15)),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: IndustrialStyle.accentOrange,
        shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 2)),
        onPressed: () { setState(() { _showFloatingCalc = !_showFloatingCalc; }); },
        child: const Icon(Icons.currency_exchange, size: 28),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 4)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: IndustrialStyle.accentOrange,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          currentIndex: _currentIndex < 3 ? _currentIndex : 0, 
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.calendar_view_day), label: '行程'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '口袋名單'),
            BottomNavigationBarItem(icon: Icon(Icons.g_translate), label: '翻譯'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: '折價券'),
          ],
        ),
      ),
    );
  }
}

// === 行程表頁面 (加入完整的 CRUD 功能：新增、編輯、刪除) ===
class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);
  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  int _selectedDayIndex = 0;
  final List<String> _dates = ["9/25 (五)", "9/26 (六)", "9/27 (日)", "9/28 (一)"];

  void _searchNearbyGoogleMaps(String hotelName, String keyword) async {
    String jpKeyword = keyword;
    if (keyword == '超市') jpKeyword = 'スーパー';
    if (keyword == '餐廳' || keyword == '美食店') jpKeyword = '飲食店';
    if (keyword == '藥妝') jpKeyword = 'ドラッグストア';
    if (keyword == '購物商店') jpKeyword = 'ショッピング';
    if (keyword == '百貨公司') jpKeyword = 'デパート';
    if (keyword == '公園') jpKeyword = '公園';
    if (keyword == '兒童景點') jpKeyword = '子供 遊び場';

    String searchAnchor = hotelName;
    if (hotelName.contains('西鐵克魯姆') || hotelName.contains('克魯姆')) {
      searchAnchor = "西鉄ホテル クルーム博多祇園";
    } else if (hotelName.contains('Seven') || hotelName.contains('七')) {
      searchAnchor = "seven x seven 糸島";
    }

    final String encodedUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$searchAnchor 近くの $jpKeyword')}";
    await launchUrl(Uri.parse(encodedUrl), mode: LaunchMode.platformDefault);
  }

  void _searchEventOnMap(String destination) async {
    final String encodedUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(destination)}";
    await launchUrl(Uri.parse(encodedUrl), mode: LaunchMode.platformDefault);
  }

  // 彈出視窗：新增與編輯行程
  void _showEventEditor(Map<String, dynamic> dayData, {DocumentReference? docRef, int localIndex = -1, int? itemIndex}) {
    final bool isEdit = itemIndex != null;
    final Map<String, dynamic>? existingItem = isEdit ? dayData['items'][itemIndex] : null;

    final timeCtrl = TextEditingController(text: existingItem?['time'] ?? '12:00');
    final eventCtrl = TextEditingController(text: existingItem?['event'] ?? '');
    final subCtrl = TextEditingController(text: existingItem?['sub'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
          title: Text(isEdit ? '✏️ 編輯行程' : '➕ 新增行程', style: const TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeCtrl, 
                decoration: const InputDecoration(labelText: '時間 (例：14:30)', border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: IndustrialStyle.accentOrange, width: 2))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: eventCtrl, 
                decoration: const InputDecoration(labelText: '地點 / 事件名稱', border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: IndustrialStyle.accentOrange, width: 2))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subCtrl, 
                decoration: const InputDecoration(labelText: '備註細節 (可留白)', border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: IndustrialStyle.accentOrange, width: 2))),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: IndustrialStyle.accentOrange,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                if (eventCtrl.text.isEmpty) return; // 簡單防呆

                List items = List.from(dayData['items'] ?? []);
                final newItem = {
                  'time': timeCtrl.text.trim(),
                  'event': eventCtrl.text.trim(),
                  'sub': subCtrl.text.trim()
                };

                if (isEdit) {
                  items[itemIndex] = newItem; // 更新現有
                } else {
                  items.add(newItem); // 插入新增
                }
                
                // 自動依照時間重新排序
                items.sort((a, b) => a['time'].toString().compareTo(b['time'].toString()));

                // 執行儲存
                if (Db.isFirebase && docRef != null) {
                  docRef.update({'items': items});
                } else if (localIndex != -1) {
                  Db.travelPlan[localIndex]['items'] = items;
                  Db.refreshAllStreams();
                }

                Navigator.pop(context);
              },
              child: const Text('儲存並共享', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  // 彈出視窗：刪除確認
  void _deleteEvent(Map<String, dynamic> dayData, int itemIndex, {DocumentReference? docRef, int localIndex = -1}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
        title: const Text('🗑️ 刪除行程', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('確定要刪除這個行程嗎？\n刪除後將同步更新給大家。', style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () {
              List items = List.from(dayData['items'] ?? []);
              items.removeAt(itemIndex);

              // 執行刪除更新
              if (Db.isFirebase && docRef != null) {
                docRef.update({'items': items});
              } else if (localIndex != -1) {
                Db.travelPlan[localIndex]['items'] = items;
                Db.refreshAllStreams();
              }
              Navigator.pop(context);
            },
            child: const Text('確定刪除', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: IndustrialStyle.neoBox(color: Colors.white),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny, size: 48, color: IndustrialStyle.accentOrange),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('今日福岡天氣 TODAY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const Text('☀️ 26°C ~ 30°C 晴朗', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text('💡 穿著建議：早晚微涼，長輩出門記得帶件「薄防風外套」唷！', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 55,
          color: Colors.black,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedDayIndex == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? IndustrialStyle.accentOrange : Colors.grey[900],
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () { setState(() { _selectedDayIndex = index; }); },
                  child: Text(_dates[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Db.isFirebase 
            ? StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('travel_plan').where('day_index', isEqualTo: _selectedDayIndex).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('暫無行程數據'));
                  final data = docs.first.data() as Map<String, dynamic>;
                  return _buildTimelineList(data, docRef: docs.first.reference, localIndex: -1);
                },
              )
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: Db.travelPlanStream,
                initialData: Db.travelPlan,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: CircularProgressIndicator());
                  final localIndex = snapshot.data!.indexWhere((plan) => plan['day_index'] == _selectedDayIndex);
                  if (localIndex == -1) return const Center(child: Text('無行程資料'));
                  return _buildTimelineList(snapshot.data![localIndex], docRef: null, localIndex: localIndex);
                },
              ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              // 點擊新增行程按鈕，抓取目前資料狀態並呼叫彈窗
              if (Db.isFirebase) {
                FirebaseFirestore.instance.collection('travel_plan').where('day_index', isEqualTo: _selectedDayIndex).get().then((snap) {
                  if (snap.docs.isNotEmpty) {
                    var doc = snap.docs.first;
                    _showEventEditor(doc.data() as Map<String, dynamic>, docRef: doc.reference);
                  }
                });
              } else {
                final localIndex = Db.travelPlan.indexWhere((element) => element['day_index'] == _selectedDayIndex);
                if (localIndex != -1) {
                  _showEventEditor(Db.travelPlan[localIndex], localIndex: localIndex);
                }
              }
            },
            child: Container(
              height: 52,
              decoration: IndustrialStyle.neoBox(color: IndustrialStyle.accentOrange),
              alignment: Alignment.center,
              child: const Text('ADD TIMELINE EVENT +', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineList(Map<String, dynamic> data, {DocumentReference? docRef, required int localIndex}) {
    final String hotel = data['hotel_name'] ?? '西鐵克魯姆酒店';
    final List items = data['items'] ?? [];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Container(
          decoration: IndustrialStyle.neoBox(color: Colors.white),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏨 當日住宿飯店：', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold)),
              Text(hotel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: IndustrialStyle.accentOrange)),
              const Divider(color: Colors.black, thickness: 2),
              const Text('搜尋飯店周邊（保證找出結果）：', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: ['超市', '餐廳', '藥妝', '購物商店', '百貨公司', '公園', '兒童景點'].map((keyword) {
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, 
                      foregroundColor: Colors.white, 
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () => _searchNearbyGoogleMaps(hotel, keyword),
                    icon: const Icon(Icons.search, size: 14, color: IndustrialStyle.accentOrange),
                    label: Text(keyword, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('此日無排定行程。點選下方按鈕新增！', style: TextStyle(fontWeight: FontWeight.bold))),
          ),
        ...items.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: IndustrialStyle.neoBox(color: Colors.black),
                child: Text(item['time'] ?? '00:00', style: const TextStyle(color: IndustrialStyle.accentOrange, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: IndustrialStyle.neoBox(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(item['event'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
                          // 加入編輯與刪除按鈕
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _showEventEditor(data, docRef: docRef, localIndex: localIndex, itemIndex: index),
                                child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.edit, size: 20, color: Colors.blueGrey)),
                              ),
                              InkWell(
                                onTap: () => _deleteEvent(data, index, docRef: docRef, localIndex: localIndex),
                                child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.delete, size: 20, color: Colors.red)),
                              ),
                            ],
                          )
                        ],
                      ),
                      if (item['sub'] != null && item['sub'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Text(item['sub'], style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      const SizedBox(height: 4),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => _searchEventOnMap(item['event'] ?? ''),
                        icon: const Icon(Icons.location_on, size: 16),
                        label: const Text('開啟地圖定位 🗺️', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        }).toList(),
      ],
    );
  }
}

class PocketListPage extends StatefulWidget {
  const PocketListPage({Key? key}) : super(key: key);
  @override
  State<PocketListPage> createState() => _PocketListPageState();
}

class _PocketListPageState extends State<PocketListPage> {
  String _selectedCategory = "全部";
  final List<String> _categories = ["全部", "餐廳", "超市", "伴手禮", "咖啡"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 55,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
                child: ChoiceChip(
                  label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                  selected: isSelected,
                  selectedColor: IndustrialStyle.accentOrange,
                  onSelected: (val) { setState(() { _selectedCategory = cat; }); },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Db.isFirebase
            ? StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('pocket_list').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final list = snapshot.data!.docs.map((d) => d.data() as Map<String, dynamic>).toList();
                  return _buildPocketList(list);
                },
              )
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: Db.pocketListStream,
                initialData: Db.pocketList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: CircularProgressIndicator());
                  return _buildPocketList(snapshot.data!);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildPocketList(List<Map<String, dynamic>> rawList) {
    final docs = rawList.where((data) {
      final String dbCategory = data['category'] ?? '';
      if (_selectedCategory == "全部") return true;
      if (_selectedCategory == "餐廳") return dbCategory == "正餐" || dbCategory == "早餐" || dbCategory == "餐廳" || dbCategory == "外帶" || dbCategory == "Bar";
      if (_selectedCategory == "咖啡") return dbCategory == "咖啡/午茶" || dbCategory == "點心" || dbCategory.contains("咖啡");
      if (_selectedCategory == "超市") return dbCategory == "購物" || dbCategory == "超市";
      if (_selectedCategory == "伴手禮") return dbCategory == "伴手禮";
      return dbCategory == _selectedCategory;
    }).toList();

    if (docs.isEmpty) return const Center(child: Text('此分類下暫無店家資料'));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final shop = docs[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: IndustrialStyle.neoBox(),
          child: ListTile(
            title: Text(shop['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(shop['category'] ?? '', style: const TextStyle(color: IndustrialStyle.accentOrange, fontWeight: FontWeight.bold, fontSize: 12)),
            trailing: const Icon(Icons.near_me, color: Colors.black),
            onTap: () => launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(shop['name'] ?? '')}")),
          ),
        );
      },
    );
  }
}

class TranslationToolsPage extends StatelessWidget {
  const TranslationToolsPage({Key? key}) : super(key: key);

  void _launchAppOrWeb(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('長輩必備翻譯神器', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('點擊下方按鈕，直接啟動最強大的翻譯工具。', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        InkWell(
          onTap: () => _launchAppOrWeb('https://translate.google.com/?sl=ja&tl=zh-TW&op=translate'),
          child: Container(
            decoration: IndustrialStyle.neoBox(color: Colors.white),
            padding: const EdgeInsets.all(20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.camera_alt, size: 36, color: IndustrialStyle.accentOrange),
                    SizedBox(width: 12),
                    Expanded(child: Text('Google 智慧鏡頭', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                  ],
                ),
                SizedBox(height: 12),
                Text('看不懂日文菜單？點擊打開 Google 翻譯，選擇「相機」圖示，直接對著菜單拍照就能看懂！', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.5)),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('開啟拍照翻譯 ➔', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                )
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),

        InkWell(
          onTap: () => _launchAppOrWeb('https://voicetra.nict.go.jp/'),
          child: Container(
            decoration: IndustrialStyle.neoBox(color: Colors.black),
            padding: const EdgeInsets.all(20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.mic, size: 36, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text('VoiceTra 語音翻譯', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white))),
                  ],
                ),
                SizedBox(height: 12),
                Text('想直接跟日本店員講話？這是日本開發的最強語音翻譯 APP，按住麥克風講中文，它會直接幫你講日文！', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.5, color: Colors.white70)),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('開啟語音對話 ➔', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: IndustrialStyle.accentOrange)),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _initializeFirebaseDataIfNeeded() async {
  final travelSnap = await FirebaseFirestore.instance.collection('travel_plan').limit(1).get();
  if (travelSnap.docs.isEmpty) {
    final List<Map<String, dynamic>> initialPlan = [
      {
        "day_index": 0, "date": "9/25 (五)", "title": "Day 1 · 出發與糸島",
        "hotel_name": "糸島 Seven*Seven (住宿房價 NT\$16,640)",
        "items": [
          {"time": "07:00", "event": "星宇航空 JX840", "sub": "09:35桃園機場 - 13:05福岡機場"},
          {"time": "14:00", "event": "飯店辦理 Check In", "sub": "seven x seven 糸島"},
          {"time": "16:00", "event": "糸島海鮮堂 二見ヶ浦本店", "sub": "享用超豐富海鮮"},
          {"time": "17:00", "event": "二見ヶ浦海岸夫婦岩", "sub": "絕美夕陽地標"}
        ]
      },
      {
        "day_index": 1, "date": "9/26 (六)", "title": "Day 2 · 未排定行程",
        "hotel_name": "博多祇園櫛田神社前西鐵克魯姆酒店 (3間房共 NT\$24,483)", "items": []
      },
      {
        "day_index": 2, "date": "9/27 (日)", "title": "Day 3 · 未排定行程",
        "hotel_name": "博多祇園櫛田神社前西鐵克魯姆酒店 (連續入住第2晚)", "items": []
      },
      {
        "day_index": 3, "date": "9/28 (一)", "title": "Day 4 · 返航回家",
        "hotel_name": "今日退房 (西鐵克魯姆酒店 11:00前)",
        "items": [
          {"time": "14:15", "event": "星宇航空 JX841", "sub": "14:15福岡機場 - 15:45桃園機場"}
        ]
      }
    ];
    for (var plan in initialPlan) {
      await FirebaseFirestore.instance.collection('travel_plan').add(plan);
    }
  }
}
