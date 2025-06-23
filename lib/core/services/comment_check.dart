import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentCheckResult {
  final String prediction;
  final double confidence;
  final String originalComment;

  CommentCheckResult({
    required this.prediction,
    required this.confidence,
    required this.originalComment,
  });

  factory CommentCheckResult.fromJson(Map<String, dynamic> json) {
    return CommentCheckResult(
      prediction: json['prediction'],
      confidence: (json['confidence'] as num).toDouble(),
      originalComment: json['comment'],
    );
  }
}

class CommentCheckerService {
  static const String baseUrl = 'http://192.168.1.110:5000'; // Thay IP nếu cần

  static Future<CommentCheckResult?> checkComment(String comment) async {
    final url = Uri.parse('$baseUrl/predict');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'comment': comment}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CommentCheckResult.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi khi gọi API toxic comment: $e');
      return null;
    }
  }
}
