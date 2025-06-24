import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class GeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GenerativeModel _model;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!dotenv.isInitialized) {
      await dotenv.load();
    }
    final apiKey = dotenv.env['GEMINI_AI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Không tìm thấy API key cho Gemini AI');
    }
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
    _initialized = true;
  }

  /// Lấy danh sách địa điểm từ 'destinations' với tất cả các trường quan trọng
  Future<String> getDestinationsInfo() async {
    final snapshot = await _firestore.collection('DESTINATION').get();
    if (snapshot.docs.isEmpty) return "Không có địa điểm nào.";
    final buffer = StringBuffer();
    buffer.writeln("Danh sách địa điểm chi tiết:");
    for (var doc in snapshot.docs) {
      final data = doc.data();
      buffer.writeln("- ID: " + (data['destinationId'] ?? ''));
      buffer.writeln("  Tên: " + (data['destinationName'] ?? ''));
      buffer.writeln("  Tỉnh/Thành: " + (data['province'] ?? ''));
      buffer.writeln("  Địa chỉ cụ thể: " + (data['specificAddress'] ?? ''));
      buffer.writeln("  Vĩ độ: " + (data['latitude']?.toString() ?? ''));
      buffer.writeln("  Kinh độ: " + (data['longitude']?.toString() ?? ''));
      buffer.writeln("  Mô tả (VI): " + (data['descriptionViet'] ?? ''));
      buffer.writeln("  Mô tả (EN): " + (data['descriptionEng'] ?? ''));
      buffer.writeln("  Ảnh: " + ((data['photo'] as List?)?.join(', ') ?? ''));
      buffer
          .writeln("  Video: " + ((data['video'] as List?)?.join(', ') ?? ''));
      buffer.writeln("  Ngày tạo: " + (data['createdDate'] ?? ''));
      buffer.writeln("  Số lượt yêu thích: " +
          (data['favouriteTimes']?.toString() ?? '0'));
      buffer.writeln(
          "  Danh mục: " + ((data['categories'] as List?)?.join(', ') ?? ''));
      buffer.writeln("  Đánh giá: " + (data['rating']?.toString() ?? '0'));
      buffer.writeln("  Số lượt đánh giá: " +
          (data['userRatingsTotal']?.toString() ?? '0'));
      buffer.writeln("");
    }
    return buffer.toString();
  }

  /// Hỏi Gemini AI với prompt chỉ trả lời liên quan đến các địa điểm và features
  Future<String> askGemini(String userQuestion) async {
    await initialize();
    final destinationsInfo = await getDestinationsInfo();
    final prompt =
        "Dưới đây là danh sách các địa điểm và thông tin chi tiết. Hãy trả lời các câu hỏi"
        "của người dùng dựa trên dữ liệu này.\n"
        "$destinationsInfo\n"
        "Dữ liệu địa điểm đã được cung cấp đầy đủ các trường. Khi người dùng hỏi về: \n"
        "- Địa điểm nổi tiếng: sắp xếp theo số người đánh giá giảm dần. \n"
        "- Địa điểm theo tỉnh: lọc theo trường province. \n"
        "- Địa chỉ cụ thể: trả về specificAddress. \n"
        "- Ảnh: trả về danh sách photo. \n"
        "- Địa điểm theo loại: lọc theo categories, sắp xếp theo số người đánh giá. \n"
        "- Địa điểm tương tự: tìm theo categories[0] của địa điểm đó. \n"
        "- Chi tiết: trả về địa chỉ, mô tả, ảnh, đánh giá, số người đánh giá. \n"
        "Luôn sắp xếp danh sách theo số người đánh giá giảm dần. \n"
        "Người dùng hỏi: $userQuestion";
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    await _firestore.collection('chats').add({
      'userId': _auth.currentUser?.uid,
      'message': response.text,
      'type': 'text',
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return response.text ??
        'Xin lỗi, câu hỏi của bạn có vẻ không liên quan đến ứng dụng du lịch Traveline'
            'của mình. Hãy thử hỏi lại nhé!';
  }

  /// Lấy các địa điểm nổi tiếng nhất (nhiều người đánh giá nhất)
  Future<List<Map<String, dynamic>>> getFamousDestinations(
      {int limit = 10}) async {
    final snapshot = await _firestore
        .collection('DESTINATION')
        .orderBy('userRatingsTotal', descending: true)
        .limit(limit)
        .get();
    await _firestore.collection('chats').add({
      'userId': _auth.currentUser?.uid,
      'message': jsonEncode(snapshot.docs.map((doc) => doc.data()).toList()),
      'type': 'list',
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Lấy các địa điểm theo tỉnh
  Future<List<Map<String, dynamic>>> getDestinationsByProvince(
      String province) async {
    final snapshot = await _firestore
        .collection('DESTINATION')
        .where('province', isEqualTo: province)
        .orderBy('userRatingsTotal', descending: true)
        .get();
    await _firestore.collection('chats').add({
      'userId': _auth.currentUser?.uid,
      'message': jsonEncode(snapshot.docs.map((doc) => doc.data()).toList()),
      'type': 'list',
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Lấy địa chỉ cụ thể của một địa điểm
  Future<String?> getSpecificAddress(String destinationName) async {
    final snapshot = await _firestore
        .collection('DESTINATION')
        .where('destinationName', isEqualTo: destinationName)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first['specificAddress'];
  }

  /// Lấy danh sách ảnh của một địa điểm
  Future<List<String>> getPhotosOfDestination(String destinationName) async {
    final snapshot = await _firestore
        .collection('DESTINATION')
        .where('destinationName', isEqualTo: destinationName)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return [];
    return List<String>.from(snapshot.docs.first['photo'] ?? []);
  }

  /// Lấy các địa điểm theo loại (category)
  Future<List<Map<String, dynamic>>> getDestinationsByCategory(
      String category) async {
    final snapshot = await _firestore
        .collection('DESTINATION')
        .where('categories', arrayContains: category)
        .orderBy('userRatingsTotal', descending: true)
        .get();
    await _firestore.collection('chats').add({
      'userId': _auth.currentUser?.uid,
      'message': jsonEncode(snapshot.docs.map((doc) => doc.data()).toList()),
      'type': 'list',
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Lấy các địa điểm tương tự một địa điểm (cùng category[0])
  Future<List<Map<String, dynamic>>> getSimilarDestinations(
      String destinationName) async {
    final snapshot = await _firestore
        .collection('DESTINATION')
        .where('destinationName', isEqualTo: destinationName)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return [];
    final data = snapshot.docs.first.data();
    final List categories = data['categories'] ?? [];
    if (categories.isEmpty) return [];
    final String mainCategory = categories[0];
    final similarSnapshot = await _firestore
        .collection('DESTINATION')
        .where('categories', arrayContains: mainCategory)
        .orderBy('userRatingsTotal', descending: true)
        .get();
    // Loại bỏ chính nó
    await _firestore.collection('chats').add({
      'userId': _auth.currentUser?.uid,
      'message': jsonEncode(similarSnapshot.docs
          .where((doc) => doc['destinationName'] != destinationName)
          .map((doc) => doc.data())
          .toList()),
      'type': 'list',
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return similarSnapshot.docs
        .where((doc) => doc['destinationName'] != destinationName)
        .map((doc) => doc.data())
        .toList();
  }

  /// Lấy chi tiết một địa điểm
  Future<Map<String, dynamic>?> getDestinationDetail(
      String destinationName) async {
    final snapshot = await _firestore
        .collection('DESTINATION')
        .where('destinationName', isEqualTo: destinationName)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    await _firestore.collection('chats').add({
      'userId': _auth.currentUser?.uid,
      'message': jsonEncode(snapshot.docs.first.data()),
      'type': 'text',
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return snapshot.docs.first.data();
  }

  String? getCategoryFromKeyword(String keyword) {
    keyword = keyword.toLowerCase();
    for (final entry in keywordToCategory.entries) {
      if (keyword.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }
}

final List<Map<String, dynamic>> chatbotServices = [
  {
    "intent": "car_rental",
    "label": "Thuê xe ô tô tự lái",
    "imageUrl": "assets/img/car_home.png",
    "description": "Thuê xe ô tô tự lái",
    "navigate": (BuildContext context) {
      Navigator.pushNamed(context, "/car_rental");
    }
  },
  {
    "intent": "motorbike_rental",
    "label": "Thuê xe máy tự lái",
    "imageUrl": "assets/img/motorbike_home.png",
    "description": "Thuê xe máy tự lái",
    "navigate": (BuildContext context) {
      Navigator.pushNamed(context, "/motorbike_rental");
    }
  },
  {
    "intent": "custom_route",
    "label": "Tạo lộ trình du lịch",
    "imageUrl": "assets/img/travel_home.png",
    "description": "Tạo lộ trình du lịch cho riêng bạn",
    "navigate": (BuildContext context) {
      Navigator.pushNamed(context, "/travel");
    }
  },
  {
    "intent": "restaurant_booking",
    "label": "Đặt bàn nhà hàng",
    "imageUrl": "assets/img/restaurant_home.png",
    "description": "Đặt bàn nhà hàng",
    "navigate": (BuildContext context) {
      Navigator.pushNamed(context, "/restaurant");
    }
  },
  {
    "intent": "hotel_booking",
    "label": "Đặt phòng khách sạn",
    "imageUrl": "assets/img/hotel_home.png",
    "description": "Đặt phòng khách sạn",
    "navigate": (BuildContext context) {
      Navigator.pushNamed(context, "/hotel");
    }
  },
  {
    "intent": "delivery",
    "label": "Đặt chuyển phát nhanh",
    "imageUrl": "assets/img/delivery_home.png",
    "description": "Đặt chuyển phát nhanh",
    "navigate": (BuildContext context) {
      Navigator.pushNamed(context, "/delivery");
    }
  },
  {
    "intent": "find_eatery",
    "label": "Tìm quán ăn ngon",
    "imageUrl": "assets/img/eatery_home.png",
    "description": "Tìm quán ăn ngon",
    "navigate": (BuildContext context) {
      Navigator.pushNamed(context, "/eatery");
    }
  },
  {
    "intent": "bus_ticket",
    "label": "Đặt mua vé xe",
    "imageUrl": "assets/img/bus_home.png",
    "description": "Đặt mua vé xe",
    "navigate": (BuildContext context) {
      Navigator.pushNamed(context, "/bus");
    }
  },
];

Widget buildDestinationList(List<Map<String, dynamic>> destinations) {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: destinations.length,
    itemBuilder: (context, index) {
      final d = destinations[index];
      return ListTile(
        title: Text(d['destinationName']),
        subtitle: Text('${d['province']} - ${d['userRatingsTotal']} đánh giá'),
        onTap: () {
          // Xem chi tiết địa điểm
        },
      );
    },
  );
}

const Map<String, String> keywordToCategory = {
  // Biển
  'biển': 'Biển',
  'vịnh': 'Biển',
  'cù lao': 'Biển',
  'bãi biển': 'Biển',
  'non nước': 'Biển',
  'bãi tắm': 'Biển',
  // Núi
  'núi': 'Núi',
  'đèo': 'Núi',
  'đỉnh': 'Núi',
  'thung lũng': 'Núi',
  'ruộng bậc thang': 'Núi',
  'đồng bằng': 'Núi',
  'đồi': 'Núi',
  // Lịch sử
  'di tích': 'Lịch sử',
  'chùa': 'Lịch sử',
  'đền': 'Lịch sử',
  'cổ': 'Lịch sử',
  'lăng': 'Lịch sử',
  'thành': 'Lịch sử',
  'dinh': 'Lịch sử',
  'cố đô': 'Lịch sử',
  'kinh thành': 'Lịch sử',
  // Văn hóa
  'chợ': 'Văn hóa',
  'văn hóa': 'Văn hóa',
  'bảo tàng': 'Văn hóa',
  'làng': 'Văn hóa',
  'làng nghề': 'Văn hóa',
  'phố cổ': 'Văn hóa',
  // Thiên nhiên
  'sông': 'Thiên nhiên',
  'suối': 'Thiên nhiên',
  'thác': 'Thiên nhiên',
  'rừng': 'Thiên nhiên',
  'hang': 'Thiên nhiên',
  'hồ': 'Thiên nhiên',
  'vườn': 'Thiên nhiên',
  'vườn quốc gia': 'Thiên nhiên',
  'khu bảo tồn': 'Thiên nhiên',
  'sở thú': 'Thiên nhiên',
  // Giải trí
  'phố': 'Giải trí',
  'phố đi bộ': 'Giải trí',
  'chơi': 'Giải trí',
  'vui chơi': 'Giải trí',
  'khu vui chơi': 'Giải trí',
  'công viên': 'Giải trí',
  'đầm sen': 'Giải trí',
  'suối tiên': 'Giải trí',
  'hills': 'Giải trí',
  // Công trình
  'cầu': 'Công trình',
  'tòa nhà': 'Công trình',
  'landmark': 'Công trình',
  'bitexco': 'Công trình',
};
