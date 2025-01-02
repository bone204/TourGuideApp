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
    'Nam': 'Male',
    'Nữ': 'Female',
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

  // Thêm GlobalKey để truy cập BuildContext
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Hàm chuyển đổi từ tiếng Anh sang tiếng Việt cho gender
  String _getVietnameseGender(String? englishValue) {
    return genderTranslations.entries
        .firstWhere((entry) => entry.value == englishValue,
            orElse: () => const MapEntry('Nam', 'Male'))
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
            ? _getVietnameseGender(genderTranslations[gender] ?? '')  // Chuyển từ tiếng Việt sang Anh rồi lại về Việt
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

  // Clear data
  void _clearData() {
    fullnameController.text = '';
    genderController.text = '';
    citizenIdController.text = '';
    phoneNumberController.text = '';
    addressController.text = '';
    nationalityController.text = '';
    birthdayController.text = '';
    bankNameController.text = '';
    bankAccountNumberController.text = '';
    bankAccountNameController.text = '';
    notifyListeners();
  }

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
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          bankNameController.text = data['bankName'] ?? '';
          bankAccountNumberController.text = data['bankAccountNumber'] ?? '';
          bankAccountNameController.text = data['bankAccountName'] ?? '';
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading banking info: $e');
    }
  }
}
