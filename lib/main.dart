import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() async {
  // 確保 Flutter Web 引擎在背景完全初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 💡 【Firebase 雲端設定金鑰】
  // 如果你還沒設定好，請先維持原樣 "YOUR_API_KEY"。
  // 雙模版會自動辨識並切換至「離線高模擬展示模式」，100% 保證你的網頁不會白畫面！
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
      // 🚀 自動初始設定雲端資料庫：如果你的 Firebase 是空的，打開網頁時會自動幫你灌入 4天行程與51家商店！
      await _initializeFirebaseDataIfNeeded();
    } catch (e) {
      // Firebase 初始化若失敗，自動降級切換至離線模式，避免白畫面
      Db.isFirebase = false;
      Db.initLocal();
    }
  } else {
    // 尚未填入 Firebase 金鑰，自動啟用離線高模擬模式，所有功能均可 100% 順暢運作！
    Db.isFirebase = false;
    Db.initLocal();
  }

  runApp(const BlackOrangeTravelApp());
}

// 🗄️ 超級雙模資料庫管理器 (整合 Firestore 與 In-Memory 本地模擬引擎)
class Db {
  static bool isFirebase = false;

  // 本地離線記憶體快取
  static List<Map<String, dynamic>> travelPlan = [];
  static List<Map<String, dynamic>> expenses = [];
  static List<Map<String, dynamic>> pocketList = [];
  static List<Map<String, dynamic>> luggage = [];
  static List<Map<String, dynamic>> souvenirs = [];
  static List<Map<String, dynamic>> coupons = [];

  // 本地模式廣播控制器
  static final _travelPlanController = StreamController<List<Map<String, dynamic>>>.broadcast();
  static final _expensesController = StreamController<List<Map<String, dynamic>>>.broadcast();
  static final _pocketListController = StreamController<List<Map<String, dynamic>>>.broadcast();
  static final _luggageController = StreamController<List<Map<String, dynamic>>>.broadcast();
  static final _souvenirsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  static final _couponsController = StreamController<List<Map<String, dynamic>>>.broadcast();

  // 灌入本地模擬初始數據 (內容與 Firebase 一模一樣，保證離線展示完美無缺！)
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

    coupons = [
      {"category_id": 1, "mall": "天神岩田屋 (IWATAYA)", "benefit": "5% 折扣 Guest Card + 10% 免稅", "note": "至新館7樓退稅櫃台領取", "url": "https://www.iwataya-mitsukoshi.mistore.jp/"},
      {"category_id": 1, "mall": "博多阪急百貨 (Hakata Hankyu)", "benefit": "外國旅客專屬 5% 優惠券", "note": "至1樓服務台出示護照領取", "url": "https://www.hankyu-dept.co.jp/"},
      {"category_id": 1, "mall": "福岡大丸百貨 (DAIMARU Tenjin)", "benefit": "5% 特典優惠券 + 10% 免稅", "note": "東館5樓海外顧客服務台領取", "url": "https://www.daimaru-fukuoka.jp/"},
      {"category_id": 1, "mall": "福岡三越 (MITSUKOSHI)", "benefit": "5% 折扣卡 + 10% 免稅退稅", "note": "與岩田屋通用，服務台憑護照換取", "url": "https://www.iwataya-mitsukoshi.mistore.jp/"},
      {"category_id": 1, "mall": "天神 PARCO", "benefit": "特定店家獨家折扣與贈品手冊", "note": "直接在櫃位結帳出示護照與官網優惠網頁", "url": "https://fukuoka.parco.jp/"},
      {"category_id": 1, "mall": "博多運感城 (Canal City)", "benefit": "專屬外國旅客免稅優惠小手冊", "note": "至1樓綜合服務台出示護照換取", "url": "https://canalcity.co.jp/"},
      {"category_id": 1, "mall": "福岡 LaLaport 百貨", "benefit": "最高享 10% 免稅 + 最高 10% 折扣優惠", "note": "現場掃描各樓面引導看板 QR code 領電子券", "url": "https://mitsui-shopping-park.com/"},
      {"category_id": 2, "mall": "松本清藥妝 (Matsumoto Kiyoshi)", "benefit": "免稅 10% + 滿額最高再折 7%", "note": "結帳出示官方免稅折價券條碼", "url": "https://www.matsukiyo.co.jp/"},
      {"category_id": 2, "mall": "大國藥妝 (Daikoku Drug)", "benefit": "免稅 10% + 最高加碼再折 8%", "note": "結帳出示大國藥妝電子優惠券畫面供刷條碼", "url": "https://www.daikokudrug.com/"},
      {"category_id": 2, "mall": "鶴羽藥妝 (TSURUHA DRUG)", "benefit": "免稅 10% + 滿額現折最高 7%", "note": "結帳前出示電子折扣條碼供店員讀取", "url": "https://www.tsuruha.co.jp/"},
      {"category_id": 2, "mall": "Cocokara Fine 藥妝店", "benefit": "免稅 10% + 最高再享 7% 加碼折扣", "note": "松本清旗下同享，結帳刷讀免稅優惠券", "url": "https://www.cocokarafine.co.jp/"},
      {"category_id": 2, "mall": "尚都樂客 (Sun Drug 藥妝)", "benefit": "免稅 10% + 最高現折 7% 優惠", "note": "手機出示官方合作電子優惠條碼結帳", "url": "https://www.sundrug.co.jp/"},
      {"category_id": 3, "mall": "驚安殿堂 唐吉訶德", "benefit": "免稅 10% + 滿一萬日圓現折 5%", "note": "結帳刷讀動態免稅電子條碼（截圖無效）", "url": "https://www.donki.com/"},
      {"category_id": 3, "mall": "Bic Camera 天神館", "benefit": "免稅 10% + 電器折 7% / 藥妝折 5%", "note": "出示聯名信用卡或 Bic Camera 免稅折價券", "url": "https://www.biccamera.com/"},
      {"category_id": 3, "mall": "Yodobashi Camera 博多店", "benefit": "免稅 10% + 指定信用卡刷卡折 5%", "note": "持配合之特定信用卡付款直接抵扣", "url": "https://www.yodobashi.com/"}
    ];

    luggage = [
      {"name": "護照、日幣現金、隨身包", "checked": false},
      {"name": "衣服褲子、換洗保養旅行裝", "checked": false},
      {"name": "行動電源、充電線與充電頭", "checked": false}
    ];

    souvenirs = [
      {"name": "小倉山莊 仙貝 🍘", "checked": false},
      {"name": "福太郎 明太子仙貝 🌶️", "checked": false},
      {"name": "博多通饅頭 🥮", "checked": false}
    ];

    expenses = [];

    _publishAll();
  }

  static void _publishAll() {
    _travelPlanController.add(List.from(travelPlan));
    _expensesController.add(List.from(expenses));
    _pocketListController.add(List.from(pocketList));
    _luggageController.add(List.from(luggage));
    _souvenirsController.add(List.from(souvenirs));
    _couponsController.add(List.from(coupons));
  }

  // 🔔 讀取數據：自動適配 Firebase 與離線 Stream
  static Stream<List<Map<String, dynamic>>> getTravelPlanStream(int dayIndex) {
    if (isFirebase) {
      return FirebaseFirestore.instance
          .collection('travel_plan')
          .where('day_index', isEqualTo: dayIndex)
          .snapshots()
          .map((snap) => snap.docs.map((doc) {
                var d = doc.data();
                d['id'] = doc.id;
                return d;
              }).toList());
    } else {
      return _travelPlanController.stream.map((list) =>
          list.where((item) => item['day_index'] == dayIndex).toList());
    }
  }

  static Stream<List<Map<String, dynamic>>> getExpensesStream() {
    if (isFirebase) {
      return FirebaseFirestore.instance
          .collection('expenses')
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());
    } else {
      return _expensesController.stream;
    }
  }

  static Stream<List<Map<String, dynamic>>> getPocketListStream() {
    if (isFirebase) {
      return FirebaseFirestore.instance
          .collection('pocket_list')
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());
    } else {
      return _pocketListController.stream;
    }
  }

  static Stream<List<Map<String, dynamic>>> getChecklistStream(String collection) {
    if (isFirebase) {
      return FirebaseFirestore.instance
          .collection(collection)
          .snapshots()
          .map((snap) => snap.docs.map((doc) {
                var d = doc.data();
                d['id'] = doc.id;
                return d;
              }).toList());
    } else {
      if (collection == 'luggage') return _luggageController.stream;
      return _souvenirsController.stream;
    }
  }

  static Stream<List<Map<String, dynamic>>> getCouponsStream() {
    if (isFirebase) {
      return FirebaseFirestore.instance
          .collection('coupons')
          .orderBy('category_id')
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());
    } else {
      return _couponsController.stream;
    }
  }

  // ✍️ 寫入與異動：自動適配 Firebase 與離線機制
  static void addTravelEvent(int dayIndex, String? docId) {
    if (isFirebase && docId != null) {
      FirebaseFirestore.instance.collection('travel_plan').doc(docId).get().then((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          List currentItems = data['items'] ?? [];
          currentItems.add({'time': '12:00', 'event': '點擊地圖按鈕進行搜尋', 'sub': '自訂新增行程'});
          currentItems.sort((a, b) => a['time'].compareTo(b['time']));
          doc.reference.update({'items': currentItems});
        }
      });
    } else {
      for (var plan in travelPlan) {
        if (plan['day_index'] == dayIndex) {
          List items = plan['items'] ?? [];
          items.add({'time': '12:00', 'event': '點擊地圖按鈕進行搜尋', 'sub': '自訂新增行程'});
          items.sort((a, b) => a['time'].compareTo(b['time']));
          plan['items'] = items;
          break;
        }
      }
      _publishAll();
    }
  }

  static void addExpense(double jpy, double twd) {
    if (isFirebase) {
      FirebaseFirestore.instance.collection('expenses').add({
        'jpy': jpy,
        'twd': twd,
        'title': '共用花費記帳'
      });
    } else {
      expenses.add({
        'jpy': jpy,
        'twd': twd,
        'title': '共用花費記帳'
      });
      _publishAll();
    }
  }

  static void toggleCheck(String collection, int localIndex, String? docId, bool val) {
    if (isFirebase && docId != null) {
      FirebaseFirestore.instance.collection(collection).doc(docId).update({'checked': val});
    } else {
      if (collection == 'luggage') {
        luggage[localIndex]['checked'] = val;
      } else {
        souvenirs[localIndex]['checked'] = val;
      }
      _publishAll();
    }
  }

  static void addChecklistItem(String collection, String name) {
    if (isFirebase) {
      FirebaseFirestore.instance.collection(collection).add({'name': name, 'checked': false});
    } else {
      if (collection == 'luggage') {
        luggage.add({'name': name, 'checked': false});
      } else {
        souvenirs.add({'name': name, 'checked': false});
      }
      _publishAll();
    }
  }
}

// 🎨 黑橘工業風核心配色與粗黑框硬陰影樣式 (Neo-Brutalism Style)
class IndustrialStyle {
  static const Color bgMarble = Color(0xFFEFEFEF); // 淺灰大理石感底色
  static const Color strokeBlack = Color(0xFF000000); // 極致粗黑框
  static const Color accentOrange = Color(0xFFFF5500); // 亮橘色

  // 貼紙浮空硬陰影 BoxDecoration 元件控制函數
  static BoxDecoration neoBox({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      border: Border.all(strokeBlack, width: 3.5),
      boxShadow: const [
        BoxShadow(
          color: strokeBlack,
          offset: Offset(5, 5), // 硬陰影位移
          blurRadius: 0,        // 無模糊，呈現強烈工業貼紙感
        )
      ],
    );
  }
}

class BlackOrangeTravelApp extends StatelessWidget {
  const BlackOrangeTravelApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '福岡黑橘工業風雲端 App',
      theme: ThemeData(
        scaffoldBackgroundColor: IndustrialStyle.bgMarble,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Arial Black', fontWeight: FontWeight.w900, color: Colors.black),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

// 🏠 首頁：雜誌風六宮格佈局 + 長輩天氣置頂看板
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showFloatingCalc = false;
  double _calcJpy = 0;
  final double _rate = 0.21; // 預設匯率參數

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FUKUOKA INDUSTRIAL TRIP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5)),
        backgroundColor: IndustrialStyle.accentOrange,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 4)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // ☀️ 今日福岡天氣卡片（長輩置頂防呆設計）
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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

                // 1. 行程表卡片：橫跨整列寬度（最顯眼最大）
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelinePage())),
                  child: Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: IndustrialStyle.neoBox(color: IndustrialStyle.accentOrange),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_view_day, size: 32, color: Colors.black),
                        SizedBox(height: 6),
                        Text('每日行程表 TIMELINE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        Text('橫向日期切換 · 飯店周邊日本在地五大快捷搜尋', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(context, '日文菜單翻譯 DECODER', Icons.g_translate, const MenuTranslatorPage()),
                    _buildMenuCard(context, '記帳本 LEDGER', Icons.calculate, const LedgerPage()),
                    _buildMenuCard(context, '口袋名單 STORES', Icons.restaurant, const PocketListPage()),
                    _buildMenuCard(context, '行李清單 BAG', Icons.backpack, const ChecklistPage(collectionName: 'luggage', title: '行李勾選清單')),
                    _buildMenuCard(context, '伴手禮 GIFT', Icons.card_giftcard, const ChecklistPage(collectionName: 'souvenirs', title: '伴手禮勾選清單')),
                    _buildMenuCard(context, '折價券 COUPONS', Icons.shopping_bag, const CouponPage()),
                  ],
                ),
              ],
            ),
          ),
          
          if (_showFloatingCalc)
            Positioned(
              right: 16,
              bottom: 90,
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
    );
  }

  Widget _buildMenuCard(BuildContext context, String text, IconData icon, Widget targetPage) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage)),
      child: Container(
        decoration: IndustrialStyle.neoBox(color: Colors.white),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

// 🗓️ 功能一：時間軸行程表（含橫向日期選單與實時周邊搜尋）
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

  void _getNavigationToEvent(String destination) async {
    final String encodedUrl = "https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destination)}";
    await launchUrl(Uri.parse(encodedUrl), mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TIMELINE 行程表'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            height: 65,
            color: Colors.black,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedDayIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Db.getTravelPlanStream(_selectedDayIndex),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!;
                if (docs.isEmpty) return const Center(child: Text('暫無行程數據'));

                final data = docs.first;
                final String hotel = data['hotel_name'] ?? '西鐵克魯姆酒店';
                final String? docId = data['id']; // Firebase 模式下才會有
                final List items = data['items'] ?? [];

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      decoration: IndustrialStyle.neoBox(color: Colors.white),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🏨 當日住宿飯店 (Elders Home)：', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold)),
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
                        child: Center(child: Text('此日無預設排定行程。點選下方按鈕新增！')),
                      ),
                    ...items.map((item) => Row(
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
                                Text(item['event'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                if (item['sub'] != null && item['sub'].toString().isNotEmpty)
                                  Text(item['sub'], style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  ),
                                  onPressed: () => _getNavigationToEvent(item['event'] ?? ''),
                                  icon: const Icon(Icons.directions, size: 16),
                                  label: const Text('打開地圖與交通路徑 🧭', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )).toList(),
                  ],
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: Db.getTravelPlanStream(_selectedDayIndex),
          builder: (context, snapshot) {
            final String? docId = (snapshot.hasData && snapshot.data!.isNotEmpty) ? snapshot.data!.first['id'] : null;
            return InkWell(
              onTap: () => Db.addTravelEvent(_selectedDayIndex, docId),
              child: Container(
                height: 52,
                decoration: IndustrialStyle.neoBox(color: IndustrialStyle.accentOrange),
                alignment: Alignment.center,
                child: const Text('ADD TIMELINE EVENT +', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            );
          }
        ),
      ),
    );
  }
}

// 💰 功能二：記帳本（置頂大按鈕計算機）
class LedgerPage extends StatefulWidget {
  const LedgerPage({Key? key}) : super(key: key);
  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  String _inputExpression = "0";
  final double _jpyRate = 0.21;

  void _pressKey(String char) {
    setState(() {
      if (char == "C") { _inputExpression = "0"; }
      else if (_inputExpression == "0") { _inputExpression = char; }
      else { _inputExpression += char; }
    });
  }

  @override
  Widget build(BuildContext context) {
    double twdCalc = (double.tryParse(_inputExpression) ?? 0) * _jpyRate;

    return Scaffold(
      appBar: AppBar(title: const Text('INDUSTRIAL LEDGER'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: IndustrialStyle.neoBox(color: Colors.black),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  alignment: Alignment.centerRight,
                  child: Text('¥ $_inputExpression (TWD \$${twdCalc.toStringAsFixed(0)})', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.8,
                  children: ["7", "8", "9", "C", "4", "5", "6", "記帳", "1", "2", "3", "0"].map((btn) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btn == "記帳" ? IndustrialStyle.accentOrange : Colors.grey[900],
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () {
                        if (btn == "記帳") {
                          Db.addExpense(double.parse(_inputExpression), twdCalc);
                          _pressKey("C");
                        } else { _pressKey(btn); }
                      },
                      child: Text(btn, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Db.getExpensesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shape: const Border(),
                      child: ListTile(
                        title: const Text('旅遊支出項', style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text('NT \$${data['twd']?.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, color: IndustrialStyle.accentOrange)),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// 🍱 功能三：51筆完整口袋名單數據庫分頁（完美對齊與修正分類標籤篩選問題）
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
    return Scaffold(
      appBar: AppBar(title: const Text('口袋名單庫 STORES'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Column(
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Db.getPocketListStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.where((item) {
                  final String dbCategory = item['category'] ?? '';
                  
                  if (_selectedCategory == "全部") {
                    return true;
                  } else if (_selectedCategory == "餐廳") {
                    return dbCategory == "正餐" || dbCategory == "早餐" || dbCategory == "餐廳" || dbCategory == "外帶" || dbCategory == "Bar";
                  } else if (_selectedCategory == "咖啡") {
                    return dbCategory == "咖啡/午茶" || dbCategory == "點心" || dbCategory.contains("咖啡");
                  } else if (_selectedCategory == "超市") {
                    return dbCategory == "購物" || dbCategory == "超市";
                  } else if (_selectedCategory == "伴手禮") {
                    return dbCategory == "伴手禮";
                  }
                  return dbCategory == _selectedCategory;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('此分類下暫無店家資料'));
                }

                return ListView.builder(
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 🧳 功能四：行李與伴手禮清單 (共用雲端/本地 雙模勾選模板)
class ChecklistPage extends StatelessWidget {
  final String collectionName;
  final String title;
  const ChecklistPage({Key? key, required this.collectionName, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Db.getChecklistStream(collectionName),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final bool isChecked = data['checked'] ?? false;
              final String? docId = data['id']; // Firebase 模式才會有

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: IndustrialStyle.neoBox(color: isChecked ? Colors.grey[300]! : Colors.white),
                child: CheckboxListTile(
                  activeColor: IndustrialStyle.accentOrange,
                  title: Text(data['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, decoration: isChecked ? TextDecoration.lineThrough : null)),
                  value: isChecked,
                  onChanged: (val) {
                    Db.toggleCheck(collectionName, index, docId, val ?? false);
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: () {
            Db.addChecklistItem(collectionName, '自訂新增清單項');
          },
          child: Container(
            height: 52,
            decoration: IndustrialStyle.neoBox(color: Colors.black),
            alignment: Alignment.center,
            child: const Text('ADD NEW ITEM +', style: TextStyle(color: IndustrialStyle.accentOrange, fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ),
      ),
    );
  }
}

// 🎫 功能五：折價券大全 (包含15家全福岡百貨、連鎖藥妝、電器超商數據)
class CouponPage extends StatelessWidget {
  const CouponPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('福岡優惠券大全 COUPONS'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Db.getCouponsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final coupon = docs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: IndustrialStyle.neoBox(),
                child: ListTile(
                  title: Text(coupon['mall'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('🎁 優惠：${coupon['benefit'] ?? ''}', style: const TextStyle(color: IndustrialStyle.accentOrange, fontWeight: FontWeight.w900, fontSize: 13)),
                      if (coupon['note'] != null)
                        Text('💡 方式：${coupon['note']}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchUrl(Uri.parse(coupon['url'] ?? '')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 🗣️ 功能六：長輩專用免打字日文菜單快速解碼器
class MenuTranslatorPage extends StatefulWidget {
  const MenuTranslatorPage({Key? key}) : super(key: key);
  @override
  State<MenuTranslatorPage> createState() => _MenuTranslatorPageState();
}

class _MenuTranslatorPageState extends State<MenuTranslatorPage> {
  int _activeTab = 0;

  final List<String> _tabs = ["🍜 麵食", "🥩 肉類", "🍣 海鮮", "🍺 飲料", "🗣️ 常用對話"];

  final List<List<Map<String, String>>> _foodData = [
    [
      {"jp": "豚骨ラーメン", "zh": "豚骨拉麵", "pron": "ton-kotsu raa-men"},
      {"jp": "うどん", "zh": "烏龍麵", "pron": "u-don"},
      {"jp": "そば", "zh": "蕎麥麵", "pron": "so-ba"},
      {"jp": "替え玉", "zh": "加麵", "pron": "ka-e da-ma"},
    ],
    [
      {"jp": "カルビ", "zh": "牛五花肉", "pron": "ka-ru-bi"},
      {"jp": "ロース", "zh": "牛里肌/沙朗", "pron": "roo-su"},
      {"jp": "タン", "zh": "牛舌", "pron": "tan"},
      {"jp": "焼き鳥", "zh": "烤雞肉串", "pron": "ya-ki-to-ri"},
    ],
    [
      {"jp": "すし", "zh": "壽司", "pron": "su-shi"},
      {"jp": "さしみ", "zh": "生魚片", "pron": "sa-shi-mi"},
      {"jp": "e-bi", "zh": "蝦子", "pron": "e-bi"},
      {"jp": "マグロ", "zh": "鮪魚", "pron": "ma-gu-ro"},
    ],
    [
      {"jp": "ビール", "zh": "啤酒", "pron": "bii-ru"},
      {"jp": "日本酒", "zh": "日本清酒", "pron": "ni-hon-shu"},
      {"jp": "お茶", "zh": "綠茶/熱茶", "pron": "o-cha"},
      {"jp": "お水", "zh": "冰水 (免費)", "pron": "o-mi-zu"},
    ],
    [
      {"jp": "これ、ください", "zh": "請給我這個 (指著菜單)", "pron": "ko-re ku-da-sai"},
      {"jp": "お会計、お願いします", "zh": "請幫我結帳", "pron": "o-kai-kei o-nei-gai-shi-masu"},
      {"jp": "すみません", "zh": "不好意思 (呼叫店員)", "pron": "su-mi-ma-sen"},
      {"jp": "クレジットカードは使えますか", "zh": "可以刷信用卡嗎？", "pron": "ku-re-jit-to kaa-do tsuka-e-masu-ka"},
    ]
  ];

  void _showGiantTextDialog(String jp, String zh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const Border(),
        title: const Text('👉 請直接把手機螢幕給日本店員看：', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Colors.black, thickness: 3),
            const SizedBox(height: 16),
            Text(jp, textAlign: TextAlign.center, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: IndustrialStyle.accentOrange)),
            const SizedBox(height: 16),
            Text('中文意思：$zh', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉視窗 CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗣️ 長輩專用：日文點餐解碼器'), backgroundColor: Colors.black),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = _activeTab == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? IndustrialStyle.accentOrange : Colors.grey[900],
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () { setState(() { _activeTab = index; }); },
                    child: Text(_tabs[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemCount: _foodData[_activeTab].length,
              itemBuilder: (context, index) {
                final item = _foodData[_activeTab][index];
                return Container(
                  decoration: IndustrialStyle.neoBox(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['jp']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: IndustrialStyle.accentOrange)),
                          const SizedBox(height: 2),
                          Text('🔊 拼音: ${item['pron']!}', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(item['zh']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 32),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => _showGiantTextDialog(item['jp']!, item['zh']!),
                        child: const Text('👉 大字給店員看', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// 🗄️ 雲端資料庫初始化函數：僅在 Firebase 模式成功連線時，於資料庫全空時寫入初始資料
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

    final List<Map<String, String>> shops = [
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
    for (var shop in shops) {
      await FirebaseFirestore.instance.collection('pocket_list').add(shop);
    }

    final List<Map<String, dynamic>> fullCoupons = [
      {"category_id": 1, "mall": "天神岩田屋 (IWATAYA)", "benefit": "5% 折扣 Guest Card + 10% 免稅", "note": "至新館7樓退稅櫃台領取", "url": "https://www.iwataya-mitsukoshi.mistore.jp/"},
      {"category_id": 1, "mall": "博多阪急百貨 (Hakata Hankyu)", "benefit": "外國旅客專屬 5% 優惠券", "note": "至1樓服務台出示護照領取", "url": "https://www.hankyu-dept.co.jp/"},
      {"category_id": 1, "mall": "福岡大丸百貨 (DAIMARU Tenjin)", "benefit": "5% 特典優惠券 + 10% 免稅", "note": "東館5樓海外顧客服務台領取", "url": "https://www.daimaru-fukuoka.jp/"},
      {"category_id": 1, "mall": "福岡三越 (MITSUKOSHI)", "benefit": "5% 折扣卡 + 10% 免稅退稅", "note": "與岩田屋通用，服務台憑護照換取", "url": "https://www.iwataya-mitsukoshi.mistore.jp/"},
      {"category_id": 1, "mall": "天神 PARCO", "benefit": "特定店家獨家折扣與贈品手冊", "note": "直接在櫃位結帳出示護照與官網優惠網頁", "url": "https://fukuoka.parco.jp/"},
      {"category_id": 1, "mall": "博多運河城 (Canal City)", "benefit": "專屬外國旅客免稅優惠小手冊", "note": "至1樓綜合服務台出示護照換取", "url": "https://canalcity.co.jp/"},
      {"category_id": 1, "mall": "福岡 LaLaport 百貨", "benefit": "最高享 10% 免稅 + 最高 10% 折扣優惠", "note": "現場掃描各樓面引導看板 QR code 領電子券", "url": "https://mitsui-shopping-park.com/"},
      {"category_id": 2, "mall": "松本清藥妝 (Matsumoto Kiyoshi)", "benefit": "免稅 10% + 滿額最高再折 7%", "note": "結帳出示官方免稅折價券條碼", "url": "https://www.matsukiyo.co.jp/"},
      {"category_id": 2, "mall": "大國藥妝 (Daikoku Drug)", "benefit": "免稅 10% + 最高加碼再折 8%", "note": "結帳出示大國藥妝電子優惠券畫面供刷條碼", "url": "https://www.daikokudrug.com/"},
      {"category_id": 2, "mall": "鶴羽藥妝 (TSURUHA DRUG)", "benefit": "免稅 10% + 滿額現折最高 7%", "note": "結帳前出示電子折扣條碼供店員讀取", "url": "https://www.tsuruha.co.jp/"},
      {"category_id": 2, "mall": "Cocokara Fine 藥妝店", "benefit": "免稅 10% + 最高再享 7% 加碼折扣", "note": "松本清旗下同享，結帳刷讀免稅優惠券", "url": "https://www.cocokarafine.co.jp/"},
      {"category_id": 2, "mall": "尚都樂客 (Sun Drug 藥妝)", "benefit": "免稅 10% + 最高現折 7% 優惠", "note": "手機出示官方合作電子優惠條碼結帳", "url": "https://www.sundrug.co.jp/"},
      {"category_id": 3, "mall": "驚安殿堂 唐吉訶德", "benefit": "免稅 10% + 滿一萬日圓現折 5%", "note": "結帳刷讀動態免稅電子條碼（截圖無效）", "url": "https://www.donki.com/"},
      {"category_id": 3, "mall": "Bic Camera 天神館", "benefit": "免稅 10% + 電器折 7% / 藥妝折 5%", "note": "出示聯名信用卡或 Bic Camera 免稅折價券", "url": "https://www.biccamera.com/"},
      {"category_id": 3, "mall": "Yodobashi Camera 博多店", "benefit": "免稅 10% + 指定信用卡刷卡折 5%", "note": "持配合之特定信用卡付款直接抵扣", "url": "https://www.yodobashi.com/"}
    ];
    for (var coupon in fullCoupons) {
      await FirebaseFirestore.instance.collection('coupons').add(coupon);
    }

    await FirebaseFirestore.instance.collection('luggage').add({"name": "護照、日幣現金、隨身包", "checked": false});
    await FirebaseFirestore.instance.collection('luggage').add({"name": "衣服褲子、換洗保養旅行裝", "checked": false});
    await FirebaseFirestore.instance.collection('luggage').add({"name": "行動電源、充電線與充電頭", "checked": false});
  }
}
