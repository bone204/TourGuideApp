import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tourguideapp/core/services/comment_check.dart';

class FeedbackViewModel extends ChangeNotifier {
  int _rating = 0;
  String _comment = '';
  List<File> _images = [];
  List<File> _videos = [];
  bool _isLoading = false;
  String _error = '';

  int get rating => _rating;
  String get comment => _comment;
  List<File> get images => _images;
  List<File> get videos => _videos;
  bool get isLoading => _isLoading;
  String get error => _error;

  void setRating(int value) {
    _rating = value;
    notifyListeners();
  }

  void setComment(String value) {
    _comment = value;
    notifyListeners();
  }

  Future<void> addImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _images.add(File(image.path));
      notifyListeners();
    }
  }

  Future<void> addVideo() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _videos.add(File(video.path));
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  void removeVideo(int index) {
    _videos.removeAt(index);
    notifyListeners();
  }

  Future<String?> _validateComment(String comment) async {
    final result = await CommentCheckerService.checkComment(comment);
    if (result == null) return 'Lỗi khi kiểm tra nội dung đánh giá';

    final prediction = result.prediction;
    final confidence = result.confidence;

    if (prediction == 'toxic' && confidence >= 0.9) {
      return 'Comment có nội dung độc hại. Vui lòng sửa lại.';
    }

    if (prediction == 'non_toxic' && confidence >= 0.9) {
      return 'Comment bị hệ thống chặn do độ tin cậy quá cao. Hãy sửa lại.';
    }

    return null;
  }

  Future<List<String>> _uploadFiles(List<File> files, String folder) async {
    List<String> urls = [];
    for (File file in files) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<bool> submitFeedback({
    required String userId,
    String? travelRouteId,
    String? destinationId,
    String? licensePlate,
    String? cooperationId,
  }) async {
    if (_rating == 0) {
      _error = 'Vui lòng chọn số sao đánh giá';
      notifyListeners();
      return false;
    }

    if (_comment.trim().isEmpty) {
      _error = 'Vui lòng nhập nội dung đánh giá';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final validationMessage = await _validateComment(_comment);
      if (validationMessage != null) {
        _error = validationMessage;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Upload ảnh & video
      final photoUrls = await _uploadFiles(_images, 'feedback_photos');
      final videoUrls = await _uploadFiles(_videos, 'feedback_videos');

      // Tạo document trong Firestore
      final docRef = FirebaseFirestore.instance.collection('FEEDBACKS').doc();

      final feedbackData = {
        'feedbackId': docRef.id,
        'userId': userId,
        'travelRouteId': travelRouteId,
        'destinationId': destinationId,
        'licensePlate': licensePlate,
        'cooperationId': cooperationId,
        'date': DateTime.now().toIso8601String(),
        'star': _rating,
        'comment': _comment,
        'photo': photoUrls,
        'video': videoUrls,
        'status': 'active',
      };

      await docRef.set(feedbackData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Có lỗi xảy ra: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _rating = 0;
    _comment = '';
    _images.clear();
    _videos.clear();
    _error = '';
    notifyListeners();
  }
}
