import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  /// Lấy danh sách địa điểm từ 'destinations' với tên, mô tả, số lượt thích
  Future<String> getDestinationsInfo() async {
    final snapshot = await _firestore.collection('DESTINATION').get();
    if (snapshot.docs.isEmpty) return "Không có địa điểm nào.";
    final buffer = StringBuffer();
    buffer.writeln("Danh sách địa điểm:");
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final name = data['destinationName'] ?? 'Không rõ tên';
      final desc = data['descriptionViet'] ?? data['descriptionEng'] ?? '';
      final likes = data['favouriteTimes'] ?? 0;
      buffer.writeln("- Tên: $name, Mô tả: $desc, Lượt thích: $likes");
    }
    return buffer.toString();
  }

  /// Hỏi Gemini AI với prompt chỉ trả lời liên quan đến các địa điểm và features
  Future<String> askGemini(String userQuestion) async {
    await initialize();
    final destinationsInfo = await getDestinationsInfo();
    final prompt =
        "Dưới đây là danh sách các địa điểm và thông tin chi tiết. Hãy trả lời các câu hỏi của người dùng dựa trên dữ liệu này.\n"
        "$destinationsInfo\n"
        "Người dùng hỏi: $userQuestion";
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? 'Xin lỗi, tôi không thể trả lời ngay lúc này.';
  }
} 