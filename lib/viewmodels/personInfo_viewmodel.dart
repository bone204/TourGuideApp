import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class PersonInfoViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController citizenIdController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController bankAccountNumberController = TextEditingController();
  final TextEditingController bankAccountNameController = TextEditingController();
  
  bool isEditing = false;
  
  String? gender;
  String? nationality;
  String selectedCountryCode = '+84';
  
  bool isLoading = true;
  
  // Thêm các thuộc tính để lưu trữ thông tin ngân hàng
  String? _bankName;
  String? _bankAccountNumber;
  String? _bankAccountName;
  
  // Getters cho thông tin ngân hàng
  String? get bankName => _bankName;
  String? get bankAccountNumber => _bankAccountNumber;
  String? get bankAccountName => _bankAccountName;
  
  // Kiểm tra xem người dùng đã có thông tin ngân hàng chưa
  bool get hasBankingInfo => 
      _bankName != null && 
      _bankAccountNumber != null && 
      _bankAccountName != null &&
      _bankName!.isNotEmpty &&
      _bankAccountNumber!.isNotEmpty &&
      _bankAccountName!.isNotEmpty;
  
  // Thêm getters để lấy giá trị hiện tại và xử lý đa ngôn ngữ
  String? get currentGender => gender != null && gender!.isNotEmpty
      ? (Localizations.localeOf(navigatorKey.currentContext!).languageCode == 'vi'
          ? gender
          : genderTranslations[gender])
      : null;

  String? get currentNationality => nationality != null && nationality!.isNotEmpty
      ? (Localizations.localeOf(navigatorKey.currentContext!).languageCode == 'vi'
          ? nationality
          : nationalityTranslations[nationality])
      : null;

  // Thêm các Map để chuyển đổi giữa tiếng Anh và tiếng Việt
  final Map<String, String> genderTranslations = {
    'NAM': 'MALE',
    'NỮ': 'FEMALE',
    'Khác': 'Other',
  };

  final Map<String, String> nationalityTranslations = {
    'Việt Nam': 'Vietnamese',
    'Mỹ': 'American',
    'Anh': 'British',
    'Trung Quốc': 'Chinese',
    'Nhật Bản': 'Japanese',
    'Hàn Quốc': 'Korean',
  };

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _getVietnameseGender(String? englishValue) {
    return genderTranslations.entries
        .firstWhere((entry) => entry.value == englishValue,
            orElse: () => const MapEntry('NAM', 'MALE'))
        .key;
  }

  // Hàm chuyển đổi từ tiếng Anh sang tiếng Việt cho nationality
  String _getVietnameseNationality(String? englishValue) {
    return nationalityTranslations.entries
        .firstWhere((entry) => entry.value == englishValue,
            orElse: () => const MapEntry('Việt Nam', 'Vietnamese'))
        .key;
  }

  PersonInfoViewModel() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      isLoading = true;
      notifyListeners();
      
      final docSnapshot = await _firestore
          .collection('USER')
          .doc(_auth.currentUser?.uid)
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        
        fullnameController.text = userData['fullName'] ?? '';
        
        // Cập nhật gender
        String genderValue = userData['gender'] ?? '';
        gender = genderValue;
        genderController.text = genderValue;
        
        citizenIdController.text = userData['citizenId'] ?? '';
        
        // Xử lý số điện thoại
        String fullPhone = userData['phoneNumber'] ?? '';
        if (fullPhone.isNotEmpty) {
          phoneNumberController.text = fullPhone.replaceFirst(selectedCountryCode, '');
        }
        
        addressController.text = userData['address'] ?? '';
        
        // Cập nhật nationality
        String nationalityValue = userData['nationality'] ?? '';
        nationality = nationalityValue;
        nationalityController.text = nationalityValue;
        
        birthdayController.text = userData['birthday'] ?? '';
        
        // Cập nhật thông tin ngân hàng
        _bankName = userData['bankName'] as String?;
        _bankAccountNumber = userData['bankAccountNumber'] as String?;
        _bankAccountName = userData['bankAccountName'] as String?;
        
        // Cập nhật các controller
        bankNameController.text = _bankName ?? '';
        bankAccountNumberController.text = _bankAccountNumber ?? '';
        bankAccountNameController.text = _bankAccountName ?? '';
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('Error loading user data: $e');
    }
  }

  // Save data to Firestore
  Future<void> saveData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String uid = user.uid;
        
        // Kiểm tra ngôn ngữ hiện tại
        bool isEnglish = Localizations.localeOf(navigatorKey.currentContext!).languageCode == 'en';
        
        // Lấy giá trị từ state thay vì từ controller
        String genderValue = isEnglish 
            ? _getVietnameseGender(genderTranslations[gender] ?? '')  
            : gender ?? '';
            
        String nationalityValue = isEnglish
            ? _getVietnameseNationality(nationalityTranslations[nationality] ?? '')
            : nationality ?? '';

        await _firestore.collection('USER').doc(uid).update({
          'fullName': fullnameController.text,
          'gender': genderValue,
          'citizenId': citizenIdController.text,
          'phoneNumber': phoneNumberController.text.trim(),
          'address': addressController.text,
          'nationality': nationalityValue,
          'birthday': birthdayController.text,
          'bankName': bankNameController.text,
          'bankAccountNumber': bankAccountNumberController.text,
          'bankAccountName': bankAccountNameController.text,
        });
        
        // Cập nhật state
        gender = genderValue;
        nationality = nationalityValue;
        
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('Lỗi khi cập nhật thông tin người dùng: $e');
        }
      }
    }
  }

  Future<void> updateUserFromIdCard(Map<String, dynamic> idCardData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không tìm thấy người dùng đang đăng nhập');
      }

      // Map dữ liệu từ CMND/CCCD sang các trường trong user
      final Map<String, dynamic> updateData = {
        'fullName': idCardData['name'],
        'citizenId': idCardData['id'],
        'birthday': idCardData['dob'],
        'gender': idCardData['sex'],
        'address': idCardData['address'],
        'nationality': idCardData['nationality'],
      };

      // Cập nhật thông tin lên Firebase
      await _firestore.collection('USER').doc(user.uid).update(updateData);
    } catch (e) {
      print('Lỗi cập nhật thông tin người dùng: $e');
      throw Exception('Không thể cập nhật thông tin người dùng');
    }
  }

  // Clear data

  Icon getFieldIcon(String text) {
    if (text.trim().isEmpty) {
      return const Icon(Icons.warning_amber_rounded, color: Colors.red);
    }
    return const Icon(Icons.check_circle, color: Colors.green);
  }

  Future<void> loadBankingInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Clear banking info first
        _bankName = null;
        _bankAccountNumber = null;
        _bankAccountName = null;
        bankNameController.clear();
        bankAccountNumberController.clear();
        bankAccountNameController.clear();

        final doc = await FirebaseFirestore.instance
            .collection('USER')
            .doc(user.uid)
            .get();
            
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _bankName = data['bankName'];
          _bankAccountNumber = data['bankAccountNumber'];
          _bankAccountName = data['bankAccountName'];
          
          bankNameController.text = _bankName ?? '';
          bankAccountNumberController.text = _bankAccountNumber ?? '';
          bankAccountNameController.text = _bankAccountName ?? '';
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading banking info: $e');
    }
  }
}
